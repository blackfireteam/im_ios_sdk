//
//  BFConversationListCell.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/18.
//

#import "BFConversationListCell.h"
#import "UIColor+BFDarkMode.h"
#import "BFHeader.h"
#import "NSDate+MSKit.h"
#import <SDWebImage.h>
#import "UIView+Frame.h"


@interface BFConversationListCell()

@property(nonatomic,strong) BFConversationCellData *convData;

@end
@implementation BFConversationListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor d_colorWithColorLight:TCell_Nomal dark:TCell_Nomal_Dark];
        
        _headImageView = [[UIImageView alloc]init];
        _headImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_headImageView];
        
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = [UIColor d_systemGrayColor];
        [self.contentView addSubview:_timeLabel];
        
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:17];
        _titleLabel.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
        [self.contentView addSubview:_titleLabel];
        
        _goldIcon = [[UIImageView alloc]init];
        _goldIcon.image = [UIImage imageNamed:@"gold_verify"];
        [self.contentView addSubview:_goldIcon];
        
        _unReadView = [[BFUnreadView alloc]init];
        [self.contentView addSubview:_unReadView];
        
        _subTitleLabel = [[UILabel alloc]init];
        _subTitleLabel.font = [UIFont systemFontOfSize:13];
        _subTitleLabel.textColor = [UIColor d_systemGrayColor];
        [self.contentView addSubview:_subTitleLabel];
        
        _matchIcon = [[UIImageView alloc]init];
        _matchIcon.image = [UIImage imageNamed:@"ic_match_message"];
        [self.contentView addSubview:_matchIcon];
        
        _verifyIcon = [[UIImageView alloc]init];
        _verifyIcon.image = [UIImage imageNamed:@"photo_verify"];
        [self.contentView addSubview:_verifyIcon];
        
        [self setSeparatorInset:UIEdgeInsetsMake(0, 97, 0, 0)];
        [self setSelectionStyle:UITableViewCellSelectionStyleDefault];
        
        self.headImageView.layer.cornerRadius = 34;
        self.headImageView.layer.masksToBounds = YES;
    }
    return self;
}

- (void)configWithData:(BFConversationCellData *)convData
{
    _convData = convData;
    self.titleLabel.text = convData.title;
    self.timeLabel.text = [convData.time ms_messageString];
    self.subTitleLabel.attributedText = convData.subTitle;
    [self.unReadView setNum:convData.conv.unread_count];
    self.goldIcon.hidden = !convData.conv.userInfo.gold;
    self.matchIcon.hidden = !convData.conv.ext.matched;;
    self.verifyIcon.hidden = !convData.conv.userInfo.verified;
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:XMNoNilString(convData.conv.userInfo.avatar)] placeholderImage:convData.avatarImage];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.headImageView.frame = CGRectMake(15, 17, 68, 68);
    CGSize titleSize = [self.titleLabel sizeThatFits:CGSizeMake(200, 30)];
    self.titleLabel.frame = CGRectMake(self.headImageView.maxX+14, 31, titleSize.width, 22);
    CGSize timeSize = [self.timeLabel sizeThatFits:CGSizeMake(200, 20)];
    self.timeLabel.frame = CGRectMake(self.contentView.width-15-timeSize.width, self.titleLabel.centerY-timeSize.height*0.5, timeSize.width, timeSize.height);
    self.subTitleLabel.frame = CGRectMake(self.titleLabel.x, self.titleLabel.maxY+5, 250, 16);
    self.unReadView.maxX = self.width-15;
    self.unReadView.y = self.subTitleLabel.y;
    
    self.matchIcon.size = CGSizeMake(18, 18);
    self.matchIcon.center = CGPointMake(self.headImageView.maxX-8, self.headImageView.maxY-8);
    if (self.verifyIcon.isHidden) {
        self.goldIcon.frame = CGRectMake(self.titleLabel.maxX+8, self.titleLabel.centerY-10, 20, 20);
    }else {
        self.verifyIcon.frame = CGRectMake(self.titleLabel.maxX+8, self.titleLabel.centerY-10, 20, 20);
        self.goldIcon.frame = CGRectMake(self.verifyIcon.maxX+5, self.titleLabel.centerY-10, 20, 20);
    }
}

@end
