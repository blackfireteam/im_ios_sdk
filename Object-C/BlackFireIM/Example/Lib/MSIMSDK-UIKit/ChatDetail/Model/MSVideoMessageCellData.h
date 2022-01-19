//
//  MSVideoMessageCellData.h
//  BlackFireIM
//
//  Created by benny wang on 2021/4/2.
//

#import "MSMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface MSVideoMessageCellData : MSMessageCellData

@property(nonatomic,strong,readonly) MSIMVideoElem *videoElem;

@end

NS_ASSUME_NONNULL_END
