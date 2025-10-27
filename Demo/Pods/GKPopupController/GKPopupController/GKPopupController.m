//
//  GKPopupController.m
//  GKPopupController
//
//  Created by QuintGao on 2024/1/12.
//

#import "GKPopupController.h"

typedef NS_ENUM(NSUInteger, GKPopupPanGestureDirection) {
    GKPopupPanGestureDirectionHorizontal,   // 水平方向
    GKPopupPanGestureDirectionVertical      // 竖直方向
};

int const static kPopupPanTranslationThreshold = 10;

@interface GKPopupPanGestureRecognizer : UIPanGestureRecognizer

@property (nonatomic, assign) GKPopupPanGestureDirection direction;

@end

@implementation GKPopupPanGestureRecognizer {
    BOOL _isDrag;
    int _moveX;
    int _moveY;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    if (self.state == UIGestureRecognizerStateFailed) return;
    CGPoint nowPoint = [[touches anyObject] locationInView:self.view];
    CGPoint prevPoint = [[touches anyObject] previousLocationInView:self.view];
    _moveX += prevPoint.x - nowPoint.x;
    _moveY += prevPoint.y - nowPoint.y;
    if (!_isDrag) {
        if (abs(_moveX) > kPopupPanTranslationThreshold) {
            if (self.direction == GKPopupPanGestureDirectionVertical) {
                self.state = UIGestureRecognizerStateFailed;
            }else {
                _isDrag = YES;
            }
        }else if (abs(_moveY) > kPopupPanTranslationThreshold) {
            if (self.direction == GKPopupPanGestureDirectionHorizontal) {
                self.state = UIGestureRecognizerStateFailed;
            }else {
                _isDrag = YES;
            }
        }
    }
}

- (void)reset {
    [super reset];
    _isDrag = NO;
    _moveX = 0;
    _moveY = 0;
}

@end

@interface GKPopupController ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIWindow *alertWindow;

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, weak) UIView *contentView;

@property (nonatomic, weak) UIScrollView *scrollView;

@property (nonatomic, assign) BOOL isDragScrollView;

@property (nonatomic, assign) CGPoint beginTranslation;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, strong) GKPopupPanGestureRecognizer *horizontalPanGesture;

@property (nonatomic, strong) GKPopupPanGestureRecognizer *verticalPanGesture;

@end

@implementation GKPopupController

- (instancetype)initWithContentView:(UIView *)contentView {
    if (self = [super init]) {
        self.contentView = contentView;
        self.statusBarHidden = NO;
        self.statusBarStyle = UIStatusBarStyleLightContent;
        self.bgColor = [UIColor.blackColor colorWithAlphaComponent:0.5];
        self.animationDuration = 0.25;
        self.allowsTapDismiss = YES;
        self.allowsSlideDismiss = YES;
        self.allowsRightSlideDismiss = YES;
        self.velocityThreshold = 300;
    }
    return self;
}

- (BOOL)prefersStatusBarHidden {
    return self.statusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.statusBarStyle;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}

#pragma mark - Public
- (void)show {
    [self initUI];
    [self alertWindow];
    [self showWithCompletion:nil];
}

- (void)showWithCompletion:(void(^)(void))completion {
    if (self.contentView.frame.origin.y == self.view.frame.size.height - self.contentHeight) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(contentViewWillShow)]) {
        [self.delegate contentViewWillShow];
    }
    __weak __typeof(self) weakSelf = self;
    [self showAnimationCompletion:^{
        __strong __typeof(weakSelf) self = weakSelf;
        if ([self.delegate respondsToSelector:@selector(contentViewDidShow)]) {
            [self.delegate contentViewDidShow];
        }
        !completion ?: completion();
    }];
}

- (void)dismiss {
    [self dismissWithCompletion:nil];
}

- (void)dismissWithCompletion:(void(^)(void))completion {
    if ([self.delegate respondsToSelector:@selector(contentViewWillDismiss)]) {
        [self.delegate contentViewWillDismiss];
    }
    __weak __typeof(self) weakSelf = self;
    [self dismissAnimationCompletion:^{
        __strong __typeof(weakSelf) self = weakSelf;
        if ([self.delegate respondsToSelector:@selector(contentViewDidDismiss)]) {
            [self.delegate contentViewDidDismiss];
        }
        self.alertWindow.hidden = YES;
        self.alertWindow.rootViewController = nil;
        !self.dismissBlock ?: self.dismissBlock();
        !completion ?: completion();
    }];
}

