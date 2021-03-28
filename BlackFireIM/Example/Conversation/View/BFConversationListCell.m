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
        [self addSubview:_headImageView];
        
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = [UIColor d_systemGrayColor];
        [self addSubview:_timeLabel];
        
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
        [self addSubview:_titleLabel];
        
        _unReadView = [[BFUnreadView alloc]init];
        [self addSubview:_unReadView];
        
        _subTitleLabel = [[UILabel alloc]init];
        _subTitleLabel.font = [UIFont systemFontOfSize:14];
        _subTitleLabel.textColor = [UIColor d_systemGrayColor];
        [self addSubview:_subTitleLabel];
        
        [self setSeparatorInset:UIEdgeInsetsMake(0, 12, 0, 0)];
        [self setSelectionStyle:UITableViewCellSelectionStyleDefault];
        
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
    
//    self.headImageView.layer.masksToBounds = YES;
//    self.headImageView.layer.cornerRadius = self.headImageView.frame.size.height/2;
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:XMNoNilString(convData.conv.userInfo.avatar)]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat height = self.frame.size.height;
    CGFloat imageHeight = height - 2*12;
    self.headImageView.frame = CGRectMake(15, 12, imageHeight, imageHeight);
    CGSize timeSize = [self.timeLabel sizeThatFits:CGSizeMake(200, 20)];
    self.timeLabel.frame = CGRectMake(self.frame.size.width-15-timeSize.width, 8, timeSize.width, timeSize.height);
    CGSize titleSize = [self.titleLabel sizeThatFits:CGSizeMake(200, 30)];
    self.titleLabel.frame = CGRectMake(CGRectGetMaxX(self.headImageView.frame)+10, CGRectGetMinY(self.headImageView.frame), titleSize.width, titleSize.height);
    self.unReadView.maxX = self.width-15;
    self.unReadView.y = height*0.5;
    self.subTitleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x, CGRectGetMaxY(self.headImageView.frame)-20, 250, 20);
}

@end
