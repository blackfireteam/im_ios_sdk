//
//  BFBaseViewController.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/29.
//

#import <UIKit/UIKit.h>
#import "WFNavigationView.h"


NS_ASSUME_NONNULL_BEGIN

@interface BFBaseViewController : UIViewController

/** 自定义导航栏*/
@property (nonatomic,strong)WFNavigationView *navView;

/** 显示空页面*/
- (void)showEmptyViewInView:(UIView *)view;

/** 隐藏空页面*/
- (void)hideEmptyView;

/** 子类重写******************************/

/** 占位图片*/
- (NSString *)placeHolderOfImage;
/** 占位文字*/
- (NSString *)placeHolderOfText;

/** 占位的颜色*/
- (UIColor *)placeHolderTextOfColor;

/** 空白页面按钮*/
- (UIButton *)placeHolderButton;

/** 空白点位图片Y轴的偏移量，默认为Screen_Nav_Height+Screen_StatusBar_Height+30*/
- (CGFloat)placeImageOffsetY;

- (void)nav_leftButtonClick;

- (void)nav_rightButtonClick;

@end

NS_ASSUME_NONNULL_END
