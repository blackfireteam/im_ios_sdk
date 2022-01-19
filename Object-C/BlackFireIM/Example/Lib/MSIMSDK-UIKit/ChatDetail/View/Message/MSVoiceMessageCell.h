//
//  MSVoiceMessageCell.h
//  BlackFireIM
//
//  Created by benny wang on 2021/4/22.
//

#import "MSBubbleMessageCell.h"
#import "MSVoiceMessageCellData.h"


NS_ASSUME_NONNULL_BEGIN

@interface MSVoiceMessageCell : MSBubbleMessageCell

@property (nonatomic, strong) UIImageView *voice;

@property (nonatomic, strong) UILabel *duration;


@property(nonatomic,strong,readonly) MSVoiceMessageCellData *voiceData;

@end

NS_ASSUME_NONNULL_END
