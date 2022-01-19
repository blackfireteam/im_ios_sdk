//
//  BFProfileButton.m
//  BlackFireIM
//
//  Created by benny wang on 2021/12/23.
//

#import "BFProfileButton.h"
#import "MSIMSDK-UIKit.h"


@interface BFProfileButton()

@property(nonatomic,strong) UILabel *numL;

@property(nonatomic,strong) UILabel *titleL;

@end
@implementation BFProfileButton

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.numL = [[UILabel alloc]init];
        self.numL.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
        self.numL.font = [UIFont boldSystemFontOfSize:16];
        self.numL.textAlignment = NSTextAlignmentCenter;
        self.numL.text = @"0";
        [self addSubview:self.numL];
        
        self.titleL = [[UILabel alloc]init];
        self.titleL.textColor = [UIColor lightGrayColor];
        self.titleL.font = [UIFont boldSystemFontOfSize:12];
        self.titleL.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.titleL];
    }
    return self;
}

- (void)updateNum:(NSInteger)num title:(NSString *)title
{
    self.numL.text = [NSString stringWithFormat:@"%zd",num];
    self.titleL.text = title;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.numL.frame  = CGRectMake(0, 0, self.width, 20);
    self.titleL.frame = CGRectMake(0, self.height - 20, self.width, 20);
}

@end
