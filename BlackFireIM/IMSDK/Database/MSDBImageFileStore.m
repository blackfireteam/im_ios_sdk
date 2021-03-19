//
//  MSDBImageFileStore.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/18.
//

#import "MSDBImageFileStore.h"
#import "MSDBManager.h"
#import "MSIMConst.h"
#import <FMDB.h>


static NSString *FILE_TABLE_NAME = @"file";
@implementation MSDBImageFileStore

- (FMDatabaseQueue *)dbQueue
{
    return [MSDBManager sharedInstance].commonQueue;
}

///向数据库中添加一条记录
- (BOOL)addRecord:(MSImageInfo *)info
{
    if (info == nil || info.uuid.length == 0 || info.url.length == 0) {
        return NO;
    }
    NSString *createSQL = [NSString stringWithFormat:@"create table if not exists %@(uuid TEXT,url TEXT,path TEXT,width INTEGER,height INTEGER,size INTEGER,PRIMARY KEY(uuid))",FILE_TABLE_NAME];
    BOOL isOK = [self createTable:FILE_TABLE_NAME withSQL:createSQL];
    if (isOK == NO) {
        NSLog(@"创建表失败****%@",FILE_TABLE_NAME);
        return NO;
    }
    NSString *addSQL = @"REPLACE into %@ (uuid,url,path,width,height,size) VALUES (?,?,?,?,?,?)";
    NSString *sqlStr = [NSString stringWithFormat:addSQL,FILE_TABLE_NAME];
    NSArray *addParams = @[info.uuid,
                           XMNoNilString(info.url),
                           XMNoNilString(info.path),
                           @(info.width),
                           @(info.height),
                           @(info.size)];
    BOOL isAddOK = [self excuteSQL:sqlStr withArrParameter:addParams];
    return isAddOK;
}

///查找某一条记录
- (MSImageInfo *)searchRecord:(NSString *)key
{
    if (key.length == 0) {
        return nil;
    }
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@ where uuid = '%@'",FILE_TABLE_NAME,key];
    __block MSImageInfo *info = nil;
    [self excuteQuerySQL:sqlStr resultBlock:^(FMResultSet * _Nonnull rsSet) {
        while ([rsSet next]) {
            info = [[MSImageInfo alloc]init];
            info.uuid = [rsSet stringForColumn:@"uuid"];
            info.url = [rsSet stringForColumn:@"url"];
            info.path = [rsSet stringForColumn:@"path"];
            info.width = [rsSet intForColumn:@"width"];
            info.height = [rsSet intForColumn:@"height"];
            info.size = [rsSet intForColumn:@"size"];
        }
        [rsSet close];
    }];
    return info;
}

///删除某一条记录
- (BOOL)deleteRecord:(NSString *)key
{
    if (key.length == 0) {
        return NO;
    }
    NSString *sqlString = [NSString stringWithFormat:@"DELETE FROM %@ WHERE uuid = '%@'", FILE_TABLE_NAME, key];
    BOOL ok = [self excuteSQL:sqlString];
    return ok;
}


@end


@implementation MSImageInfo



@end
