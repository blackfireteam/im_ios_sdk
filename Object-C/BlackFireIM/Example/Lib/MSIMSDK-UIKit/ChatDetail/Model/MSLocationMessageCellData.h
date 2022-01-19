//
//  MSLocationMessageCellData.h
//  BlackFireIM
//
//  Created by benny wang on 2021/11/30.
//

#import "MSMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface MSLocationMessageCellData : MSMessageCellData

@property(nonatomic,strong,readonly) MSIMLocationElem *locationElem;

@end

NS_ASSUME_NONNULL_END
