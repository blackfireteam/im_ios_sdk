//
//  MSWinkMessageCell.h
//  BlackFireIM
//
//  Created by benny wang on 2021/4/13.
//

#import "MSMessageCell.h"
#import <Lottie/Lottie.h>
#import "MSEmotionMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface MSEmotionMessageCell : MSMessageCell

@property(nonatomic,strong) LOTAnimationView *animationView;

@property(nonatomic,strong,readonly) MSEmotionMessageCellData *emotionData;

@end

NS_ASSUME_NONNULL_END
