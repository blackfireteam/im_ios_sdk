//
//  BFProfileService.m
//  BlackFireIM
//
//  Created by benny wang on 2021/4/21.
//

#import "BFProfileService.h"
#import "NSString+Encry.h"
#import "MSIMSDK.h"
#import <AFNetworking.h>

@implementation BFProfileService


+ (void)requestIMToken:(NSString *)uid
               success:(void(^)(NSDictionary *dic))succ
                  fail:(void(^)(NSError *error))fail
{
    if (uid == nil) {
        fail(nil);
        return;
    }
    AFHTTPSessionManager *manager = [self ms_manager];
    NSString *secret = @"asfasdasd123";
    NSString *radom = [NSString stringWithFormat:@"%u",arc4random_uniform(1000000)];
    NSString *time = [NSString stringWithFormat:@"%zd",[MSIMTools sharedInstance].adjustLocalTimeInterval/1000/1000/10];
    NSString *sign = [[NSString stringWithFormat:@"%@%@%@",secret,radom,time] bf_sh1];
    NSString *postUrl = [NSString stringWithFormat:@"https://%@:18788/user/iminit",[IMSDKConfig defaultConfig].ip];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:uid forKey:@"uid"];
    [params setValue:@(0) forKey:@"ctype"];
    [manager POST:postUrl parameters:params headers:@{@"nonce":radom,@"timestamp":time,@"sig":sign} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        NSNumber *code = dic[@"code"];
        if (code.integerValue == 0) {
            if (succ) succ(dic[@"data"]);
        }else {
            if (fail) fail(nil);
        }
        
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            if (fail) fail(error);
    }];
}

///修改个人资料
+ (void)requestToEditProfile:(MSProfileInfo *)info
                     success:(void(^)(NSDictionary *dic))succ
                        fail:(void(^)(NSError *error))fail
{
    if (info == nil) {
        fail(nil);
        return;
    }
    AFHTTPSessionManager *manager = [self ms_manager];
    NSString *secret = @"asfasdasd123";
    NSString *radom = [NSString stringWithFormat:@"%u",arc4random_uniform(1000000)];
    NSString *time = [NSString stringWithFormat:@"%zd",[MSIMTools sharedInstance].adjustLocalTimeInterval/1000/1000/10];
    NSString *sign = [[NSString stringWithFormat:@"%@%@%@",secret,radom,time] bf_sh1];
    NSString *postUrl = [NSString stringWithFormat:@"https://%@:18788/user/update",[IMSDKConfig defaultConfig].ip];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:info.user_id forKey:@"uid"];
    [params setValue:info.nick_name forKey:@"nick_name"];
    [params setValue:info.avatar forKey:@"avatar"];
    [params setValue:@(info.gold) forKey:@"gold"];
    if (info.gold_exp) {
        [params setValue:@(info.gold_exp) forKey:@"gold_exp"];
    }
    [params setValue:@(info.verified) forKey:@"verified"];
    [manager POST:postUrl parameters:params headers:@{@"nonce":radom,@"timestamp":time,@"sig":sign} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        if (succ) succ(dic);
        
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            if (fail) fail(error);
    }];
}

+ (AFHTTPSessionManager *)ms_manager
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    return manager;
}

@end
