//
//  BFSparkLoadingView.m
//  BlackFireIM
//
//  Created by benny wang on 2021/4/20.
//

#import "BFSparkLoadingView.h"
#import "BFHeader.h"

@interface BFSparkLoadingView()

@property(nonatomic,strong) UIImageView *bgImg;
@property(nonatomic,strong) UIImageView *topImg;
@property(nonatomic,strong) UIImageView *maskImg;
@property(nonatomic,strong) UIImageView *headImg;

@end
@implementation BFSparkLoadingView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        self.bgImg = [UIImageView new];
        self.bgImg.image = [UIImage imageNamed:@"loadingbg"];
        [self addSubview:self.bgImg];
        
        self.topImg = [UIImageView new];
        self.topImg.image = [UIImage imageNamed:@"loadingtop"];
        [self addSubview:self.topImg];
        
        self.maskImg = [UIImageView new];
        self.maskImg.image = [UIImage imageNamed:@"loadingheadmask"];
        [self addSubview:self.maskImg];
        
        self.headImg = [UIImageView new];
        self.headImg.image = [UIImage imageNamed:@"loadinghead"];
        [self addSubview:self.headImg];
        self.alpha = 0;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.bgImg.frame = CGRectMake(0, 0, Screen_Width, Screen_Width);
    self.bgImg.center = self.center;
    self.topImg.frame = CGRectMake(0, 0, Screen_Width, Screen_Width);
    self.topImg.center = self.center;
    self.maskImg.frame = CGRectMake(0, 0, 97, 97);
    self.maskImg.center = self.center;
    self.headImg.frame = CGRectMake(0, 0, 41, 55);
    self.headImg.center = self.center;
}

- (void)beginAnimating
{
    self.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1;
        
        } completion:^(BOOL finished) {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            animation.fromValue = [NSNumber numberWithFloat:0.f];
            animation.toValue = [NSNumber numberWithFloat: M_PI *2];
            animation.duration = 3;
            animation.autoreverses = NO;
            animation.fillMode = kCAFillModeForwards;
            animation.repeatCount = MAXFLOAT;
            animation.removedOnCompletion = NO;
            [self.topImg.layer addAnimation:animation forKey:nil];
        }];
}

- (void)stopAnimating
{
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self.topImg.layer removeAllAnimations];
    }];
}

@end
