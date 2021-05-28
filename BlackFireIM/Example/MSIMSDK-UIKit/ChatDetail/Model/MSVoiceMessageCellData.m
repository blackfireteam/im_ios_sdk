//
//  MSVoiceMessageCellData.m
//  BlackFireIM
//
//  Created by benny wang on 2021/4/22.
//

#import "MSVoiceMessageCellData.h"
#import <AVFoundation/AVFoundation.h>
#import "MSHeader.h"
#import "NSFileManager+filePath.h"
#import "MSIMSDK.h"


@interface MSVoiceMessageCellData()<AVAudioPlayerDelegate>

@property(nonatomic,strong) AVAudioPlayer *audioPlayer;

@property(nonatomic,copy) NSString *wavPath;

@end
@implementation MSVoiceMessageCellData

- (instancetype)initWithDirection:(TMsgDirection)direction
{
    self = [super initWithDirection:direction];
    if (self) {
        if (direction == MsgDirectionIncoming) {
            _voiceImage = [UIImage bf_imageNamed:@"receiver_voice"];
            _voiceAnimationImages = @[[UIImage bf_imageNamed:@"receiver_voice_play_1"],
                                      [UIImage bf_imageNamed:@"receiver_voice_play_2"],
                                      [UIImage bf_imageNamed:@"receiver_voice_play_3"]];
        } else {
            _voiceImage = [UIImage bf_imageNamed:@"sender_voice"];
            _voiceAnimationImages = @[[UIImage bf_imageNamed:@"sender_voice_play_1"],
                                      [UIImage bf_imageNamed:@"sender_voice_play_2"],
                                      [UIImage bf_imageNamed:@"sender_voice_play_3"]];
        }
    }

    return self;
}

- (MSIMVoiceElem *)voiceElem
{
    return (MSIMVoiceElem *)self.elem;
}

- (CGSize)contentSize
{
    CGFloat bubbleWidth = TVoiceMessageCell_Back_Width_Min + self.voiceElem.duration / TVoiceMessageCell_Max_Duration * Screen_Width;
    if(bubbleWidth > TVoiceMessageCell_Back_Width_Max){
        bubbleWidth = TVoiceMessageCell_Back_Width_Max;
    }

    CGFloat bubbleHeight = TVoiceMessageCell_Duration_Size.height;
    if (self.direction == MsgDirectionIncoming) {
        bubbleWidth = MAX(bubbleWidth, [MSBubbleMessageCellData incommingBubble].size.width);
        bubbleHeight = 40;
    } else {
        bubbleWidth = MAX(bubbleWidth, [MSBubbleMessageCellData outgoingBubble].size.width);
        bubbleHeight = 40;
    }
    return CGSizeMake(bubbleWidth+TVoiceMessageCell_Duration_Size.width, bubbleHeight);
}

- (void)playVoiceMessage
{
    if (self.isPlaying) {
        return;
    }
    self.isPlaying = YES;
    NSString *path = self.voiceElem.path;
    if (path && [[NSFileManager defaultManager]fileExistsAtPath:path]) {
        [self playInternal:path];
    }else {
        if (self.isDownloading) {
            return;
        }
        //下载
        self.isDownloading = YES;
        WS(weakSelf)
        NSString *savePath = [[NSFileManager pathForIMVoice] stringByAppendingPathComponent:[self.voiceElem.url lastPathComponent]];
        
        [[MSIMManager sharedInstance].uploadMediator ms_downloadFromUrl:self.voiceElem.url toSavePath:savePath progress:^(CGFloat progress) {
                    
                } succ:^(NSString * _Nonnull url) {
                    
                    weakSelf.isDownloading = NO;
                    weakSelf.voiceElem.path = savePath;
                    [weakSelf playInternal:savePath];
                    
                } fail:^(NSInteger code, NSString * _Nonnull desc) {
                    weakSelf.isDownloading = NO;
                    [weakSelf stopVoiceMessage];
        }];
    }
}

- (void)playInternal:(NSString *)path
{
    if (!self.isPlaying) return;

    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    NSURL *url = [NSURL fileURLWithPath:path];
    [self.audioPlayer stop];
    self.audioPlayer = [[AVAudioPlayer alloc]initWithData:[NSData dataWithContentsOfURL:url] error:nil];
    self.audioPlayer.delegate = self;
    BOOL result = [self.audioPlayer play];
    if (!result) {
        self.isPlaying = NO;
        [MSHelper showToastFail:@"音频文件不存在或已损坏"];
    }
}

- (void)stopVoiceMessage
{
    if ([self.audioPlayer isPlaying]) {
        [self.audioPlayer stop];
        self.audioPlayer = nil;
    }
    self.isPlaying = NO;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag;
{
    self.isPlaying = NO;
    [[NSFileManager defaultManager] removeItemAtPath:self.wavPath error:nil];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error
{
    self.isPlaying = NO;
    MSLog(@"音频播放失败：%@",error);
    [MSHelper showToastFail:@"音频文件解码失败"];
}

- (NSString *)reuseId
{
    return TVoiceMessageCell_ReuseId;
}

@end
