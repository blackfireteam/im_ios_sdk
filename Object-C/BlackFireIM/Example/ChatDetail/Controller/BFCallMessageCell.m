//
//  MSCallMessageCell.m
//  BlackFireIM
//
//  Created by benny wang on 2021/8/18.
//

#import "BFCallMessageCell.h"
#import "MSIMSDK-UIKit.h"


@implementation BFCallMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _icon = [[UIImageView alloc]init];
        [self.bubbleView addSubview:_icon];
        
        _titleL = [[UILabel alloc] init];
        [self.bubbleView addSubview:_titleL];
    }
    return self;
}

- (BFCallMessageCellData *)callData
{
    return (BFCallMessageCellData *)self.messageData;
}

- (void)fillWithData:(BFCallMessageCellData *)data
{
    [super fillWithData:data];
    if (data.direction == MsgDirectionIncoming) {
        self.titleL.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color];
    }else {
        self.titleL.textColor = [UIColor d_colorWithColorLight:[UIColor whiteColor] dark:[UIColor whiteColor]];
    }
    self.titleL.font = [UIFont systemFontOfSize:16];
    self.titleL.text = data.notice;
    self.icon.image = data.iconImage;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.titleL.frame = self.callData.noticeFrame;
    self.icon.frame = self.callData.iconFrame;
}

@end
