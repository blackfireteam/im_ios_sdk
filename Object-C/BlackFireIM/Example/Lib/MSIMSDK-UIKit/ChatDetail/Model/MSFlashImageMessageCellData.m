//
//  MSFlashImageMessageCellData.m
//  BlackFireIM
//
//  Created by benny wang on 2022/1/25.
//

#import "MSFlashImageMessageCellData.h"
#import "MSIMSDK-UIKit.h"


@implementation MSFlashImageMessageCellData

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (CGSize)contentSize
{
    return CGSizeMake(200, 200);
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
    return TFlashImageMessageCell_ReuseId;
}

@end
