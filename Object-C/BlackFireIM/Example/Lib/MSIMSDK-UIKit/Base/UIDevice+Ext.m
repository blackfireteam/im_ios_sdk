//
//  UIDevice+Ext.m
//  BlackFireIM
//
//  Created by benny wang on 2021/4/15.
//

#import "UIDevice+Ext.h"
#import <AVFoundation/AVFoundation.h>


/**
 *  系统铃声播放完成后的回调
 */
static SystemSoundID _ringSystemSoundID;
static void ringAudioServicesSystemSoundCompletionProc(SystemSoundID ssID, void *clientData)
{
    AudioServicesPlayAlertSound(ssID);
}

@implementation UIDevice (Ext)

// UIImpactFeedbackGenerator类是标准的触觉反馈类
+ (void)impactFeedback
{
    if(@available(iOS 10.0, *)) {
        UIImpactFeedbackGenerator *impactLight = [[UIImpactFeedbackGenerator alloc]initWithStyle:UIImpactFeedbackStyleMedium];
        [impactLight impactOccurred];
    }
}

// 播放短声音
+ (void)playShortSound:(NSString *)soundName soundExtension:(NSString *)soundExtension
{
    NSURL *audioPath = [[NSBundle mainBundle] URLForResource:soundName withExtension:soundExtension];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(audioPath), &_ringSystemSoundID);
    // Register the sound completion callback.
    AudioServicesAddSystemSoundCompletion(_ringSystemSoundID,
                                          NULL, // uses the main run loop
                                          NULL, // uses kCFRunLoopDefaultMode
                                          ringAudioServicesSystemSoundCompletionProc, // the name of our custom callback function
                                          NULL // for user data, but we don't need to do that in this case, so we just pass NULL
                                          );
    
    AudioServicesPlayAlertSound(_ringSystemSoundID);
}

+ (void)stopPlaySystemSound
{
    if (_ringSystemSoundID != 0) {
        //移除系统播放完成后的回调函数
        AudioServicesRemoveSystemSoundCompletion(_ringSystemSoundID);
        //销毁创建的SoundID
        AudioServicesDisposeSystemSoundID(_ringSystemSoundID);
        _ringSystemSoundID = 0;
    }
}

@end
