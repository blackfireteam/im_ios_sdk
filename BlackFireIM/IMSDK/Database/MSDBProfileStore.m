//
//  MSDBProfileStore.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/15.
//

#import "MSDBProfileStore.h"
#import <FMDB.h>
#import "MSDBManager.h"


static NSString *PROFILE_TABLE_NAME = @"profile";

@implementation MSDBProfileStore

- (FMDatabaseQueue *)dbQueue
{
    return [MSDBManager sharedInstance].commonQueue;
}

///向数据库中添加一条记录
- (BOOL)addProfile:(MSProfileInfo *)profile
{
    NSString *createSQL = [NSString stringWithFormat:@"create table if not exists %@(uid TEXT,update_time INTEGER,nick_name TEXT,avatar TEXT,gold bool,verified bool,ext TEXT,PRIMARY KEY(uid))",PROFILE_TABLE_NAME];
    BOOL isOK = [self createTable:PROFILE_TABLE_NAME withSQL:createSQL];
    if (isOK == NO) {
        NSLog(@"创建表失败****%@",PROFILE_TABLE_NAME);
        return NO;
    }
    NSString *addSQL = @"REPLACE into %@ (uid,update_time,nick_name,avatar,gold,verified,ext) VALUES (?,?,?,?,?,?,?)";
    NSString *sqlStr = [NSString stringWithFormat:addSQL,PROFILE_TABLE_NAME];
    NSArray *addParams = @[profile.user_id,
                           @(profile.update_time),
                           profile.nick_name,
                           profile.avatar,
                           @(profile.gold),
                           @(profile.verified),
                           @""];
    BOOL isAddOK = [self excuteSQL:sqlStr withArrParameter:addParams];
    return isAddOK;
}

///向数据库中添加批量记录
- (BOOL)addProfiles:(NSArray<MSProfileInfo *> *)profiles
{
    BOOL isOK = YES;
    for (MSProfileInfo *profile in profiles) {
        BOOL isAdd = [self addProfile:profile];
        if (isAdd == NO) {
            isOK = isAdd;
        }
    }
    return isOK;
}

///查找某一条prifle
- (MSProfileInfo *)searchProfile:(NSString *)user_id
{
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@ where uid = '%@'",PROFILE_TABLE_NAME,user_id];
    __block MSProfileInfo *profile = nil;
    [self excuteQuerySQL:sqlStr resultBlock:^(FMResultSet * _Nonnull rsSet) {
        while ([rsSet next]) {
            profile = [self ms_component:rsSet];
        }
        [rsSet close];
    }];
    return profile;
}

///返回数据库中所有的记录
- (NSArray *)allProfiles
{
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@",PROFILE_TABLE_NAME];
    __block NSMutableArray *profiles = [NSMutableArray array];
    [self excuteQuerySQL:sqlStr resultBlock:^(FMResultSet * _Nonnull rsSet) {
        while ([rsSet next]) {
            MSProfileInfo *info = [self ms_component:rsSet];
            [profiles addObject:info];
        }
        [rsSet close];
    }];
    return profiles;
}

- (MSProfileInfo *)ms_component:(FMResultSet *)rsSet
{
    MSProfileInfo *p = [[MSProfileInfo alloc]init];
    p.user_id = [rsSet stringForColumn:@"uid"];
    p.update_time = [rsSet longLongIntForColumn:@"update_time"];
    p.nick_name = [rsSet stringForColumn:@"nick_name"];
    p.avatar = [rsSet stringForColumn:@"avatar"];
    p.gold = [rsSet boolForColumn:@"gold"];
    p.verified = [rsSet boolForColumn:@"verified"];
    return p;
}

@end
