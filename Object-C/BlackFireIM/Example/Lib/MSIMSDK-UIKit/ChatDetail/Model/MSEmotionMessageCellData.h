//
//  BFCustomMessageCellData.h
//  BlackFireIM
//
//  Created by benny wang on 2021/4/13.
//

#import "MSMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface MSEmotionMessageCellData : MSMessageCellData

@property(nonatomic,strong,readonly) MSIMEmotionElem *emotionElem;

@end

NS_ASSUME_NONNULL_END
