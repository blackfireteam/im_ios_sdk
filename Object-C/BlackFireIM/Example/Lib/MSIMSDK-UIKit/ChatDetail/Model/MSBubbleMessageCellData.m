//
//  MSBubbleMessageCellData.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/5.
//

#import "MSBubbleMessageCellData.h"
#import "MSIMSDK-UIKit.h"


@implementation MSBubbleMessageCellData

- (id)initWithDirection:(TMsgDirection)direction
{
    self = [super initWithDirection:direction];
    if (self) {
        if (direction == MsgDirectionIncoming) {
            _bubble = [[self class] incommingBubble];
            _highlightedBubble = [[self class] incommingHighlightedBubble];
        } else {
            _bubble = [[self class] outgoingBubble];
            _highlightedBubble = [[self class] outgoingHighlightedBubble];
        }
    }
    return self;
}


static UIImage *sOutgoingBubble;

+ (UIImage *)outgoingBubble
{
    if (!sOutgoingBubble) {
        sOutgoingBubble = [[UIImage imageNamed:TUIKitResource(@"sender_text_normal")] resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{15,20,15,22}") resizingMode:UIImageResizingModeStretch];
    }
    return sOutgoingBubble;
}

+ (void)setOutgoingBubble:(UIImage *)outgoingBubble
{
    sOutgoingBubble = outgoingBubble;
}

static UIImage *sOutgoingHighlightedBubble;
+ (UIImage *)outgoingHighlightedBubble
{
    if (!sOutgoingHighlightedBubble) {
        sOutgoingHighlightedBubble = [[UIImage imageNamed:TUIKitResource(@"sender_text_pressed")] resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{15,20,15,22}") resizingMode:UIImageResizingModeStretch];
    }
    return sOutgoingHighlightedBubble;
}

+ (void)setOutgoingHighlightedBubble:(UIImage *)outgoingHighlightedBubble
{
    sOutgoingHighlightedBubble = outgoingHighlightedBubble;
}

static UIImage *sIncommingBubble;
+ (UIImage *)incommingBubble
{
    if (!sIncommingBubble) {
        sIncommingBubble = [[UIImage d_imageWithImageLight:TUIKitResource(@"receiver_text_normal") dark:TUIKitResource(@"receiver_text_pressed")] resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{15,23,15,16}") resizingMode:UIImageResizingModeStretch];
    }
    return sIncommingBubble;
}

+ (void)setIncommingBubble:(UIImage *)incommingBubble
{
    sIncommingBubble = incommingBubble;
}

static UIImage *sIncommingHighlightedBubble;
+ (UIImage *)incommingHighlightedBubble
{
    if (!sIncommingHighlightedBubble) {
        sIncommingHighlightedBubble = [[UIImage imageNamed:TUIKitResource(@"receiver_text_pressed")] resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{15,23,15,16}") resizingMode:UIImageResizingModeStretch];
    }
    return sIncommingHighlightedBubble;
}

+ (void)setIncommingHighlightedBubble:(UIImage *)incommingHighlightedBubble
{
    sIncommingHighlightedBubble = incommingHighlightedBubble;
}


@end
