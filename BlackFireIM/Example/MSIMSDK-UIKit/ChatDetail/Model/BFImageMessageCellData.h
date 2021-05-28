//
//  BFImageMessageCellData.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/5.
//

#import "BFMessageCellData.h"


NS_ASSUME_NONNULL_BEGIN

@interface BFImageMessageCellData : BFMessageCellData

@property(nonatomic,strong,readonly) MSIMImageElem *imageElem;


@end

NS_ASSUME_NONNULL_END
