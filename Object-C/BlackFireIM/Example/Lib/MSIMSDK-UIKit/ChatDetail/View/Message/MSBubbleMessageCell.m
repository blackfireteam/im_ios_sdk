//
//  MSBubbleMessageCell.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/5.
//

#import "MSBubbleMessageCell.h"
#import "UIView+Frame.h"

@implementation MSBubbleMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _bubbleView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.container addSubview:_bubbleView];
        _bubbleView.bounds = self.container.bounds;
        _bubbleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (MSBubbleMessageCellData *)bubbleData
{
    return (MSBubbleMessageCellData *)self.messageData;
}

- (void)fillWithData:(MSBubbleMessageCellData *)data
{
    [super fillWithData:data];
    self.bubbleView.image = data.bubble;
    self.bubbleView.highlightedImage = data.highlightedBubble;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

@end
