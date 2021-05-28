//
//  BFVideoMessageCellData.h
//  BlackFireIM
//
//  Created by benny wang on 2021/4/2.
//

#import "BFMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface BFVideoMessageCellData : BFMessageCellData

@property(nonatomic,strong,readonly) MSIMVideoElem *videoElem;

@end

NS_ASSUME_NONNULL_END
