//
//  MSUIConversationCell.m
//  BlackFireIM
//
//  Created by benny wang on 2021/5/28.
//

#import "MSUIConversationCell.h"
#import "MSIMSDK-UIKit.h"
#import <SDWebImage.h>


@implementation MSUIConversationCell

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
        
        _unReadView = [[MSUnreadView alloc]init];
        [self.contentView addSubview:_unReadView];
        
        _subTitleLabel = [[UILabel alloc]init];
        _subTitleLabel.font = [UIFont systemFontOfSize:13];
        _subTitleLabel.textColor = [UIColor d_systemGrayColor];
        [self.contentView addSubview:_subTitleLabel];
        
        _genderIcon = [[UIImageView alloc]init];
        [self.contentView addSubview:_genderIcon];
        
        [self setSeparatorInset:UIEdgeInsetsMake(0, 97, 0, 0)];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        self.headImageView.layer.cornerRadius = 34;
        self.headImageView.layer.masksToBounds = YES;
    }
    return self;
}

- (void)configWithData:(MSUIConversationCellData *)convData
{
    _convData = convData;
    self.titleLabel.text = convData.title;
    self.timeLabel.text = [convData.time ms_messageString];
    self.subTitleLabel.attributedText = convData.subTitle;
    [self.unReadView setNum:convData.conv.unread_count];
    self.genderIcon.image = convData.conv.userInfo.gender == 1 ? [UIImage bf_imageNamed:@"male"] : [UIImage bf_imageNamed:@"female"];
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:XMNoNilString(convData.conv.userInfo.avatar)] placeholderImage:convData.avatarImage];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.headImageView.frame = CGRectMake(15, 17, 68, 68);
    CGSize titleSize = [self.titleLabel sizeThatFits:CGSizeZero];
    self.titleLabel.frame = CGRectMake(self.headImageView.maxX+14, 31, MIN(titleSize.width, 150), 22);
    CGSize timeSize = [self.timeLabel sizeThatFits:CGSizeMake(200, 20)];
    self.timeLabel.frame = CGRectMake(self.contentView.width-15-timeSize.width, self.titleLabel.centerY-timeSize.height*0.5, timeSize.width, timeSize.height);
    self.subTitleLabel.frame = CGRectMake(self.titleLabel.x, self.titleLabel.maxY+5, 250, 16);
    self.unReadView.maxX = self.width-15;
    self.unReadView.y = self.subTitleLabel.y;
    
    self.genderIcon.frame = CGRectMake(self.titleLabel.maxX+5, self.titleLabel.centerY-10, 20, 20);
}

@end
