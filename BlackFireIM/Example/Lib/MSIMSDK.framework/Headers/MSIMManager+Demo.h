//
//  MSIMManager+Demo.h
//  BlackFireIM
//
//  Created by benny wang on 2021/4/9.
//
//测试Demo相关的接口
#import <MSIMSDK/MSIMManager.h>

NS_ASSUME_NONNULL_BEGIN

@class MSProfileInfo;
@interface MSIMManager (Demo)

///获取首页Spark相关数据
- (void)getSparks:(void(^)(NSArray<MSProfileInfo *> *sparks))succ
             fail:(MSIMFail)fail;


///模拟获取用户的token  for demo
- (void)getIMToken:(NSString *)phone
              succ:(void(^)(NSString *userToken))succ
            failed:(MSIMFail)fail;


///模拟用户注册
- (void)userSignUp:(NSString *)phone
          nickName:(NSString *)nickName
            avatar:(NSString *)avatar
              succ:(void(^)(NSString *userToken))succ
            failed:(MSIMFail)fail;
@end

NS_ASSUME_NONNULL_END