- (void)refreshContentHeight {
    CGFloat originHeight = _contentHeight;
    if (self.contentHeight > originHeight) {
        CGRect frame = self.contentView.frame;
        frame.size.height = self.contentHeight;
        self.contentView.frame = frame;
        [self addTopCorner];
    }
    
    [UIView animateWithDuration:self.animationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect frame = self.contentView.frame;
        frame.origin.y = CGRectGetHeight(self.view.frame) - self.contentHeight;
        self.contentView.frame = frame;
        if ([self.delegate respondsToSelector:@selector(contentViewRefreshAnimation)]) {
            [self.delegate contentViewRefreshAnimation];
        }
    } completion:^(BOOL finished) {
        CGRect frame = self.contentView.frame;
        frame.size.height = self.contentHeight;
        self.contentView.frame = frame;
        [self addTopCorner];
        if ([self.delegate respondsToSelector:@selector(contentViewRefreshCompletion)]) {
            [self.delegate contentViewRefreshCompletion];
        }
    }];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == self.horizontalPanGesture || gestureRecognizer == self.verticalPanGesture) {
        UIView *touchView = touch.view;
        while (touchView != nil) {
            if ([touchView isKindOfClass:UIScrollView.class]) {
                self.scrollView = (UIScrollView *)touchView;
                self.isDragScrollView = YES;
                break;
            }else if (touchView == self.contentView) {
                self.isDragScrollView = NO;
                break;
            }
            touchView = (UIView *)[touchView nextResponder];
        }
    }
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self.contentView];
    if (gestureRecognizer == self.tapGesture) {
        if ([self.contentView.layer containsPoint:point] && gestureRecognizer.view == self.view) {
            return NO;
        }
    }else if (gestureRecognizer == self.horizontalPanGesture || gestureRecognizer == self.verticalPanGesture) {
        if (![self.contentView.layer containsPoint:point] && gestureRecognizer.view == self.view) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == self.horizontalPanGesture || gestureRecognizer == self.verticalPanGesture) {
        if ([otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")] || [otherGestureRecognizer isKindOfClass:UIPanGestureRecognizer.class]) {
            if ([otherGestureRecognizer.view isKindOfClass:UIScrollView.class]) {
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark - Gesture Handle
- (void)handleTapGesture:(UITapGestureRecognizer *)tapGesture {
    CGPoint point = [tapGesture locationInView:self.contentView];
    if (![self.contentView.layer containsPoint:point] && tapGesture.view == self.view) {
        [self dismiss];
    }
}

- (void)handlePanGesture:(GKPopupPanGestureRecognizer *)panGesture {
    CGPoint translation = [panGesture locationInView:panGesture.view];
    CGPoint velocity = [panGesture velocityInView:panGesture.view];
    // 最小Y值
    CGFloat minY = CGRectGetHeight(self.view.frame) - self.contentHeight;
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            self.beginTranslation = translation;
            // 横向滑动时，禁止UIScrollView滑动
            if (panGesture.direction == GKPopupPanGestureDirectionHorizontal) {
                if (!self.allowsRightSlideDismiss) {
                    self.scrollView.panGestureRecognizer.enabled = NO;
                }
                if (self.isDragScrollView && self.scrollView.contentSize.width <= self.scrollView.frame.size.width) {
                    self.scrollView.panGestureRecognizer.enabled = NO;
                }
            }
            if ([self.delegate respondsToSelector:@selector(panSlideBegan)]) {
                [self.delegate panSlideBegan];
            }
        }
            break;
        case UIGestureRecognizerStateChanged: {
            if (panGesture.direction == GKPopupPanGestureDirectionHorizontal) { // 横向滑动
                // 滑动百分比
                CGFloat ratio = (translation.x - self.beginTranslation.x) / CGRectGetWidth(self.view.frame);
                if (self.isDragScrollView) {
                    // 当UIScrollView在最左端时，处理视图的滑动
                    if (self.scrollView.contentOffset.x <= 0 && (translation.x - self.beginTranslation.x) > 0) {
                        self.scrollView.contentOffset = CGPointZero;
                        self.scrollView.panGestureRecognizer.enabled = NO;
                        self.isDragScrollView = NO;
                        self.beginTranslation = translation;
                        if ([self.delegate respondsToSelector:@selector(panSlideChangeWithRatio:)]) {
                            [self.delegate panSlideChangeWithRatio:ratio];
                        }
                    }
                }else {
                    if (self.dismissType == GKRightSlideDismissType_Down) {
                        // 转换为Y值
                        CGFloat scrollY = minY + self.contentHeight * ratio;
                        [self updateContentViewFrameY:scrollY];
                    }else {
                        // 转换为X值
                        CGFloat scrollX = self.view.frame.size.width * ratio;
                        [self updateContentViewFrameX:scrollX];
                    }
                    if ([self.delegate respondsToSelector:@selector(panSlideChangeWithRatio:)] && ratio >= 0) {
                        [self.delegate panSlideChangeWithRatio:ratio];
                    }
                }
            }else { // 纵向滑动
                CGFloat scrollY = minY + (translation.y - self.beginTranslation.y);
                CGFloat ratio = (translation.y - self.beginTranslation.y) / self.contentHeight;
                if (self.isDragScrollView) { // 拖拽scrollView
                    // 当UIScrollView在最顶端时，处理视图的滑动
                    if (self.scrollView.contentOffset.y <= 0 && (translation.y - self.beginTranslation.y) > 0) {
                        self.scrollView.contentOffset = CGPointZero;
                        self.scrollView.panGestureRecognizer.enabled = NO;
                        self.isDragScrollView = NO;
                        self.beginTranslation = translation;
                        if ([self.delegate respondsToSelector:@selector(panSlideChangeWithRatio:)]) {
                            [self.delegate panSlideChangeWithRatio:ratio];
                        }
                    }
                }else {
                    [self updateContentViewFrameY:scrollY];
                    if ([self.delegate respondsToSelector:@selector(panSlideChangeWithRatio:)] && ratio >= 0) {
                        [self.delegate panSlideChangeWithRatio:ratio];
                    }
                }
            }
            // 背景透明度
            CGFloat alpha = (CGRectGetHeight(self.view.frame) - CGRectGetMinY(self.contentView.frame)) / self.contentHeight;
            self.backgroundView.alpha = alpha;
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            // 平移距离
            CGFloat translationY = CGRectGetMinY(self.contentView.frame) - minY;
            if (panGesture.direction == GKPopupPanGestureDirectionHorizontal) {
                if (self.dismissType == GKRightSlideDismissType_Down) {
                    if (velocity.x > self.velocityThreshold || translationY > self.translationThreshold) {
                        if ([self.delegate respondsToSelector:@selector(panSlideEnded:)]) {
                            [self.delegate panSlideEnded:NO];
                        }
                        [self dismiss];
                    }else {
                        if ([self.delegate respondsToSelector:@selector(panSlideEnded:)]) {
                            [self.delegate panSlideEnded:YES];
                        }
                        [self showAnimationCompletion:nil];
                    }
                }else {
                    CGFloat translationX = CGRectGetMinX(self.contentView.frame);
                    if (velocity.x > self.velocityThreshold || translationX > self.translationThreshold) {
                        if ([self.delegate respondsToSelector:@selector(panSlideEnded:)]) {
                            [self.delegate panSlideEnded:NO];
                        }
                        [self dismissRightSlideAnimation];
                    }else {
                        if ([self.delegate respondsToSelector:@selector(panSlideEnded:)]) {
                            [self.delegate panSlideEnded:YES];
                        }
                        [self showRightSlideAnimation];
                    }
                }
            }else {
                if (velocity.y > self.velocityThreshold || translationY > self.translationThreshold) {
                    if ([self.delegate respondsToSelector:@selector(panSlideEnded:)]) {
                        [self.delegate panSlideEnded:NO];
                    }
                    [self dismiss];
                }else {
                    if ([self.delegate respondsToSelector:@selector(panSlideEnded:)]) {
                        [self.delegate panSlideEnded:YES];
                    }
                    [self showAnimationCompletion:nil];
                }
            }
            self.scrollView.panGestureRecognizer.enabled = YES;
        }
            break;
        default:
            break;
    }
}

#pragma mark - Private
- (void)initUI {
    self.delegate.popupController = self;
    
    CGRect frame = self.view.bounds;
    self.backgroundView.frame = frame;
    [self.view addSubview:self.backgroundView];
    
    frame.origin.y = frame.size.height;
    frame.size.height = self.contentHeight;
    self.contentView.frame = frame;
    [self.view addSubview:self.contentView];
    
    [self addTopCorner];
    
    if (self.allowsTapDismiss) {
        [self.view addGestureRecognizer:self.tapGesture];
    }
    if (self.allowsSlideDismiss) {
        [self.view addGestureRecognizer:self.verticalPanGesture];
        if (self.allowsRightSlideDismiss) {
            [self.view addGestureRecognizer:self.horizontalPanGesture];
        }
    }
}

- (void)addTopCorner {
    if (self.topCornerRadius > 0) {
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.contentView.bounds byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight) cornerRadii:CGSizeMake(self.topCornerRadius, self.topCornerRadius)];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = self.contentView.bounds;
        maskLayer.path = bezierPath.CGPath;
        self.contentView.layer.mask = maskLayer;
    }
}

