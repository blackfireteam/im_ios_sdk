//
//  BFProfileRowItemView.m
//  BlackFireIM
//
//  Created by benny wang on 2021/12/23.
//

#import "BFProfileRowView.h"
#import "MSIMSDK-UIKit.h"
#import "BFSettingController.h"
#import "BFFeedbackController.h"


@interface BFProfileRowView()


@end
@implementation BFProfileRowView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor d_colorWithColorLight:[UIColor whiteColor] dark:TPage_Color_Dark];
        self.layer.cornerRadius = 8;
        self.clipsToBounds = YES;
        
        NSArray *images = @[@"setting_share",@"help_hover",@"settings"];
        NSArray *titles = @[@"推荐给好友",@"意见反馈",@"设置"];
        for (NSInteger i = 0; i < images.count; i++) {
            BFProfileItemView *item = [[BFProfileItemView alloc]init];
            item.tag = 1000 + i;
            item.icon.image = [UIImage imageNamed:images[i]];
            item.titleL.text = titles[i];
            item.frame = CGRectMake(0, 60*i, self.width, 60);
            [self addSubview:item];
            if (i != images.count - 1) {
                UIView *line  = [[UIView alloc]initWithFrame:CGRectMake(15, item.maxY, item.width - 30, 0.5)];
                line.backgroundColor = [UIColor d_colorWithColorLight:TLine_Color dark:TLine_Color_Dark];
                line.alpha = 0.5;
                [self addSubview:line];
            }
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(itemTap:)];
            [item addGestureRecognizer:tap];
        }
    }
    return self;
}

- (void)itemTap:(UITapGestureRecognizer *)ges
{
    NSInteger tag = ges.view.tag;
    if (tag == 1002) {
        BFSettingController *vc = [[BFSettingController alloc]init];
        [self.bf_viewController.navigationController pushViewController:vc animated:YES];
    }else if (tag == 1001) {
        BFFeedbackController *vc = [[BFFeedbackController alloc]init];
        [self.bf_viewController.navigationController pushViewController:vc animated:YES];
    }else if (tag == 1000) {
        NSURL *url = [NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id1603754521"];
        [[UIApplication sharedApplication]openURL:url options:@{UIApplicationOpenURLOptionsSourceApplicationKey:@YES} completionHandler:^(BOOL success) {

        }];
    }
}


@end


@interface BFProfileItemView()

@property(nonatomic,strong) UIImageView *indicator;

@end
@implementation BFProfileItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.icon = [[UIImageView alloc]init];
        [self addSubview:self.icon];
        
        self.titleL = [[UILabel alloc]init];
        self.titleL.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
        self.titleL.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.titleL];
        
        self.indicator = [[UIImageView alloc]init];
        self.indicator.image = [UIImage imageNamed:@"disclosure_indicator"];
        [self addSubview:self.indicator];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.icon.frame = CGRectMake(15, self.height * 0.5 - 12.5, 25, 25);
    self.titleL.frame = CGRectMake(self.icon.maxX + 15, self.height * 0.5 - 10, 200, 20);
    self.indicator.frame = CGRectMake(self.width - 15 - 15, self.height * 0.5 - 7.5, 15, 15);
}

@end
