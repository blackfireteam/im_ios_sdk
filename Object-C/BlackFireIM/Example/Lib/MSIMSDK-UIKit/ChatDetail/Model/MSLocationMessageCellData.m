//
//  MSLocationMessageCellData.m
//  BlackFireIM
//
//  Created by benny wang on 2021/11/30.
//

#import "MSLocationMessageCellData.h"
#import "MSHeader.h"

@implementation MSLocationMessageCellData

- (MSIMLocationElem *)locationElem
{
    return (MSIMLocationElem *)self.elem;
}

- (CGSize)contentSize
{
   return CGSizeMake(TLocationMessageCell_Width, TLocationMessageCell_Height);
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
    return TLocationMessageCell_ReuseId;
}

@end
