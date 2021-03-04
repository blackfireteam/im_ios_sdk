//
//  IMSDKConfig.m
//  BlackFireIM
//
//  Created by benny wang on 2021/2/25.
//

#import "IMSDKConfig.h"

@implementation IMSDKConfig

+ (instancetype)defaultConfig
{
    IMSDKConfig *config = [[IMSDKConfig alloc]init];
    config.ip = @"192.168.1.1";
    config.port = 9090;
    config.token = @"";
    config.heartDuration = 30;
    config.retryCount = 5;
    return config;
}

//写入保护
- (void)setHeartDuration:(NSInteger)heartDuration
{
    _heartDuration = MAX(heartDuration, 5);
    _heartDuration = MIN(_heartDuration, 4*60);
}

- (void)setRetryCount:(NSInteger)retryCount
{
    _retryCount = MAX(1, retryCount);
}

@end
