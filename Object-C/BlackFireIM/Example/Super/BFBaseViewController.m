//
//  BFBaseViewController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/29.
//

#import "BFBaseViewController.h"
#import "UIColor+BFDarkMode.h"
#import "MSIMSDK-UIKit.h"
#import "CustomCommonEmptyView.h"
#import <Lottie/Lottie.h>
#import "UINavigationController+FDFullscreenPopGesture.h"

@interface BFBaseViewController ()

@property (nonatomic,strong)CustomCommonEmptyView *emptyView;

@property (nonatomic,copy)void(^rightBarItemClick)(void);
@end

@implementation BFBaseViewController

- (instancetype)init
{
    if(self = [super init]) {
        self.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
    self.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    
    WS(weakSelf)
    self.navView = [[WFNavigationView alloc]initWithBackgroundColor:[UIColor d_colorWithColorLight:[UIColor whiteColor] dark:[UIColor blackColor]] leftItemClick:^(UIButton *leftBtn) {
        [weakSelf nav_leftButtonClick];
    } rightItemClick:^(UIButton *rightBtn) {
        [weakSelf nav_rightButtonClick];
    }];
    [self.navView.leftButton setImage:[UIImage d_imageWithImageLight:@"nav_back" dark:@"nav_back_white"] forState:UIControlStateNormal];
    [self.navView.rightButton setTitleColor:[UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark] forState:UIControlStateNormal];
    [self.navView.leftButton setTitleColor:[UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark] forState:UIControlStateNormal];
    self.navView.frame = CGRectMake(0, 0, Screen_Width, StatusBar_Height+NavBar_Height);
    [self.view addSubview:self.navView];

}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.view bringSubviewToFront:self.navView];
}

- (CustomCommonEmptyView *)emptyView
{
    if(!_emptyView) {
        _emptyView = [[CustomCommonEmptyView alloc]initWithTitle:[self placeHolderOfText]
                                                     secondTitle:nil
                                                        iconName:[self placeHolderOfImage]];
        _emptyView.firstLabel.textColor = [self placeHolderTextOfColor];
    }
    return _emptyView;
}

- (void)showEmptyViewInView:(UIView *)view
{
    UIView *superV = view;
    if(view == nil) {
        superV = self.view;
    }
    [self.emptyView showInView:superV];
    CGFloat offsetY = [self placeImageOffsetY];
    CGRect frame = CGRectMake(0, superV.height*.5-self.emptyView.emptyViewHeight*.5, superV.width, self.emptyView.emptyViewHeight);
    frame.origin.y -= offsetY;
    self.emptyView.frame = frame;
    UIButton *btn = [self placeHolderButton];
    if(btn) {
        btn.frame = CGRectMake(frame.size.width*.5-190*.5,frame.size.height+20, 190, 40);
        frame.size.height += 60;
        self.emptyView.frame = frame;
        [self.emptyView addSubview:btn];
    }
}

- (void)hideEmptyView
{
    if(_emptyView) {
        [_emptyView removeFromSuperview];
        _emptyView = nil;
    }
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if (![touch.view isKindOfClass: [UITextField class]] || ![touch.view isKindOfClass: [UITextView class]]) {
        [self.view endEditing:YES];
    }
}

- (void)nav_leftButtonClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nav_rightButtonClick
{
    
}

/** 子类重写******************************/
/** 占位图片*/
- (NSString *)placeHolderOfImage
{
    return @"";
}

/** 占位文字*/
- (NSString *)placeHolderOfText
{
    return @"no more data";
}

/** 占位的颜色*/
- (UIColor *)placeHolderTextOfColor
{
    return [UIColor lightGrayColor];
}

/** 空白页面按钮*/
- (UIButton *)placeHolderButton
{
    return nil;
}

/** 空白点位图片Y轴的偏移量，默认为Screen_Nav_Height+Screen_StatusBar_Height+30*/
- (CGFloat)placeImageOffsetY
{
    return (NavBar_Height+StatusBar_Height+30);
}

/** 空白点位图片Y轴的偏移量，默认为Screen_Nav_Height+Screen_StatusBar_Height+30*/
- (CGFloat)loadingViewOffsetY
{
    return (NavBar_Height+StatusBar_Height+30);
}

/** 无网络页面Y轴的偏移量，默认为Screen_Nav_Height+Screen_StatusBar_Height+30*/
- (CGFloat)noNetworkViewOffsetY
{
    return (NavBar_Height+StatusBar_Height+30);
}

- (void)dealloc
{
    MSLog(@"****%@ dealloc~",self.class);
}

@end
