//
//  BFMessageCell.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/4.
//

#import "BFMessageCell.h"
#import "UIColor+BFDarkMode.h"
#import <SDWebImage.h>
#import "BFHeader.h"
#import "UIView+Frame.h"


@interface BFMessageCell()

@property(nonatomic,strong) BFMessageCellData *messageData;

@end
@implementation BFMessageCell

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
        
        //已读label,由于 indicator 和 error，所以默认隐藏，消息发送成功后进行显示
        _readReceiptLabel = [[UILabel alloc] init];
        _readReceiptLabel.hidden = YES;
        _readReceiptLabel.font = [UIFont systemFontOfSize:12];
        _readReceiptLabel.textColor = [UIColor d_systemGrayColor];
        _readReceiptLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [self.contentView addSubview:_readReceiptLabel];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)fillWithData:(BFMessageCellData *)data
{
    self.messageData = data;
    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:data.avatarUrl] placeholderImage:data.defaultAvatar];
    
    self.avatarView.layer.masksToBounds = YES;
    self.avatarView.layer.cornerRadius = 40 * 0.5;
    
    //set data
    self.nameLabel.text = data.nickName;

    if(data.elem.sendStatus == BFIM_MSG_STATUS_SEND_FAIL){
        [_indicator stopAnimating];
        self.retryView.image = [UIImage imageNamed:TUIKitResource(@"msg_error")];
    }else if (data.elem.sendStatus == BFIM_MSG_STATUS_SENDING) {
        [_indicator startAnimating];
        self.retryView.image = nil;
    }else {
        [_indicator stopAnimating];
        self.retryView.image = nil;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.messageData.showName) {
        _nameLabel.size = CGSizeMake(MAX(1, _nameLabel.width), MAX(20, _nameLabel.height));
        _nameLabel.hidden = NO;
    } else {
        _nameLabel.hidden = YES;
        _nameLabel.height = 0;
    }
    
    if (self.messageData.direction == MsgDirectionIncoming) {
        self.avatarView.x = 8;
        self.avatarView.y = 3;
        self.avatarView.width = 40;
        self.avatarView.height = 40;
        
        self.nameLabel.x = self.avatarView.maxX+5;
        self.nameLabel.y = self.avatarView.y;
        
        CGSize csize = [self.messageData contentSize];
        self.container.x = self.nameLabel.x;
        self.container.y = self.nameLabel.height + 3;
        self.container.width = csize.width;
        self.container.height = csize.height;
        
        [self.indicator sizeToFit];
        self.indicator.frame = CGRectZero;
        self.retryView.frame = self.indicator.frame;
        self.readReceiptLabel.hidden = YES;
    } else {
        self.avatarView.width = 40;
        self.avatarView.height = 40;
        self.avatarView.y = 3;
        self.avatarView.maxX = self.contentView.width-8;
        
        self.nameLabel.maxX = self.avatarView.x-5;
        self.nameLabel.y = self.avatarView.y;
        
        CGSize csize = [self.messageData contentSize];
        self.container.width = csize.width;
        self.container.height = csize.height;
        self.container.y = self.nameLabel.height + 3;
        self.container.maxX = self.nameLabel.maxX;
        [self.indicator sizeToFit];
        self.indicator.centerY = self.container.centerY;
        self.indicator.x = self.container.x - 8 - self.indicator.width;
        self.retryView.frame = self.indicator.frame;
    }
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
    if (_messageData.elem.sendStatus == BFIM_MSG_STATUS_SEND_FAIL)
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

- (void)prepareForReuse{
    [super prepareForReuse];
    //今后任何关于复用产生的 UI 问题，都可以在此尝试编码解决。
}

@end
