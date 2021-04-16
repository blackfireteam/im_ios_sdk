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
    HDNormalLog(@"[发送消息]获取首页Sparks：%@",request);
    [self send:[request data] protoType:XMChatProtoTypeGetSpark needToEncry:NO sign:request.sign callback:^(NSInteger code, id  _Nullable response, NSString * _Nullable error) {
        if (code == ERR_SUCC) {
            Sparks *datas = response;
            NSMutableArray *arr = [[NSMutableArray alloc]init];
            for (Spark *s in datas.sparksArray) {
                MSProfileInfo *info = [MSProfileInfo createWithSpark:s];
                [arr addObject:info];
                //更新profile
                [[MSProfileProvider provider]updateProfile:info];
            }
            if (succ) succ(arr);
        }else {
            if (fail) fail(code,error);
        }
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
    HDNormalLog(@"[发送消息]获取im-token：%@",token);
    [self send:[token data] protoType:CMChatProtoTypeGetImToken needToEncry:NO sign:token.sign callback:^(NSInteger code, id  _Nullable response, NSString * _Nullable error) {
        Result *result = response;
        if (code == ERR_SUCC) {
            if (succ) succ(result.msg);
        }else {
            if (fail) fail(result.code,result.msg);
        }
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
    HDNormalLog(@"[发送消息]用户注册signUp：%@",request);
    [self send:[request data] protoType:XMChatProtoTypeSignup needToEncry:NO sign:request.sign callback:^(NSInteger code, id  _Nullable response, NSString * _Nullable error) {
        Result *result = response;
        if (code == ERR_SUCC) {
            if (succ) succ(result.msg);
        }else {
            if (fail) fail(result.code,result.msg);
        }
    }];
}

@end
