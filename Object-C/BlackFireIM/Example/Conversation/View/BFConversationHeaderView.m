//
//  BFConversationHeaderView.m
//  BlackFireIM
//
//  Created by benny wang on 2021/12/27.
//

#import "BFConversationHeaderView.h"
#import "MSHeader.h"
#import <MSIMSDK/MSIMSDK.h>
#import "MSIMSDK-UIKit.h"

@interface BFConversationHeaderView()

@property(nonatomic,strong) UIImageView *icon;

@property(nonatomic,strong) UILabel *titleL;

@property(nonatomic,strong) UIView *redDot;

@property(nonatomic,strong) UILabel *subTitleLabel;

@property(nonatomic,strong) UILabel *timeLabel;

@end
@implementation BFConversationHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor d_colorWithColorLight:TCell_Nomal dark:TCell_Nomal_Dark];
        
        _icon = [[UIImageView alloc]init];
        _icon.contentMode = UIViewContentModeScaleAspectFill;
        _icon.clipsToBounds = YES;
        _icon.image = [UIImage imageNamed:@"chat_btn"];
        [self addSubview:_icon];
        
        _titleL = [[UILabel alloc]init];
        _titleL.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
        _titleL.text = @"聊天室";
        _titleL.font = [UIFont boldSystemFontOfSize:17];
        [self addSubview:_titleL];
        
        _subTitleLabel = [[UILabel alloc]init];
        _subTitleLabel.font = [UIFont systemFontOfSize:13];
        _subTitleLabel.textColor = [UIColor d_systemGrayColor];
        [self addSubview:_subTitleLabel];
        
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = [UIColor d_systemGrayColor];
        [self addSubview:_timeLabel];
        
        _redDot = [[UIView alloc]init];
        _redDot.backgroundColor = [UIColor redColor];
        _redDot.layer.cornerRadius = 4;
        _redDot.layer.masksToBounds = YES;
        [self addSubview:_redDot];
    }
    return self;
}

- (void)reloadData
{
    //模拟会话列表的展示方式
    NSString *roomName = MSChatRoomManager.sharedInstance.chatroomInfo.room_name;
    self.titleL.text = roomName.length == 0 ? @"聊天室" : roomName;
    MSUIConversationCellData *convData = [[MSUIConversationCellData alloc]init];
    MSIMConversation *conv = [[MSIMConversation alloc]init];
    conv.show_msg = MSChatRoomManager.sharedInstance.last_show_msg;
    conv.time = MSChatRoomManager.sharedInstance.last_show_msg.msg_sign;
    convData.conv = conv;
    self.subTitleLabel.attributedText = convData.subTitle;
    self.timeLabel.text = [convData.time ms_messageString];
    self.redDot.hidden = !(MSChatRoomManager.sharedInstance.unreadCount > 0);
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.icon.frame = CGRectMake(15, 17, 68, 68);
    self.titleL.frame = CGRectMake(self.icon.maxX+14, 31, 200, 22);
    CGSize timeSize = [self.timeLabel sizeThatFits:CGSizeMake(200, 20)];
    self.timeLabel.frame = CGRectMake(self.width-15-timeSize.width, self.titleL.centerY-timeSize.height*0.5, timeSize.width, timeSize.height);
    self.subTitleLabel.frame = CGRectMake(self.titleL.x, self.titleL.maxY+5, 250, 16);
    self.redDot.frame = CGRectMake(self.width - 15 - 8, self.subTitleLabel.y, 8, 8);
}

@end
