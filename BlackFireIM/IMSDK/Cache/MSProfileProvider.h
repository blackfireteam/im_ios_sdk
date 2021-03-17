//
//  MSProfileProvider.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/15.
//
///用户信息提供类。内部有缓存处理。网络->内存->数据库
#import <Foundation/Foundation.h>
#import "MSProfileInfo.h"


NS_ASSUME_NONNULL_BEGIN

@interface MSProfileProvider : NSObject

///单例
+ (instancetype)provider;


/// 查询某个用户的个人信息
/// @param user_id 用户uid
/// @param completed 异步返回查询结果。
- (void)providerProfile:(NSInteger)user_id
               complete:(void(^)(MSProfileInfo *profile))completed;

///只从本地查询用户的个人信息
- (MSProfileInfo *)providerProfileFromLocal:(NSInteger)user_id;

///更新用户信息
- (void)updateProfile:(MSProfileInfo *)info;

///比对update_time与服务器同步更新用户信息
- (void)synchronizeProfiles:(NSArray<MSProfileInfo *> *)profiles;

///返回本地数据库中所有的用户信息
- (NSArray<MSProfileInfo *> *)allProfiles;

@end

NS_ASSUME_NONNULL_END
