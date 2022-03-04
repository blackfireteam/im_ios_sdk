//
//  MSCllMessageCellData.h
//  BlackFireIM
//
//  Created by benny wang on 2021/8/18.
//

#import "MSBubbleMessageCellData.h"
#import "MSCallManager.h"


NS_ASSUME_NONNULL_BEGIN

@interface BFCallMessageCellData : MSBubbleMessageCellData


@property(nonatomic,assign) MSCallType callType;

@property(nonatomic,copy) NSString *notice;

@property(nonatomic, strong,readonly) UIImage *iconImage;

@property (nonatomic, assign,readonly) CGRect noticeFrame;

@property (nonatomic, assign,readonly) CGRect iconFrame;

@end

NS_ASSUME_NONNULL_END
