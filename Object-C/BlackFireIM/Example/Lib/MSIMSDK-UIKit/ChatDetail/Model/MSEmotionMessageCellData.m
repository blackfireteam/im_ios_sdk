//
//  BFCustomMessageCellData.m
//  BlackFireIM
//
//  Created by benny wang on 2021/4/13.
//

#import "MSEmotionMessageCellData.h"
#import "MSHeader.h"

@implementation MSEmotionMessageCellData

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (MSIMEmotionElem *)emotionElem
{
    return (MSIMEmotionElem *)self.elem;
}

- (CGSize)contentSize
{
   return TEmotionMessageCell_Container_Size;
}

- (CGFloat)heightOfWidth:(CGFloat)width
{
    CGFloat height = 0;
    if (self.showName) {
        height += 25;
    }
    CGSize containerSize = [self contentSize];
    height += containerSize.height;
    if (self.direction == MsgDirectionOutgoing) {
        height += 20;
    }
    height += 5 + 5;
    return height;
}

- (NSString *)reuseId
{
    return TEmotionMessageCell_ReuseId;
}

@end
