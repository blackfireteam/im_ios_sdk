//
//  UIDevice+Ext.h
//  BlackFireIM
//
//  Created by benny wang on 2021/4/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface UIDevice (Ext)

+ (void)impactFeedback;

/// 播放自定义短声音
+ (void)playShortSound:(NSString *)soundName soundExtension:(NSString *)soundExtension;

/// 停止播放自定义短声音
+ (void)stopPlaySystemSound;

@end

NS_ASSUME_NONNULL_END
