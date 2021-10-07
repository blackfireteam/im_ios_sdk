//
//  MSImageMessageCellData.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/5.
//

#import "MSMessageCellData.h"


NS_ASSUME_NONNULL_BEGIN

@interface MSImageMessageCellData : MSMessageCellData

@property(nonatomic,strong,readonly) MSIMImageElem *imageElem;


@end

NS_ASSUME_NONNULL_END
