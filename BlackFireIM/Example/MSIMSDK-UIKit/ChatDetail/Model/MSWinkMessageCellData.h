//
//  BFCustomMessageCellData.h
//  BlackFireIM
//
//  Created by benny wang on 2021/4/13.
//

#import "MSMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface MSWinkMessageCellData : MSMessageCellData

@property(nonatomic,strong,readonly) MSIMCustomElem *customElem;

@end

NS_ASSUME_NONNULL_END
