//
//  MSSystemMessageCellData.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/20.
//

#import "MSSystemMessageCellData.h"
#import "MSIMSDK-UIKit.h"
#import <MSIMSDK/MSIMSDK.h>

@implementation MSSystemMessageCellData

- (instancetype)initWithDirection:(TMsgDirection)direction
{
    if (self = [super initWithDirection:direction]) {
        _contentFont = [UIFont systemFontOfSize:13];
        _contentColor = [UIColor d_systemGrayColor];
    }
    return self;
}

- (CGSize)contentSize
{
    CGSize size = [self.content textSizeIn:CGSizeMake(TSystemMessageCell_Text_Width_Max, MAXFLOAT) font:self.contentFont];
    size.height += 10;
    size.width += 16;
    return size;
}

- (CGFloat)heightOfWidth:(CGFloat)width
{
    return [self contentSize].height + 16;
}

- (NSString *)reuseId
{
    return TSystemMessageCell_ReuseId;
}

@end
