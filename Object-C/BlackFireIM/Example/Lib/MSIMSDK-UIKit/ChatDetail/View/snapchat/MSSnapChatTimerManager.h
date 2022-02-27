//
//  MSSnapChatTimerManager.h
//  BlackFireIM
//
//  Created by benny wang on 2022/2/22.
//

#import <Foundation/Foundation.h>
#import <MSIMSDK/MSIMSDK.h>


NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const SNAPCHAT_COUNTDOWN_CHANGED;
@interface MSSnapChatTimerManager : NSObject


+ (instancetype)defaultManager;

/** 开始倒记时，返回剩余的时间，秒。
 倒记进行中，会发送通知SNAPCHAT_COUNTDOWN_CHANGED
 */
- (NSInteger)startCountDownWithMessage:(MSIMMessage *)message;

@end

NS_ASSUME_NONNULL_END
