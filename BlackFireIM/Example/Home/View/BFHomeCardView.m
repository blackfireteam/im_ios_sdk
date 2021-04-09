//
//  BFHomeCardView.m
//  BlackFireIM
//
//  Created by benny wang on 2021/4/8.
//

#import "BFHomeCardView.h"
#import <SDWebImage.h>


@interface BFHomeCardView()

@property (nonatomic,strong) UIImageView *imageView;

@property (nonatomic,strong) UILabel *title;

// dislike
@property (nonatomic,strong) UIImageView *dislike;
// like
@property (nonatomic,strong) UIImageView *like;

@end
@implementation BFHomeCardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    
    return self;
}

- (void)setUp
{
    self.backgroundColor = [UIColor whiteColor];
    self.imageView = [[UIImageView alloc]init];
    self.imageView.layer.cornerRadius = 4.0f;
    self.imageView.layer.masksToBounds = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.imageView];
    
    self.title = [[UILabel alloc]init];
    self.title.textColor = [UIColor blackColor];
    self.title.backgroundColor = [UIColor whiteColor];
    self.title.textAlignment = NSTextAlignmentCenter;
    self.title.font = [UIFont boldSystemFontOfSize:18.0f];
    [self addSubview:self.title];
    
    self.dislike = [[UIImageView alloc]init];
    self.dislike.image = [UIImage imageNamed:@"finder_dislike_btn"];
    self.dislike.alpha = 0.0f;
    [self addSubview:self.dislike];
    
    self.like = [[UIImageView alloc]init];
    self.like.image = [UIImage imageNamed:@"finder_like_btn"];
    self.like.alpha = 0.0f;
    [self addSubview:self.like];
    
}

- (void)dragCardViewLayoutSubviews
{
    self.imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-30);
    self.title.frame = CGRectMake(0,self.imageView.frame.size.height, self.frame.size.width, 30);
    self.like.frame = CGRectMake(16, 16, 75, 75);
    self.dislike.frame = CGRectMake(self.frame.size.width-21-75, 16, 75, 75);
}

- (void)configItem:(MSProfileInfo *)info
{
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:info.pic]];
    self.title.text = info.nick_name;
}

- (void)setAnimationwithDriection:(ContainerDragDirection)direction
{
    if (direction == ContainerDragLeft) {

        self.like.alpha = 0.0f;
        [UIView animateWithDuration:0.2f animations:^{
            if (self.dislike) {
                self.dislike.alpha = 1.0f;
                self.dislike.transform = CGAffineTransformMakeRotation(45*M_PI / 180.0);
            }
        }];
    }else if(direction == ContainerDragRight){

        self.dislike.alpha = 0.0f;
        [UIView animateWithDuration:0.2f animations:^{
            if (self.like) {
                self.like.alpha = 1.0f;
                self.like.transform = CGAffineTransformMakeRotation(-45*M_PI / 180.0);
            }
        }];
    }else{

        self.like.alpha = 0.0f;
        self.dislike.alpha = 0.0f;
        [UIView animateWithDuration:0.2 animations:^{
            if (self.like) {
                self.like.transform = CGAffineTransformMakeRotation(45*M_PI / 180.0);
            }
            if (self.dislike) {
                self.dislike.transform = CGAffineTransformMakeRotation(-45*M_PI / 180.0);
            }
        }];
    }
}

@end
