//
//  BFDragConfig.m
//  BlackFireIM
//
//  Created by benny wang on 2021/4/8.
//

#import "BFDragConfig.h"

@implementation BFDragConfig

- (instancetype)init
{
    if (self = [super init]) {
        _visableCount = 3;
        _containerEdge = 10;
        _cardEdge = 10;
        _cardCornerRadius = 10;
        _cardCornerBorderWidth = 0.5;
        _cardBordColor = [UIColor lightGrayColor];
    }
    return self;
}

@end
