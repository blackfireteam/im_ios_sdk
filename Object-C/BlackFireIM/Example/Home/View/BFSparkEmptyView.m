//
//  BFSparkEmptyView.m
//  BlackFireIM
//
//  Created by benny wang on 2021/4/20.
//

#import "BFSparkEmptyView.h"
#import "MSIMSDK-UIKit.h"


@implementation BFSparkEmptyView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.noDataImg = [UIImageView new];
        self.noDataImg.image = [UIImage imageNamed:@"meet_nodata"];
        self.noDataImg.frame = CGRectMake((Screen_Width - 148)*0.5, 0, 148, 148);
        [self addSubview:self.noDataImg];
        
        self.titleLbl = [UILabel new];
        self.titleLbl.textColor = RGB(144, 144, 144);
        self.titleLbl.textAlignment = NSTextAlignmentCenter;
        self.titleLbl.font = [UIFont systemFontOfSize:14];
        self.titleLbl.text = TUILocalizableString(TUIKitNoMoreData);
        self.titleLbl.frame = CGRectMake(0, self.noDataImg.maxY + 10, Screen_Width, 20);
        [self addSubview:self.titleLbl];
        
        
        self.retryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.retryBtn.backgroundColor = RGB(245, 245, 245);
        [self.retryBtn setTitle:TUILocalizableString(TUIKitRefresh) forState:UIControlStateNormal];
        [self.retryBtn setTitleColor:RGB(51, 51, 51) forState:UIControlStateNormal];
        self.retryBtn.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        self.retryBtn.frame = CGRectMake((Screen_Width - 203)*0.5, self.titleLbl.maxY + 16, 203, 44);
        self.retryBtn.layer.cornerRadius = 8;
        self.retryBtn.layer.masksToBounds = YES;
        [self addSubview:self.retryBtn];
    }
    return self;
}

@end
