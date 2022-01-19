//
//  WFNavigationView.m
//  XiaoMaiQuan
//
//  Created by bennyw on 2017/3/29.
//  Copyright © 2017年 XMQ. All rights reserved.
//

#import "WFNavigationView.h"
#import "MSHeader.h"

@interface WFNavigationView()

@property (nonatomic,copy)void(^leftItemClick)(UIButton *sender);
@property (nonatomic,copy)void(^rightItemClick)(UIButton *sender);

@end
@implementation WFNavigationView

- (instancetype)initWithBackgroundColor:(UIColor *)color
                          leftItemClick:(void(^)(UIButton *leftBtn))leftBlock
                         rightItemClick:(void(^)(UIButton *rightBtn))rightBlock
{
    if(self = [super init]) {
        
        self.frame = CGRectMake(0, 0, Screen_Width, StatusBar_Height+NavBar_Height);
        self.backgroundColor = color;
        _leftItemClick = leftBlock;
        _rightItemClick = rightBlock;
        [self setupUI];
    }
    return self;
}

- (UIVisualEffectView *)effectView
{
    if(!_effectView) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _effectView = [[UIVisualEffectView alloc]initWithEffect:effect];
        _effectView.hidden = YES;
    }
    return _effectView;
}

- (void)setupUI
{
    [self addSubview:self.effectView];
    self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.leftButton addTarget:self action:@selector(leftClick:) forControlEvents:UIControlEventTouchUpInside];
    self.leftButton.adjustsImageWhenHighlighted = NO;
    [self addSubview:self.leftButton];
    
    self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.rightButton setTitleColor:TText_Color forState:UIControlStateNormal];
    self.rightButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.rightButton addTarget:self action:@selector(rightClick:) forControlEvents:UIControlEventTouchUpInside];
    self.rightButton.adjustsImageWhenHighlighted = NO;
    [self addSubview:self.rightButton];
    
    self.navTitleL = [[UILabel alloc]init];
    self.navTitleL.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
    self.navTitleL.font = [UIFont boldSystemFontOfSize:16];
    self.navTitleL.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.navTitleL];
    
    self.bottomLine = [[UIView alloc]init];
    self.bottomLine.backgroundColor = [UIColor d_colorWithColorLight:TCell_separatorColor dark:TCell_separatorColor_Dark];
    [self addSubview:self.bottomLine];
}

- (void)leftClick:(UIButton *)sender
{
    if(self.leftItemClick) {
        self.leftItemClick(sender);
    }
}

- (void)rightClick:(UIButton *)sender
{
    if(self.rightItemClick) {
        self.rightItemClick(sender);
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.effectView.frame = self.bounds;
    self.leftButton.frame = CGRectMake(0, StatusBar_Height, NavBar_Height, NavBar_Height);
    self.rightButton.frame = CGRectMake(Screen_Width-NavBar_Height - 10, StatusBar_Height, NavBar_Height, NavBar_Height);
    self.navTitleL.frame = CGRectMake(MAX(self.leftButton.width, self.rightButton.width), StatusBar_Height, Screen_Width-2*MAX(self.leftButton.width, self.rightButton.width), NavBar_Height);
    self.bottomLine.frame = CGRectMake(0, self.height-0.5, Screen_Width, 0.5);
}

@end
