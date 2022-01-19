//
//  BFProfileService.h
//  BlackFireIM
//
//  Created by benny wang on 2021/4/21.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@class MSProfileInfo;
@class BFRegisterInfo;
@interface BFProfileService : NSObject

+ (NSString *)postUrl;

///请求用户的IM令牌和网关
+ (void)requestIMToken:(NSString *)uid
               success:(void(^)(NSDictionary *dic))succ
                  fail:(void(^)(NSError *error))fail;

///模拟用户注册
+ (void)userSignUp:(BFRegisterInfo *)info
              succ:(void(^)(void))succ
            failed:(void(^)(NSError *error))fail;

///修改个人资料
+ (void)requestToEditProfile:(MSProfileInfo *)info
                     success:(void(^)(NSDictionary *dic))succ
                        fail:(void(^)(NSError *error))fail;


@end

NS_ASSUME_NONNULL_END
