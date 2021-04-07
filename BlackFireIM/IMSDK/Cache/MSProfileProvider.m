//
//  BFProfileProvider.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/15.
//

#import "MSProfileProvider.h"
#import "MSDBProfileStore.h"
#import "ChatProtobuf.pbobjc.h"
#import "MSIMManager.h"
#import "MSIMTools.h"
#import "MSIMErrorCode.h"

@interface MSProfileProvider()

@property(nonatomic,strong) NSCache *mainCache;
@property(nonatomic,strong) MSDBProfileStore *store;

@end
@implementation MSProfileProvider

///单例
static MSProfileProvider *instance;
+ (instancetype)provider
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[MSProfileProvider alloc]init];
    });
    return instance;
}

- (NSCache *)mainCache
{
    if (!_mainCache) {
        _mainCache = [[NSCache alloc] init];
        _mainCache.countLimit = 1000; // 限制个数，默认是0，无限空间
        _mainCache.totalCostLimit = 0; // 设置大小设置，默认是0，无限空间
        _mainCache.name = @"profile_cache";
    }
    return _mainCache;
}

- (MSDBProfileStore *)store
{
    if (!_store) {
        _store = [[MSDBProfileStore alloc]init];
    }
    return _store;
}

/// 查询某个用户的个人信息
/// @param user_id 用户uid
/// @param completed 异步返回查询结果。
- (void)providerProfile:(NSInteger)user_id
               complete:(void(^)(MSProfileInfo *profile))completed
{
    NSString *uid = [NSString stringWithFormat:@"%zd",user_id];
    MSProfileInfo *p = [self.mainCache objectForKey:uid];
    if (p) {
        completed(p);
    }else {
        //从数据库取
        MSProfileInfo *p1 = [self.store searchProfile:uid];
        if (p1) {
            completed(p1);
            [self.mainCache setObject:p1 forKey:uid];
        }else {
            //服务器请求
            GetProfile *getP = [[GetProfile alloc]init];
            getP.uid = [uid integerValue];
            getP.updateTime = 0;
            getP.sign = [MSIMTools sharedInstance].adjustLocalTimeInterval;
            NSLog(@"[发送消息]GetProfile: %@",getP);
            [[MSIMManager sharedInstance]send:[getP data] protoType:XMChatProtoTypeGetProfile needToEncry:NO sign:getP.sign callback:^(NSInteger code, id  _Nullable response, NSString * _Nullable error) {
                            if (code == ERR_SUCC) {
                                Profile *profile = response;
                                MSProfileInfo *info = [MSProfileInfo createWithProto:profile];
                                BOOL isOK = [self.store addProfile:info];
                                if (isOK) {
                                    [self.mainCache setObject:info forKey:uid];
                                }
                                completed(info);
                            }
            }];
        }
    }
}

///只从本地查询用户的个人信息
- (MSProfileInfo *)providerProfileFromLocal:(NSInteger)user_id
{
    NSString *uid = [NSString stringWithFormat:@"%zd",user_id];
    MSProfileInfo *p = [self.mainCache objectForKey:uid];
    if (p) {
        return p;
    }else {
        MSProfileInfo *p1 = [self.store searchProfile:uid];
        return p1;
    }
    return nil;
}

///更新用户信息
- (void)updateProfile:(MSProfileInfo *)info
{
    if (info.user_id.length == 0) return;
    [self.mainCache setObject:info forKey:info.user_id];
    [self.store addProfile:info];
}

///返回本地数据库中所有的用户信息
- (NSArray<MSProfileInfo *> *)allProfiles
{
    return [self.store allProfiles];
}

///比对update_time与服务器同步更新用户信息
///批量请求，100个一组
- (void)synchronizeProfiles:(NSArray<MSProfileInfo *> *)profiles
{
    [self componentRequestWithProfiles:profiles];
}

- (void)componentRequestWithProfiles:(NSArray *)arr
{
    if (arr.count <= 0) {
        return;
    }
    NSArray *plitArr;
    if (arr.count > 100) {
        plitArr = [arr subarrayWithRange:NSMakeRange(0, 100)];
    }else {
        plitArr = arr;
    }
    NSMutableArray *pArr = [NSMutableArray array];
    GetProfiles *request = [[GetProfiles alloc]init];
    for (MSProfileInfo *info in plitArr) {
        GetProfile *pR = [[GetProfile alloc]init];
        pR.updateTime = info.update_time;
        pR.uid = [info.user_id integerValue];
        [pArr addObject:pR];
    }
    request.getProfilesArray = pArr;
    request.sign = [MSIMTools sharedInstance].adjustLocalTimeInterval;
    NSLog(@"[发送消息]GetProfiles:\n%@",request);
    [[MSIMManager sharedInstance]send:[request data] protoType:XMChatProtoTypeGetProfiles needToEncry:NO sign:request.sign callback:^(NSInteger code, id  _Nullable response, NSString * _Nullable error) {
        if (code == ERR_SUCC) {
            
        }
    }];
    if (arr.count > 100) {
        NSArray *leftArr = [arr subarrayWithRange:NSMakeRange(100, arr.count-100)];
        [self componentRequestWithProfiles:leftArr];
    }
}

@end
