//
//  CustomCommonEmptyView.h
//  NHDZiDemo
//
//  Created by 王方芳 on 16/9/17.
//  Copyright © 2016年 BennyW. All rights reserved.
//
//空白页提醒
#import <UIKit/UIKit.h>

@interface CustomCommonEmptyView : UIView

/** 图片*/
@property (nonatomic,strong)UIImageView *topTipImageView;
/** 主标题*/
@property (nonatomic,strong)UILabel *firstLabel;
/** 副标题*/
@property (nonatomic,strong)UILabel *secondLabel;

- (instancetype)initWithTitle:(NSString *)title
                  secondTitle:(NSString *)secondTitle
                     iconName:(NSString *)iconName;

- (void)showInView:(UIView *)view;

- (CGFloat)emptyViewHeight;

@end
