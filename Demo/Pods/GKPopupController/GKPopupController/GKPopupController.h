//
//  GKPopupController.h
//  GKPopupController
//
//  Created by QuintGao on 2024/1/12.
//

#import <UIKit/UIKit.h>
#import "GKPopupProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, GKRightSlideDismissType) {
    GKRightSlideDismissType_Down,   // 向下
    GKRightSlideDismissType_Right   // 向右
};

@interface GKPopupController : UIViewController

/// 是否隐藏状态栏，默认NO
@property (nonatomic, assign) BOOL statusBarHidden;

/// 状态栏样式，默认Light
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

/// 是否需要导航控制器，默认NO
@property (nonatomic, assign) BOOL needNavigationController;

/// 背景色，默认黑色0.5透明度
@property (nonatomic, strong) UIColor *bgColor;

/// 动画时间，默认0.25
@property (nonatomic, assign) NSTimeInterval animationDuration;

/// 是否允许点击隐藏，默认YES
@property (nonatomic, assign) BOOL allowsTapDismiss;

/// 是否允许滑动（包括下滑和右滑）隐藏，默认YES
@property (nonatomic, assign) BOOL allowsSlideDismiss;

/// 是否允许右滑隐藏，默认YES
@property (nonatomic, assign) BOOL allowsRightSlideDismiss;

/// 右滑隐藏类型
@property (nonatomic, assign) GKRightSlideDismissType dismissType;

/// 滑动返回时的速度阈值，超过此阈值会dismiss，默认300
@property (nonatomic, assign) CGFloat velocityThreshold;

/// 滑动返回时的平移阈值，超过此阈值会dismiss，默认contentView高度(或宽度)的一半
@property (nonatomic, assign) CGFloat translationThreshold;

/// 内容视图高度
@property (nonatomic, assign) CGFloat contentHeight;

/// 内容视图顶部圆角度数，默认0
@property (nonatomic, assign) CGFloat topCornerRadius;

/// 隐藏block
@property (nonatomic, copy) void(^dismissBlock)(void);

/// 代理
@property (nonatomic, weak) id<GKPopupProtocol> delegate;

- (instancetype)init NS_UNAVAILABLE;

/// 初始化
- (instancetype)initWithContentView:(UIView *)contentView;

/// 显示
- (void)show;
- (void)showWithCompletion:(void(^_Nullable)(void))completion;

/// 隐藏
- (void)dismiss;
- (void)dismissWithCompletion:(void(^_Nullable)(void))completion;

/// 刷新内容高度，当内容高度改变是调用此方法进行刷新
- (void)refreshContentHeight;

@end

NS_ASSUME_NONNULL_END
