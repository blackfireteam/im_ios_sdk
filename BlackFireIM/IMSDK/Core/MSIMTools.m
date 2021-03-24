//
//  MSIMTools.m
//  BlackFireIM
//
//  Created by benny wang on 2021/2/26.
//

#import "MSIMTools.h"

@interface MSIMTools()

@property(nonatomic,assign) NSInteger diff;

@end
@implementation MSIMTools

static MSIMTools *_tools;
+ (MSIMTools *)sharedInstance
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _tools = [[MSIMTools alloc]init];
    });
    return _tools;
}

- (NSInteger)currentLocalTimeInterval
{
    NSTimeInterval stamp = [[NSDate date] timeIntervalSince1970];
    return stamp * 1000 * 1000;
}

- (NSInteger)adjustLocalTimeInterval
{
    NSTimeInterval stamp = self.currentLocalTimeInterval + self.diff;
    return stamp;
}



- (void)updateServerTime:(NSInteger)s_time
{
    self.diff = s_time - self.currentLocalTimeInterval;
}

///维护会话列表更新时间
- (void)updateConversationTime:(NSInteger)update_time
{
    NSString *key = [NSString stringWithFormat:@"conv_update_%@",self.user_id];
    [[NSUserDefaults standardUserDefaults] setInteger:update_time forKey:key];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

///获取会话列表更新时间
- (NSInteger)convUpdateTime
{
    NSString *key = [NSString stringWithFormat:@"conv_update_%@",self.user_id];
    NSInteger update_time = [[NSUserDefaults standardUserDefaults] integerForKey:key];
    return update_time;
}

@end
