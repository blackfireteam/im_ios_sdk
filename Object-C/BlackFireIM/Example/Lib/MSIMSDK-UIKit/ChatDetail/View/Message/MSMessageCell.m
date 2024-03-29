//
//  MSMessageCell.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/4.
//

#import "MSMessageCell.h"
#import <SDWebImage.h>
#import "MSIMSDK-UIKit.h"
#import <MSIMSDK/MSIMSDK.h>


@interface MSMessageCell()

@property(nonatomic,strong) MSMessageCellData *messageData;

@end
@implementation MSMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        self.backgroundColor = [UIColor clearColor];
        //head
        _avatarView = [[UIImageView alloc] init];
        _avatarView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_avatarView];
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelectMessageAvatar:)];
        [_avatarView addGestureRecognizer:tap1];
        [_avatarView setUserInteractionEnabled:YES];

        //nameLabel
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:13];
        _nameLabel.textColor = [UIColor d_systemGrayColor];
        [self.contentView addSubview:_nameLabel];

        //container
        _container = [[UIView alloc] init];
        _container.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelectMessage:)];
        [_container addGestureRecognizer:tap];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
        [_container addGestureRecognizer:longPress];
        [self.contentView addSubview:_container];
        
        //indicator
        _indicator = [[UIActivityIndicatorView alloc] init];
        _indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self.contentView addSubview:_indicator];
        
        //error
        _retryView = [[UIImageView alloc] init];
        _retryView.userInteractionEnabled = YES;
        UITapGestureRecognizer *resendTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onRetryMessage:)];
        [_retryView addGestureRecognizer:resendTap];
        [self.contentView addSubview:_retryView];
        
        _readReceiptLabel = [[UILabel alloc] init];
        _readReceiptLabel.hidden = YES;
        _readReceiptLabel.font = [UIFont systemFontOfSize:12];
        _readReceiptLabel.textColor = [UIColor d_systemGrayColor];
        _readReceiptLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_readReceiptLabel];
        
        _snapBg = [[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        _snapBg.layer.cornerRadius = 5;
        _snapBg.layer.masksToBounds = YES;
        [self.container addSubview:_snapBg];
        
        _snapIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:TUIKitResource(@"snap_icon")]];
        [self.container addSubview:_snapIcon];
        
        _countDownL = [[UILabel alloc]init];
        _countDownL.textColor = [UIColor whiteColor];
        _countDownL.font = [UIFont systemFontOfSize:12];
        _countDownL.textAlignment = NSTextAlignmentCenter;
        _countDownL.backgroundColor = [UIColor redColor];
        _countDownL.layer.cornerRadius = 10;
        _countDownL.layer.masksToBounds = YES;
        [self.contentView addSubview:_countDownL];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)fillWithData:(MSMessageCellData *)data
{
    self.messageData = data;
    self.avatarView.image = data.defaultAvatar;
    NSString *fromUid = data.message.fromUid;
    if (fromUid) {
        MSProfileInfo *profile = [[MSProfileProvider provider]providerProfileFromLocal:fromUid];
        [self.avatarView sd_setImageWithURL:[NSURL URLWithString:profile.avatar] placeholderImage:data.defaultAvatar];
        self.nameLabel.text = [NSString stringWithFormat:@"%@",profile.nick_name];
//        self.nameLabel.text = [NSString stringWithFormat:@"%@--%zd",profile.nick_name,data.elem.msg_id];
    }
    if (!data.message.isSnapChat || data.message.isSelf || data.snapCount > 0 || data.message.type == MSIM_MSG_TYPE_VOICE) {
        self.snapBg.hidden = YES;
        self.snapIcon.hidden = !data.message.isSnapChat;
    }else {
        self.snapBg.hidden = NO;
        self.snapIcon.hidden = NO;
    }
    self.countDownL.hidden = data.snapCount <= 0;
    self.countDownL.text = [NSString stringWithFormat:@"%zd",data.snapCount];
    
    self.avatarView.layer.masksToBounds = YES;
    self.avatarView.layer.cornerRadius = 40 * 0.5;
    
    if(data.message.sendStatus == MSIM_MSG_STATUS_SEND_FAIL){
        [_indicator stopAnimating];
        self.retryView.image = [UIImage imageNamed:TUIKitResource(@"msg_error")];
    }else if (data.message.sendStatus == MSIM_MSG_STATUS_SENDING) {
        [_indicator startAnimating];
        self.retryView.image = nil;
    }else {
        [_indicator stopAnimating];
        self.retryView.image = nil;
    }
    if (self.messageData.direction == MsgDirectionOutgoing) {
        self.readReceiptLabel.hidden = NO;
        if (self.messageData.message.sendStatus == MSIM_MSG_STATUS_SEND_SUCC) {
            if (self.messageData.message.chatType == MSIM_CHAT_TYPE_CHATROOM) {
                self.readReceiptLabel.text = TUILocalizableString(Deliveried);
            }else {
                self.readReceiptLabel.text = (self.messageData.message.readStatus == MSIM_MSG_STATUS_UNREAD || self.messageData.message.isSnapChat) ? TUILocalizableString(Deliveried) : TUILocalizableString(Read);
            }
        }else if (self.messageData.message.sendStatus == MSIM_MSG_STATUS_SENDING) {
            self.readReceiptLabel.text = TUILocalizableString(Sending);
        }else {
            self.readReceiptLabel.text = TUILocalizableString(NotDeliveried);
        }
    }else {
        self.readReceiptLabel.hidden = YES;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize nameSize = [self.nameLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    
    if (self.messageData.direction == MsgDirectionIncoming) {
        self.avatarView.x = 8;
        self.avatarView.y = 5;
        self.avatarView.width = 40;
        self.avatarView.height = 40;
        
        if (self.messageData.showName) {
            self.nameLabel.frame = CGRectMake(self.avatarView.maxX+5, self.avatarView.y, nameSize.width, 20);
            self.nameLabel.hidden = NO;
        } else {
            self.nameLabel.hidden = YES;
            self.nameLabel.frame = CGRectMake(self.avatarView.maxX+5, self.avatarView.y, nameSize.width, 0);
        }
        
        CGSize csize = [self.messageData contentSize];
        self.container.x = self.nameLabel.x;
        self.container.y = self.nameLabel.height + 5 + self.avatarView.y;
        self.container.width = csize.width;
        self.container.height = csize.height;
        
        [self.indicator sizeToFit];
        self.indicator.frame = CGRectZero;
        self.retryView.frame = self.indicator.frame;
        
    } else {
        self.avatarView.width = 40;
        self.avatarView.height = 40;
        self.avatarView.y = 5;
        self.avatarView.maxX = self.contentView.width-8;
        
        if (self.messageData.showName) {
            self.nameLabel.frame = CGRectMake(self.avatarView.x-5-nameSize.width, self.avatarView.y, nameSize.width, 20);
            self.nameLabel.hidden = NO;
        } else {
            self.nameLabel.hidden = YES;
            self.nameLabel.height = 0;
            self.nameLabel.frame = CGRectMake(self.avatarView.x-5-nameSize.width, self.avatarView.y, nameSize.width, 0);
        }
        
        CGSize csize = [self.messageData contentSize];
        self.container.width = csize.width;
        self.container.height = csize.height;
        self.container.y = self.nameLabel.height + 5 + self.avatarView.y;
        self.container.maxX = self.nameLabel.maxX;
        [self.indicator sizeToFit];
        self.indicator.centerY = self.container.centerY;
        self.indicator.x = self.container.x - 8 - self.indicator.width;
        self.retryView.frame = self.indicator.frame;
        
        self.readReceiptLabel.frame = CGRectMake(self.container.maxX-80, self.container.maxY+3, 80, 12);
    }
    [self.container bringSubviewToFront:self.snapBg];
    [self.container bringSubviewToFront:self.snapIcon];
    self.snapBg.frame = self.container.bounds;
    if (self.messageData.direction == MsgDirectionIncoming) {
        self.snapIcon.frame = CGRectMake(self.container.width - 12, - 8, 20, 20);
    }else {
        self.snapIcon.frame = CGRectMake(- 8, - 8, 20, 20);
    }
    self.countDownL.frame = CGRectMake(self.container.maxX + 8, self.container.centerY - 10, 20, 20);
}


- (void)onLongPress:(UIGestureRecognizer *)recognizer
{
    if([recognizer isKindOfClass:[UILongPressGestureRecognizer class]] &&
       recognizer.state == UIGestureRecognizerStateBegan){
        if(_delegate && [_delegate respondsToSelector:@selector(onLongPressMessage:)]){
            [_delegate onLongPressMessage:self];
        }
    }
}

- (void)onRetryMessage:(UIGestureRecognizer *)recognizer
{
    if (_messageData.message.sendStatus == MSIM_MSG_STATUS_SEND_FAIL)
        if (_delegate && [_delegate respondsToSelector:@selector(onRetryMessage:)]) {
            [_delegate onRetryMessage:self];
        }
}


- (void)onSelectMessage:(UIGestureRecognizer *)recognizer
{
    if(_delegate && [_delegate respondsToSelector:@selector(onSelectMessage:)]){
        [_delegate onSelectMessage:self];
    }
}

- (void)onSelectMessageAvatar:(UIGestureRecognizer *)recognizer
{
    if(_delegate && [_delegate respondsToSelector:@selector(onSelectMessageAvatar:)]){
        [_delegate onSelectMessageAvatar:self];
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    //今后任何关于复用产生的 UI 问题，都可以在此尝试编码解决。
}

@end
