//
//  BFCustomMessageCellData.h
//  BlackFireIM
//
//  Created by benny wang on 2021/4/13.
//

#import "BFMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface BFWinkMessageCellData : BFMessageCellData

@property(nonatomic,strong,readonly) MSIMCustomElem *customElem;

@end

NS_ASSUME_NONNULL_END
