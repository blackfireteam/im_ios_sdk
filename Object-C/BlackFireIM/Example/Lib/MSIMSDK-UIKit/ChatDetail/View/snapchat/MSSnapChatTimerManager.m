//
//  MSSnapChatTimerManager.m
//  BlackFireIM
//
//  Created by benny wang on 2022/2/22.
//

#import "MSSnapChatTimerManager.h"


NSString * const SNAPCHAT_COUNTDOWN_CHANGED = @"SNAPCHAT_COUNTDOWN_CHANGED";

@interface MSSnapChatTimerManager()

@property(nonatomic,strong) NSMutableDictionary *cacheTimer;

@property(nonatomic,strong) NSTimer *timer;


@end
@implementation MSSnapChatTimerManager

static MSSnapChatTimerManager *manager;
+ (instancetype)defaultManager
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[MSSnapChatTimerManager alloc]init];
    });
    return manager;
}

- (instancetype)init
{
    if (self = [super init]) {
        _cacheTimer = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSInteger)startCountDownWithMessage:(MSIMMessage *)message
{
    if (message.isSelf) return 0;
    NSString *msg_id = [NSString stringWithFormat:@"%zd",message.msgID];
    NSInteger leftCount = [self.cacheTimer[msg_id]integerValue];
    if (leftCount) {
        return leftCount;
    }
    if (message.type == MSIM_MSG_TYPE_TEXT) {
        leftCount = message.textElem.text.length * 0.2 + 5;
    }else if (message.type == MSIM_MSG_TYPE_IMAGE) {
        leftCount = 20;
    }else if (message.type == MSIM_MSG_TYPE_VIDEO) {
        leftCount = MAX(message.videoElem.duration + 2, 5);
    }else if (message.type == MSIM_MSG_TYPE_VOICE) {
        leftCount = MAX(message.voiceElem.duration + 2, 5);
    }else {
        leftCount = 10;
    }
    [self.cacheTimer setValue:@(leftCount) forKey:msg_id];
    if (self.timer == nil) {
        WS(weakSelf)
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [weakSelf timerHandle];
        }];
        [[NSRunLoop mainRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
    return leftCount;
}

- (void)timerHandle
{
    for (NSInteger i = 0; i < self.cacheTimer.allKeys.count; i++) {
        NSString *key = self.cacheTimer.allKeys[i];
        NSInteger count = [self.cacheTimer[key] integerValue];
        count -= 1;
        if (count == 0) {
            [self.cacheTimer removeObjectForKey:key];
        }else {
            self.cacheTimer[key] = @(count);
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:SNAPCHAT_COUNTDOWN_CHANGED object:@{@"msg_id": key,@"count": @(count)}];
    }
    if (self.cacheTimer.count == 0) {
        [self.timer invalidate];
        self.timer = nil;
    }
}




@end
