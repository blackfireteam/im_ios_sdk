//
//  MSIMTools.m
//  BlackFireIM
//
//  Created by benny wang on 2021/2/26.
//

#import "MSIMTools.h"

@interface MSIMTools()

@property(nonatomic,assign) NSInteger diff;

@property(nonatomic,assign) NSInteger conv_update_time;

@end
@implementation MSIMTools
@synthesize user_id = _user_id;
@synthesize user_sign = _user_sign;

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

- (void)setUser_id:(NSString *)user_id
{
    _user_id = user_id;
    [[NSUserDefaults standardUserDefaults]setObject:user_id forKey:@"user_id"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (NSString *)user_id
{
    if (!_user_id) {
        _user_id = [[NSUserDefaults standardUserDefaults]objectForKey:@"user_id"];
    }
    return _user_id;
}

- (void)setUser_sign:(NSString *)user_sign
{
    _user_sign = user_sign;
    [[NSUserDefaults standardUserDefaults]setObject:user_sign forKey:@"user_sign"];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (NSString *)user_sign
{
    if (!_user_sign) {
        _user_sign = [[NSUserDefaults standardUserDefaults]objectForKey:@"user_sign"];
    }
    return _user_sign;
}

///维护会话列表更新时间
- (void)updateConversationTime:(NSInteger)update_time
{
    if (update_time > self.conv_update_time) {
        self.conv_update_time = update_time;
        NSString *key = [NSString stringWithFormat:@"conv_update_%@",self.user_id];
        [[NSUserDefaults standardUserDefaults] setInteger:update_time forKey:key];
//        [[NSUserDefaults standardUserDefaults]synchronize];
    }
}

///获取会话列表更新时间
- (NSInteger)convUpdateTime
{
    if (self.conv_update_time == 0) {
        NSString *key = [NSString stringWithFormat:@"conv_update_%@",self.user_id];
        self.conv_update_time = [[NSUserDefaults standardUserDefaults] integerForKey:key];
    }
    return self.conv_update_time;
}

- (void)cleanConvUpdateTime
{
    self.conv_update_time = 0;
}

@end