- (void)showAnimationCompletion:(void(^)(void))completion {
    if (self.contentView.frame.origin.y == self.view.frame.size.height - self.contentHeight) {
        return;
    }
    [UIView animateWithDuration:self.animationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect frame = self.contentView.frame;
        frame.origin.y = self.view.frame.size.height - self.contentHeight;
        self.contentView.frame = frame;
        self.backgroundView.alpha = 1;
        if ([self.delegate respondsToSelector:@selector(contentViewShowAnimation)]) {
            [self.delegate contentViewShowAnimation];
        }
    } completion:^(BOOL finished) {
        !completion ?: completion();
    }];
}

- (void)dismissAnimationCompletion:(void(^)(void))completion {
    [UIView animateWithDuration:self.animationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect frame = self.contentView.frame;
        frame.origin.y = self.view.frame.size.height;
        self.contentView.frame = frame;
        self.backgroundView.alpha = 0;
        if ([self.delegate respondsToSelector:@selector(contentViewDismissAnimation)]) {
            [self.delegate contentViewDismissAnimation];
        }
    } completion:^(BOOL finished) {
        !completion ?: completion();
    }];
}

- (void)showRightSlideAnimation {
    if (self.contentView.frame.origin.x == 0) {
        return;
    }
    [UIView animateWithDuration:self.animationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect frame = self.contentView.frame;
        frame.origin.x = 0;
        self.contentView.frame = frame;
        self.backgroundView.alpha = 1;
    } completion:nil];
}

