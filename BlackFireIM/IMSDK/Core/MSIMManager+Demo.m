//
//  MSIMManager+Demo.m
//  BlackFireIM
//
//  Created by benny wang on 2021/4/9.
//

#import "MSIMManager+Demo.h"
#import "MSIMTools.h"
#import "MSIMErrorCode.h"
#import "MSProfileProvider.h"


@implementation MSIMManager (Demo)

///获取首页Spark相关数据
- (void)getSparks:(void(^)(NSArray<MSProfileInfo *> *sparks))succ
             fail:(MSIMFail)fail
{
    FetchSpark *request = [[FetchSpark alloc]init];
    request.sign = [MSIMTools sharedInstance].adjustLocalTimeInterval;
    MSLog(@"[发送消息]获取首页Sparks：%@",request);
    [self send:[request data] protoType:XMChatProtoTypeGetSpark needToEncry:NO sign:request.sign callback:^(NSInteger code, id  _Nullable response, NSString * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (code == ERR_SUCC) {
                Sparks *datas = response;
                NSMutableArray *arr = [[NSMutableArray alloc]init];
                for (Spark *s in datas.sparksArray) {
                    MSProfileInfo *info = [MSProfileInfo createWithSpark:s];
                    [arr addObject:info];
                }
                [[MSProfileProvider provider]updateSparkProfiles:arr];
                if (succ) succ(arr);
            }else {
                if (fail) fail(code,error);
            }
        });
    }];
}

///模拟获取用户的token  for demo
- (void)getIMToken:(NSString *)phone
              succ:(void(^)(NSString *userToken))succ
            failed:(MSIMFail)fail
{
    GetImToken *token = [[GetImToken alloc]init];
    token.sign = [MSIMTools sharedInstance].adjustLocalTimeInterval;
    token.phone = [phone integerValue];
    MSLog(@"[发送消息]获取im-token：%@",token);
    [self send:[token data] protoType:CMChatProtoTypeGetImToken needToEncry:NO sign:token.sign callback:^(NSInteger code, id  _Nullable response, NSString * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            Result *result = response;
            if (code == ERR_SUCC) {
                if (succ) succ(result.msg);
            }else {
                if (fail) fail(result.code,result.msg);
            }
        });
    }];
}

///模拟用户注册
- (void)userSignUp:(NSString *)phone
          nickName:(NSString *)nickName
            avatar:(NSString *)avatar
              succ:(void(^)(NSString *userToken))succ
            failed:(MSIMFail)fail
{
    Signup *request = [[Signup alloc]init];
    request.sign = [MSIMTools sharedInstance].adjustLocalTimeInterval;
    request.phone = [phone integerValue];
    request.nickName = nickName;
    request.avatar = avatar;
    request.pic = avatar;
    request.verified = YES;
    request.gold = YES;
    MSLog(@"[发送消息]用户注册signUp：%@",request);
    [self send:[request data] protoType:XMChatProtoTypeSignup needToEncry:NO sign:request.sign callback:^(NSInteger code, id  _Nullable response, NSString * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            Result *result = response;
            if (code == ERR_SUCC) {
                if (succ) succ(result.msg);
                //注册成功,同步下自己的Profile
                MSProfileInfo *me = [[MSProfileInfo alloc]init];
                me.user_id = [MSIMTools sharedInstance].user_id;
                [[MSProfileProvider provider]synchronizeProfiles:@[me].mutableCopy];
            }else {
                if (fail) fail(result.code,result.msg);
            }
        });
    }];
}

@end
