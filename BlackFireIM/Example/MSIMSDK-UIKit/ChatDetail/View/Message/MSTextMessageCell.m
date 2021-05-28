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



- (void)fillWithData:(MSTextMessageCellData *)data
{
    //set data
    [super fillWithData:data];
    self.textData = data;
    self.content.attributedText = data.attributedString;
    self.content.textColor = data.textColor;
//  font set in attributedString
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.content.frame = (CGRect){.origin = self.textData.textOrigin, .size = self.textData.textSize};
}

@end
