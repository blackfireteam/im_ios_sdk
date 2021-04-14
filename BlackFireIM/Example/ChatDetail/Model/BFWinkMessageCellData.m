//
//  BFCustomMessageCellData.m
//  BlackFireIM
//
//  Created by benny wang on 2021/4/13.
//

#import "BFWinkMessageCellData.h"
#import "BFHeader.h"


@implementation BFWinkMessageCellData

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (MSIMCustomElem *)customElem
{
    return (MSIMCustomElem *)self.elem;
}

- (CGSize)contentSize
{
   return CGSizeMake(150, 150);
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
    return TWinkMessageCell_ReuseId;
}

@end
