//
//  BFMessageCellData.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/5.
//

#import "BFMessageCellData.h"
#import "UIImage+BFKit.h"
#import "BFHeader.h"


@implementation BFMessageCellData

- (instancetype)initWithDirection:(TMsgDirection)direction
{
    self = [super init];
    if (self) {
        _direction = direction;
        _avatarImage = [UIImage imageNamed:TUIKitResource(@"default_c2c_head")];
    }
    return self;
}

- (CGFloat)heightOfWidth:(CGFloat)width
{
    CGFloat height = 0;
    if (self.showName) {
        height += 20;
    }
    CGSize containerSize = [self contentSize];
    height += containerSize.height;
    height += 3 + 1;

    if (height < 55)
        height = 55;

    return height;
}

- (CGSize)contentSize
{
    return CGSizeZero;
}

- (NSString *)reuseId
{
    return @"BFMessageCell";
}

@end
