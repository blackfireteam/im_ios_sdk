//
//  MSTextMessageCell.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/5.
//

#import "MSTextMessageCell.h"

@implementation MSTextMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _content = [[UILabel alloc] init];
        _content.numberOfLines = 0;
        [self.bubbleView addSubview:_content];
    }
    return self;
}

- (MSTextMessageCellData *)textData
{
    return (MSTextMessageCellData *)self.messageData;
}

- (void)fillWithData:(MSTextMessageCellData *)data
{
    [super fillWithData:data];
    self.content.attributedText = data.attributedString;
    self.content.textColor = data.textColor;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.content.frame = (CGRect){.origin = self.textData.textOrigin, .size = self.textData.textSize};
}

@end
