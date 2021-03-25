//
//  BFUserListCell.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/24.
//

#import "BFUserListCell.h"
#import "UIColor+BFDarkMode.h"
#import <SDWebImage.h>
#import "UIView+Frame.h"


@implementation BFUserListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        self.backgroundColor = [UIColor clearColor];
        //head
        _avatarView = [[UIImageView alloc] init];
        _avatarView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_avatarView];

        //nameLabel
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:13];
        _nameLabel.textColor = [UIColor d_systemGrayColor];
        [self.contentView addSubview:_nameLabel];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
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
    self.avatarView.frame = CGRectMake(10, self.height*0.5-15, 30, 30);
    self.nameLabel.frame = CGRectMake(self.avatarView.maxX+10, self.avatarView.centerY-10, 200, 20);
}

@end
