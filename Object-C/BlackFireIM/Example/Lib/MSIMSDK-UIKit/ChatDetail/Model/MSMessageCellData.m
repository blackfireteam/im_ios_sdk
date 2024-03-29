//
//  MSMessageCellData.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/5.
//

#import "MSMessageCellData.h"
#import "MSIMSDK-UIKit.h"


@implementation MSMessageCellData

- (instancetype)initWithDirection:(TMsgDirection)direction
{
    self = [super init];
    if (self) {
        _direction = direction;
        _defaultAvatar = [UIImage imageNamed:TUIKitResource(@"holder_avatar")];
    }
    return self;
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
    height += 15;
    return height;
}

- (CGSize)contentSize
{
    return CGSizeZero;
}

- (NSString *)reuseId
{
    return @"MSMessageCell";
}

@end
