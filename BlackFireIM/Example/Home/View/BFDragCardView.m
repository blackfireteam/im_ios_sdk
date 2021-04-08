//
//  BFDragCardView.m
//  BlackFireIM
//
//  Created by benny wang on 2021/4/8.
//

#import "BFDragCardView.h"

@interface BFDragCardView()

@property (nonatomic,strong) UIImageView *like;

@property (nonatomic,strong) UIImageView *dislike;

@end
@implementation BFDragCardView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUp];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setUp];
}

- (void)setUp
{
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor cyanColor];
}

- (void)setConfig:(BFDragConfig *)config
{
    _config = config;
    self.layer.cornerRadius = config.cardCornerRadius;
    self.layer.borderWidth = config.cardCornerBorderWidth;
    self.layer.borderColor = config.cardBordColor.CGColor;
    self.layer.masksToBounds = YES;
}

- (void)dragCardViewLayoutSubviews
{
    //TO DO
}


- (void)startAnimatingForDirection:(ContainerDragDirection)direction
{
    //TO DO
}

@end
