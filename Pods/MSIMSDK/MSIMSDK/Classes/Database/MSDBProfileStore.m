//
//  MSDBProfileStore.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/15.
//

#import "MSDBProfileStore.h"
#import "FMDB.h"
#import "MSDBManager.h"
#import "MSIMConst.h"


static NSString *PROFILE_TABLE_NAME = @"profile";

@implementation MSDBProfileStore

- (FMDatabaseQueue *)dbQueue
{
    return [MSDBManager sharedInstance].commonQueue;
}

///向数据库中添加批量记录
- (void)addProfiles:(NSArray<MSProfileInfo *> *)profiles
{
    NSString *createSQL = [NSString stringWithFormat:@"create table if not exists %@(uid TEXT,update_time INTEGER,nick_name TEXT,avatar TEXT,gold bool,verified bool,ext TEXT,PRIMARY KEY(uid))",PROFILE_TABLE_NAME];
    BOOL isOK = [self createTable:PROFILE_TABLE_NAME withSQL:createSQL];
    if (isOK == NO) {
        NSLog(@"创建表失败****%@",PROFILE_TABLE_NAME);
        return;
    }
    [self.dbQueue inDeferredTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        NSString *addSQL = @"replace into %@ (uid,update_time,nick_name,avatar,gold,verified,ext) VALUES (?,?,?,?,?,?,?)";
        NSString *sqlStr = [NSString stringWithFormat:addSQL,PROFILE_TABLE_NAME];
        for (MSProfileInfo *profile in profiles) {
            NSArray *addParams = @[profile.user_id,
                                   @(profile.update_time),
                                   profile.nick_name,
                                   profile.avatar,
                                   @(profile.gold),
                                   @(profile.verified),
                                   @""];
            [db executeUpdate:sqlStr withArgumentsInArray:addParams];
        }
    }];
}

///查找某一条prifle
- (MSProfileInfo *)searchProfile:(NSString *)user_id
{
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@ where uid = '%@'",PROFILE_TABLE_NAME,user_id];
    __block MSProfileInfo *profile = nil;
    WS(weakSelf)
    [self excuteQuerySQL:sqlStr resultBlock:^(FMResultSet * _Nonnull rsSet) {
        while ([rsSet next]) {
            profile = [weakSelf ms_component:rsSet];
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
    WS(weakSelf)
    [self excuteQuerySQL:sqlStr resultBlock:^(FMResultSet * _Nonnull rsSet) {
        while ([rsSet next]) {
            MSProfileInfo *info = [weakSelf ms_component:rsSet];
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
