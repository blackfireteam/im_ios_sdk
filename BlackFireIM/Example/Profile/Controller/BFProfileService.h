//
//  BFProfileService.h
//  BlackFireIM
//
//  Created by benny wang on 2021/4/21.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@class MSProfileInfo;
@interface BFProfileService : NSObject

///修改个人资料
+ (void)requestToEditProfile:(MSProfileInfo *)info
                     success:(void(^)(NSDictionary *dic))succ
                        fail:(void(^)(NSError *error))fail;


@end

NS_ASSUME_NONNULL_END
