//
//  BFGroupMemberCell.m
//  BlackFireIM
//
//  Created by benny wang on 2021/11/8.
//

#import "BFGroupMemberCell.h"
#import <SDWebImage.h>
#import "MSIMSDK-UIKit.h"

@implementation BFGroupMemberCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor d_colorWithColorLight:TCell_Nomal dark:TCell_Nomal_Dark];
        self.layer.cornerRadius = 6;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor d_colorWithColorLight:TCell_separatorColor dark:TCell_separatorColor_Dark].CGColor;
        
        //head
        _avatarView = [[UIImageView alloc] init];
        _avatarView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarView.clipsToBounds = YES;
        [self.contentView addSubview:_avatarView];

        //nameLabel
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont boldSystemFontOfSize:16];
        _nameLabel.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_nameLabel];
        
        _idL = [[UILabel alloc]init];
        _idL.textAlignment = NSTextAlignmentCenter;
        _idL.font = [UIFont systemFontOfSize:12];
        _idL.textColor = [UIColor whiteColor];
        _idL.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_idL];
        
        _muteL = [[UILabel alloc]init];
        _muteL.text = @"禁言";
        _muteL.textAlignment = NSTextAlignmentCenter;
        _muteL.font = [UIFont systemFontOfSize:12];
        _muteL.textColor = [UIColor whiteColor];
        _muteL.backgroundColor = [UIColor blackColor];
        [self.contentView addSubview:_muteL];
    }
    return self;
}

- (void)setInfo:(MSGroupMemberItem *)info
{
    _info = info;
    if (info == nil) return;
    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:info.profile.avatar]];
    if ([info.uid isEqualToString:[MSIMTools sharedInstance].user_id]) {
        self.nameLabel.text = @"Me";
    }else {
        self.nameLabel.text = info.profile.nick_name;
    }
    if (info.role == 0) {
        self.idL.text = @"用户";
    }else if (info.role == 1) {
        self.idL.text = @"临时管理员";
    }else {
        self.idL.text = @"管理员";
    }
    self.muteL.hidden = !info.is_mute;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.avatarView.frame = CGRectMake(0, 0, self.width, self.height-40);
    self.nameLabel.frame = CGRectMake(0, self.height-40, self.width, 40);
    self.idL.frame = CGRectMake(3, 3, 80, 30);
    self.muteL.frame = CGRectMake(self.width - 3 - 60, 3, 60, 30);
}

@end
