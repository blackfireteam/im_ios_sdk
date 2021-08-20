//
//  MSSystemMessageCell.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/22.
//

#import "MSSystemMessageCell.h"
#import "UIColor+BFDarkMode.h"


@interface MSSystemMessageCell()

@property(nonatomic,strong) UILabel *messageLabel;

@property(nonatomic,strong) MSSystemMessageCellData *systemData;

@end
@implementation MSSystemMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.font = [UIFont systemFontOfSize:13];
        _messageLabel.textColor = [UIColor d_systemGrayColor];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.numberOfLines = 0;
        _messageLabel.backgroundColor = [UIColor clearColor];
        _messageLabel.layer.cornerRadius = 3;
        [_messageLabel.layer setMasksToBounds:YES];
        [self.container addSubview:_messageLabel];
    }
    return self;
}

- (MSSystemMessageCellData *)systemData
{
    return (MSSystemMessageCellData *)self.messageData;
}

- (void)fillWithData:(MSSystemMessageCellData *)data;
{
    [super fillWithData:data];
    self.messageLabel.text = data.content;
    self.messageLabel.textColor = data.contentColor;
    self.nameLabel.hidden = YES;
    self.avatarView.hidden = YES;
    self.retryView.hidden = YES;
    [self.indicator stopAnimating];
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.container.center = self.container.superview.center;
    self.messageLabel.frame = self.container.bounds;
}

@end
