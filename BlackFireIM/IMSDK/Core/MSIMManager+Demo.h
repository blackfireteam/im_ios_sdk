//
//  MSIMManager+Demo.h
//  BlackFireIM
//
//  Created by benny wang on 2021/4/9.
//
//测试Demo相关的接口
#import "MSIMManager.h"

NS_ASSUME_NONNULL_BEGIN

@class MSProfileInfo;
@interface MSIMManager (Demo)

///获取首页Spark相关数据
- (void)getSparks:(void(^)(NSArray<MSProfileInfo *> *sparks))succ
             fail:(MSIMFail)fail;

@end

NS_ASSUME_NONNULL_END
