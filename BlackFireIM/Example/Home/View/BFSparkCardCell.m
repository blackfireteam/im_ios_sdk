//
//  BFSparkCardCell.m
//  BlackFireIM
//
//  Created by benny wang on 2021/4/13.
//

#import "BFSparkCardCell.h"
#import "MSIMSDK-UIKit.h"
#import <MSIMSDK/MSIMSDK.h>
#import <SDWebImage.h>


@interface BFSparkCardCell()

@property(nonatomic,strong) CAGradientLayer *gradientLayer;

@property(nonatomic,strong) MSProfileInfo *user;

@end
@implementation BFSparkCardCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.imageView = [[UIImageView alloc]init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.userInteractionEnabled = YES;
        [self addSubview:self.imageView];
        
        self.gradientLayer = [CAGradientLayer layer];
        self.gradientLayer.colors = @[(id)RGBA(0, 0, 0, 0.0).CGColor,(id)RGBA(0, 0, 0, 0.8).CGColor];
        self.gradientLayer.startPoint = CGPointMake(0, 0);
        self.gradientLayer.endPoint = CGPointMake(0, 1);
        [self.imageView.layer addSublayer:self.gradientLayer];
        
        self.title = [[UILabel alloc]init];
        self.title.textColor = [UIColor whiteColor];
        self.title.font = [UIFont boldSystemFontOfSize:18.0f];
        [self.imageView addSubview:self.title];
        
        self.dislike = [[UIImageView alloc]init];
        self.dislike.image = [UIImage imageNamed:@"finder_dislike_btn"];
        self.dislike.alpha = 0.0f;
        [self.imageView addSubview:self.dislike];
        
        self.like = [[UIImageView alloc]init];
        self.like.image = [UIImage imageNamed:@"finder_like_btn"];
        self.like.alpha = 0.0f;
        [self.imageView addSubview:self.like];

        self.winkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.winkBtn setImage:[UIImage imageNamed:@"spark_wink"] forState:UIControlStateNormal];
        [self.winkBtn setImage:[UIImage imageNamed:@"spark_wink_sel"] forState:UIControlStateSelected];
        [self.winkBtn setImage:[UIImage imageNamed:@"spark_wink_sel"] forState:UIControlStateSelected | UIControlStateHighlighted];
        [self.winkBtn addTarget:self action:@selector(winkBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
        [self.imageView addSubview:self.winkBtn];
        
        self.chatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.chatBtn setImage:[UIImage imageNamed:@"spark_chat"] forState:UIControlStateNormal];
        [self.chatBtn addTarget:self action:@selector(chatBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
        [self.imageView addSubview:self.chatBtn];
        
        self.layer.cornerRadius = 10;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.layer.borderWidth = 1;
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)configItem:(MSProfileInfo *)info
{
    _user = info;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:info.pic] placeholderImage:nil options:SDWebImageRetryFailed | SDWebImageAllowInvalidSSLCertificates];
    self.title.text = info.nick_name;
    self.winkBtn.selected = NO;
}

- (void)winkBtnDidClick
{
    if ([self.delegate respondsToSelector:@selector(winkBtnDidClick:)]) {
        [self.delegate winkBtnDidClick:self];
    }
    [UIDevice impactFeedback];
}

- (void)chatBtnDidClick
{
    if ([self.delegate respondsToSelector:@selector(chatBtnDidClick:)]) {
        [self.delegate chatBtnDidClick:self];
    }
    [UIDevice impactFeedback];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
    self.gradientLayer.frame = CGRectMake(0, self.imageView.height-250, self.imageView.width, 250);
    self.title.frame = CGRectMake(20,self.height-120, 200, 30);
    self.like.frame = CGRectMake(16, 16, 75, 75);
    self.dislike.frame = CGRectMake(self.frame.size.width-21-75, 16, 75, 75);
    self.winkBtn.frame = CGRectMake(20, self.title.maxY+15, 50, 50);
    self.chatBtn.frame = CGRectMake(self.winkBtn.maxX+15, self.winkBtn.y, self.winkBtn.width, self.winkBtn.height);
}

@end
