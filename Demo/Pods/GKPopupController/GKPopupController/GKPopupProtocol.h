//
//  GKPopupProtocol.h
//  Pods
//
//  Created by QuintGao on 2024/1/12.
//

#import <UIKit/UIKit.h>

@class GKPopupController;

@protocol GKPopupProtocol <NSObject>

@property (nonatomic, weak) GKPopupController *popupController;

@optional

// 内容视图高度，优先级高于contentHeight
- (CGFloat)contentHeight;

// 滑动开始
- (void)panSlideBegan;

// 滑动中，滑动比例
- (void)panSlideChangeWithRatio:(CGFloat)ratio;

// 滑动结束，isShow是否显示
- (void)panSlideEnded:(BOOL)isShow;

// 即将显示
- (void)contentViewWillShow;
// 显示动画
- (void)contentViewShowAnimation;
// 已经显示
- (void)contentViewDidShow;

// 即将隐藏
- (void)contentViewWillDismiss;
// 隐藏动画
- (void)contentViewDismissAnimation;
// 已经隐藏
- (void)contentViewDidDismiss;

// 高度刷新动画
- (void)contentViewRefreshAnimation;
// 高度刷新完成
- (void)contentViewRefreshCompletion;

@end
