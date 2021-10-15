//
//  BFProfileService.m
//  BlackFireIM
//
//  Created by benny wang on 2021/4/21.
//

#import "BFProfileService.h"
#import "NSString+Encry.h"
#import <MSIMSDK/MSIMSDK.h>
#import <AFNetworking.h>
#import "MSIMSDK-UIKit.h"

@interface BFProfileService()


@end
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
    NSString *time = [NSString stringWithFormat:@"%zd",[MSIMTools sharedInstance].adjustLocalTimeInterval/1000/1000];
    NSString *sign = [[NSString stringWithFormat:@"%@%@%@",secret,radom,time] bf_sh1];
    
    NSString *postUrl = [NSString stringWithFormat:@"%@/user/iminit",[self postUrl]];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:uid forKey:@"uid"];
    [params setValue:@(0) forKey:@"ctype"];
    [manager POST:postUrl parameters:params headers:@{@"nonce":radom,@"timestamp":time,@"sig":sign} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        NSNumber *code = dic[@"code"];
        if (code.integerValue == 0) {
            if (succ) succ(dic[@"data"]);
        }else {
            NSError *err = [NSError errorWithDomain:dic[@"msg"] code:code.integerValue userInfo:nil];
            if (fail) fail(err);
            MSLog(@"%@",err);
        }

        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

            if (fail) fail(error);
            MSLog(@"%@",error);
    }];
}

///模拟用户注册
+ (void)userSignUp:(NSString *)phone
          nickName:(NSString *)nickName
            avatar:(NSString *)avatar
              succ:(void(^)(void))succ
            failed:(void(^)(NSError *error))fail
{
    AFHTTPSessionManager *manager = [self ms_manager];
    NSString *secret = @"asfasdasd123";
    NSString *radom = [NSString stringWithFormat:@"%u",arc4random_uniform(1000000)];
    NSString *time = [NSString stringWithFormat:@"%zd",[MSIMTools sharedInstance].adjustLocalTimeInterval/1000/1000];
    NSString *sign = [[NSString stringWithFormat:@"%@%@%@",secret,radom,time] bf_sh1];
    NSString *postUrl = [NSString stringWithFormat:@"%@/user/reg",[self postUrl]];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:phone forKey:@"uid"];
    [params setValue:nickName forKey:@"nick_name"];
    [params setValue:avatar forKey:@"avatar"];
    [params setValue:@(1) forKey:@"gender"];
    [manager POST:postUrl parameters:params headers:@{@"nonce":radom,@"timestamp":time,@"sig":sign} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        NSNumber *code = dic[@"code"];
        if (code.integerValue == 0) {
            if (succ) succ();
        }else {
            NSError *err = [NSError errorWithDomain:dic[@"msg"] code:code.integerValue userInfo:nil];
            if (fail) fail(err);
            MSLog(@"%@",err);
        }
        
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            if (fail) fail(error);
            MSLog(@"%@",error);
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
    NSString *time = [NSString stringWithFormat:@"%zd",[MSIMTools sharedInstance].adjustLocalTimeInterval/1000/1000];
    NSString *sign = [[NSString stringWithFormat:@"%@%@%@",secret,radom,time] bf_sh1];
    NSString *postUrl = [NSString stringWithFormat:@"%@/user/update",[self postUrl]];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:info.user_id forKey:@"uid"];
    [params setValue:info.nick_name forKey:@"nick_name"];
    [params setValue:info.avatar forKey:@"avatar"];
    [params setValue:@(info.gender) forKey:@"gender"];
    [manager POST:postUrl parameters:params headers:@{@"nonce":radom,@"timestamp":time,@"sig":sign} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        if ([dic[@"code"]integerValue] == 0) {
            if (succ) succ(dic);
        }else {
            if (fail) fail([[NSError alloc]initWithDomain:dic[@"msg"] code:[dic[@"code"]integerValue] userInfo:nil]);
        }
        
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            if (fail) fail(error);
            MSLog(@"%@",error);
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
    manager.requestSerializer.timeoutInterval = 5;
    return manager;
}

+ (NSString *)postUrl
{
    BOOL serverType = [[NSUserDefaults standardUserDefaults]boolForKey:@"ms_Test"];
    NSString *host = serverType ? @"https://im.ekfree.com:18789" : @"https://msim.ekfree.com:18789";
    return host;
}

//@"https://192.168.123.224:18789"

@end
