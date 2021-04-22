//
//  BFVoiceMessageCell.h
//  BlackFireIM
//
//  Created by benny wang on 2021/4/22.
//

#import "BFBubbleMessageCell.h"
#import "BFVoiceMessageCellData.h"


NS_ASSUME_NONNULL_BEGIN

@interface BFVoiceMessageCell : BFBubbleMessageCell

@property (nonatomic, strong) UIImageView *voice;

@property (nonatomic, strong) UILabel *duration;


@property(nonatomic,strong) BFVoiceMessageCellData *voiceData;

- (void)fillWithData:(BFVoiceMessageCellData *)data;

@end

NS_ASSUME_NONNULL_END
