//
//  IMSDKConfig.h
//  BlackFireIM
//
//  Created by benny wang on 2021/2/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IMSDKConfig : NSObject

@property(nonatomic,copy) NSString *ip;
@property(nonatomic,assign) UInt16 port;

/** 心跳间隔 默认 ：30s, min: 5s max: 4分钟*/
@property(nonatomic,assign) NSInteger heartDuration;
/** 链接断开，自动重连次数,默认：5次，min: 1次*/
@property(nonatomic,assign) NSInteger retryCount;

/** 会话列表分页拉取数量,默认：50个*/
@property(nonatomic,assign) NSInteger chatListPageCount;

+ (instancetype)defaultConfig;

@end

NS_ASSUME_NONNULL_END
