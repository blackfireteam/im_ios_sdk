//
//  CustomCommonEmptyView.m
//  NHDZiDemo
//
//  Created by 王方芳 on 16/9/17.
//  Copyright © 2016年 BennyW. All rights reserved.
//

#import "CustomCommonEmptyView.h"
#import "MSIMSDK-UIKit.h"

#define KtopImageWH 200
@interface CustomCommonEmptyView()

@end
@implementation CustomCommonEmptyView

- (instancetype)initWithTitle:(NSString *)title
                  secondTitle:(NSString *)secondTitle
                     iconName:(NSString *)iconName
{
    if(self = [super init]) {
        self.firstLabel.text = title;
        self.secondLabel.text = secondTitle;
        self.topTipImageView.image = [UIImage imageNamed:iconName];
        self.firstLabel.hidden = (title.length == 0);
        self.secondLabel.hidden = (secondTitle.length == 0);
        [self addSubview:self.topTipImageView];
        [self addSubview:self.firstLabel];
        [self addSubview:self.secondLabel];
    }
    return self;
}

- (void)showInView:(UIView *)view
{
    if(view) {
        [view addSubview:self];
    }
}

- (UILabel *)firstLabel
{
    if(!_firstLabel) {
        _firstLabel = [[UILabel alloc]init];
        _firstLabel.font = [UIFont systemFontOfSize:15];
        _firstLabel.textColor = [UIColor blackColor];
        _firstLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _firstLabel;
}

- (UILabel *)secondLabel
{
    if(!_secondLabel) {
        _secondLabel = [[UILabel alloc]init];
        _secondLabel.font = [UIFont systemFontOfSize:12];
        _secondLabel.textColor = [UIColor blackColor];
        _secondLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _secondLabel;
}

- (UIImageView *)topTipImageView
{
    if(!_topTipImageView) {
        _topTipImageView = [[UIImageView alloc]init];
    }
    return _topTipImageView;
}

- (CGFloat)emptyViewHeight
{
    CGFloat height = KtopImageWH;
    if(self.firstLabel.hidden == NO) {
        height += 35;
    }
    if(self.secondLabel.hidden == NO) {
        height += 24;
    }
    return height;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.topTipImageView.frame = CGRectMake(self.width*.5-KtopImageWH*.5, 0, KtopImageWH, KtopImageWH);
    self.firstLabel.frame = CGRectMake(0, CGRectGetMaxY(self.topTipImageView.frame)+15, self.width, 20);
    self.secondLabel.frame = CGRectMake(0, CGRectGetMaxY(self.firstLabel.frame)+10, self.width, 14);
}

@end
