//
//  MSTipsView.m
//  BlackFireIM
//
//  Created by benny wang on 2021/12/21.
//

#import "MSTipsView.h"
#import "MSIMSDK-UIKit.h"


@interface MSTipsView()

@property(nonatomic,strong) UIImageView *icon;

@property(nonatomic,strong) UILabel *noticeL;

@property(nonatomic,strong) UIImageView *indicator;

@end
@implementation MSTipsView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
        
        self.icon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"notice_icon"]];
        self.icon.frame = CGRectMake(8, 10, 20, 20);
        [self addSubview:self.icon];
        
        self.noticeL = [[UILabel alloc]initWithFrame:CGRectMake(self.icon.maxX + 10, 5, Screen_Width - 150, 30)];
        self.noticeL.textColor = [UIColor blackColor];
        self.noticeL.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.noticeL];
        
        self.indicator = [[UIImageView alloc]initWithFrame:CGRectMake(Screen_Width - 15 - 20, 10, 20, 20)];
        self.indicator.image = [UIImage imageNamed:@"disclosure_indicator"];
        [self addSubview:self.indicator];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(noticeTap)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)showTips:(NSString *)text
{
    self.noticeL.text = text;
    self.height = 0;
    [UIView animateWithDuration:0.25 animations:^{
        self.height = 40;
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void)dismiss
{
    [UIView animateWithDuration:0.25 animations:^{
        self.height = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)noticeTap
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"kChatRoomTipsDidTap" object:nil];
}

@end