- (void)dismissRightSlideAnimation {
    [UIView animateWithDuration:self.animationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect frame = self.contentView.frame;
        frame.origin.x = self.view.frame.size.width;
        self.contentView.frame = frame;
        self.backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(contentViewDidDismiss)]) {
            [self.delegate contentViewDidDismiss];
        }
        self.alertWindow.hidden = YES;
        self.alertWindow.rootViewController = nil;
        !self.dismissBlock ?: self.dismissBlock();
    }];
}

- (void)updateContentViewFrameX:(CGFloat)x {
    x = MAX(0, x);
    CGFloat maxX = self.contentView.frame.size.width;
    CGRect frame = self.contentView.frame;
    frame.origin.x = MIN(maxX, x);
    self.contentView.frame = frame;
}

- (void)updateContentViewFrameY:(CGFloat)y {
    CGFloat minY = CGRectGetHeight(self.view.frame) - self.contentHeight;
    CGRect frame = self.contentView.frame;
    frame.origin.y = MAX(minY, y);
    self.contentView.frame = frame;
}

- (CGFloat)translationThreshold {
    if (_translationThreshold > 0) {
        return _translationThreshold;
    }
    if (self.dismissType == GKRightSlideDismissType_Down) {
        return self.contentHeight / 2;
    }else {
        return self.contentView.frame.size.width / 2;
    }
}

#pragma mark - Lazy
- (CGFloat)contentHeight {
    if ([self.delegate respondsToSelector:@selector(contentHeight)]) {
        _contentHeight = [self.delegate contentHeight];
    }
    return _contentHeight;
}

- (UIWindow *)alertWindow {
    if (!_alertWindow) {
        if (@available(iOS 13.0, *)) {
            UIScene *scene = [UIApplication sharedApplication].connectedScenes.allObjects.firstObject;
            if (scene && [scene isKindOfClass:UIWindowScene.class]) {
                _alertWindow = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
            }
        }
        if (!_alertWindow) {
            _alertWindow = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        }
        _alertWindow.windowLevel = UIWindowLevelStatusBar;
        _alertWindow.backgroundColor = UIColor.clearColor;
        _alertWindow.hidden = NO;
        
        BOOL needNav = self.needNavigationController;
        if (needNav) {
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self];
            nav.view.backgroundColor = UIColor.clearColor;
            _alertWindow.rootViewController = nav;
        }else {
            _alertWindow.rootViewController = self;
        }
    }
    return _alertWindow;
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = self.bgColor;
        _backgroundView.alpha = 0;
    }
    return _backgroundView;
}

- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        _tapGesture.delegate = self;
    }
    return _tapGesture;
}

- (GKPopupPanGestureRecognizer *)horizontalPanGesture {
    if (!_horizontalPanGesture) {
        _horizontalPanGesture = [[GKPopupPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        _horizontalPanGesture.delegate = self;
        _horizontalPanGesture.direction = GKPopupPanGestureDirectionHorizontal;
    }
    return _horizontalPanGesture;
}

- (GKPopupPanGestureRecognizer *)verticalPanGesture {
    if (!_verticalPanGesture) {
        _verticalPanGesture = [[GKPopupPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        _verticalPanGesture.delegate = self;
        _verticalPanGesture.direction = GKPopupPanGestureDirectionVertical;
    }
    return _verticalPanGesture;
}

@end
