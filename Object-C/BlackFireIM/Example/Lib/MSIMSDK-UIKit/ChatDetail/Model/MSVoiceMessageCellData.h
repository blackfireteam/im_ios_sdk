//
//  MSVoiceMessageCellData.h
//  BlackFireIM
//
//  Created by benny wang on 2021/4/22.
//

#import "MSBubbleMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface MSVoiceMessageCellData : MSBubbleMessageCellData

@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic, assign) BOOL isDownloading;

@property(nonatomic,strong) NSArray<UIImage *> *voiceAnimationImages;

@property(nonatomic,strong) UIImage *voiceImage;

- (void)stopVoiceMessage;

- (void)playVoiceMessage;

@end

NS_ASSUME_NONNULL_END
