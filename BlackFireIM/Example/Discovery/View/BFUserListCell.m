//
//  BFUserListCell.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/24.
//

#import "BFUserListCell.h"
#import <SDWebImage.h>
#import "BFHeader.h"

@implementation BFUserListCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor d_colorWithColorLight:TCell_Nomal dark:TCell_Nomal_Dark];
        self.layer.cornerRadius = 6;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 1;
        self.layer.borderColor = TCell_separatorColor.CGColor;
        
        //head
        _avatarView = [[UIImageView alloc] init];
        _avatarView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarView.clipsToBounds = YES;
        [self.contentView addSubview:_avatarView];

        //nameLabel
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont boldSystemFontOfSize:16];
        _nameLabel.textColor = [UIColor darkTextColor];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_nameLabel];
        
        _liveIcon = [[UIImageView alloc]init];
        _liveIcon.image = [UIImage imageNamed:@"user_living"];
        [self.contentView addSubview:_liveIcon];
    }
    return self;
}

- (void)configWithInfo:(MSProfileInfo *)info
{
    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:info.avatar]];
    self.nameLabel.text = info.nick_name;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.avatarView.frame = CGRectMake(0, 0, self.width, self.height-40);
    self.nameLabel.frame = CGRectMake(0, self.height-40, self.width, 40);
    self.liveIcon.frame = CGRectMake(3, 3, 14, 14);
}

@end
