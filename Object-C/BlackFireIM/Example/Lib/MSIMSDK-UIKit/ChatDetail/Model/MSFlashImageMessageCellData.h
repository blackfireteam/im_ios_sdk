//
//  MSFlashImageMessageCellData.h
//  BlackFireIM
//
//  Created by benny wang on 2022/1/25.
//

#import "MSMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@class MSIMFlashElem;
@interface MSFlashImageMessageCellData : MSMessageCellData

@property(nonatomic,strong,readonly) MSIMFlashElem *flashElem;

@end

NS_ASSUME_NONNULL_END
