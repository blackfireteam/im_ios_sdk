//
//  MSCllMessageCellData.m
//  BlackFireIM
//
//  Created by benny wang on 2021/8/18.
//

#import "BFCallMessageCellData.h"
#import "MSIMSDK-UIKit.h"
#import <MSIMSDK/MSIMSDK.h>

@interface BFCallMessageCellData()

@property (nonatomic, assign) CGRect noticeFrame;

@property (nonatomic, assign) CGRect iconFrame;

@end

@implementation BFCallMessageCellData

- (instancetype)initWithDirection:(TMsgDirection)direction
{
    self = [super initWithDirection:direction];
    if (self) {
        
    }
    return self;
}

- (UIImage *)iconImage
{
    if (self.callType == MSCallType_Voice) {
        return self.direction == MsgDirectionIncoming ? [UIImage imageNamed:TUIKitResource(@"call_decline")] : [UIImage imageNamed:TUIKitResource(@"call_decline_white")];
    }else {
        return self.direction == MsgDirectionIncoming ? [UIImage imageNamed:TUIKitResource(@"video_right")] : [UIImage imageNamed:TUIKitResource(@"video_left")];
    }
}

- (CGSize)contentSize
{
    UIEdgeInsets contentInset = self.direction == MsgDirectionIncoming ? UIEdgeInsetsMake(10, 16, 10, 14) : UIEdgeInsetsMake(10, 14, 10, 16);
    CGSize size = [self.notice textSizeIn:CGSizeMake(TTextMessageCell_Text_Width_Max, MAXFLOAT) font:[UIFont systemFontOfSize:16]];
    if (self.direction == MsgDirectionIncoming) {
        self.iconFrame = CGRectMake(contentInset.left, contentInset.top, size.height, size.height);
        self.noticeFrame = CGRectMake(CGRectGetMaxX(self.iconFrame) + 5, contentInset.top, size.width, size.height);
    }else {
        self.noticeFrame = CGRectMake(contentInset.left, contentInset.top, size.width, size.height);
        self.iconFrame = CGRectMake(CGRectGetMaxX(self.noticeFrame) + 5, contentInset.top, size.height, size.height);
    }
    size.width += contentInset.left+contentInset.right + size.height + 5;
    size.height += contentInset.top+contentInset.bottom;
    
    return size;
}

- (NSString *)reuseId
{
    return @"TCallMessageCell";
}

@end
