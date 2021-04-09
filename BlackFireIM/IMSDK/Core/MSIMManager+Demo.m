//
//  MSIMManager+Demo.m
//  BlackFireIM
//
//  Created by benny wang on 2021/4/9.
//

#import "MSIMManager+Demo.h"
#import "MSIMTools.h"
#import "MSIMErrorCode.h"
#import "MSProfileInfo.h"

@implementation MSIMManager (Demo)

///获取首页Spark相关数据
- (void)getSparks:(void(^)(NSArray<MSProfileInfo *> *sparks))succ
             fail:(MSIMFail)fail
{
    FetchSpark *request = [[FetchSpark alloc]init];
    request.sign = [MSIMTools sharedInstance].adjustLocalTimeInterval;
    NSLog(@"[发送消息]获取首页Sparks：%@",request);
    [self send:[request data] protoType:XMChatProtoTypeGetSpark needToEncry:NO sign:request.sign callback:^(NSInteger code, id  _Nullable response, NSString * _Nullable error) {
        if (code == ERR_SUCC) {
            Sparks *datas = response;
            NSMutableArray *arr = [[NSMutableArray alloc]init];
            for (Spark *s in datas.sparksArray) {
                MSProfileInfo *info = [MSProfileInfo createWithSpark:s];
                [arr addObject:info];
            }
            if (succ) succ(arr);
        }else {
            if (fail) fail(code,error);
        }
    }];
}
@end
