//
//  BFProfileHeaderView.m
//  BlackFireIM
//
//  Created by benny wang on 2021/4/20.
//

#import "BFProfileHeaderView.h"
#import "MSIMSDK-UIKit.h"


@implementation BFProfileHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.avatarIcon = [[UIImageView alloc]init];
        self.avatarIcon.contentMode = UIViewContentModeScaleAspectFill;
        self.avatarIcon.layer.cornerRadius = 57;
        self.avatarIcon.layer.masksToBounds = YES;
        self.avatarIcon.frame = CGRectMake(Screen_Width*0.5-57, 30, 114, 114);
        self.avatarIcon.backgroundColor = [UIColor lightGrayColor];
        self.avatarIcon.userInteractionEnabled = YES;
        [self addSubview:self.avatarIcon];
        
        self.editIcon = [[UIImageView alloc]init];
        self.editIcon.image = [UIImage imageNamed:@"edit_avatar"];
        self.editIcon.frame = CGRectMake(self.avatarIcon.maxX-45, self.avatarIcon.maxY-18, 25, 25);
        [self addSubview:self.editIcon];
    }
    return self;
}



@end
