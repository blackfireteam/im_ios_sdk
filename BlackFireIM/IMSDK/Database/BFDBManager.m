//
//  BFDBManager.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/2.
//

#import "BFDBManager.h"
#import <FMDB.h>
#import "BFIMTools.h"
#import "NSFileManager+filePath.h"

@interface BFDBManager()


@end
@implementation BFDBManager

static BFDBManager *manager;
+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[BFDBManager alloc]init];
    });
    return manager;
}

- (FMDatabaseQueue *)messageQueue
{
    if(!_messageQueue) {
        if([BFIMTools sharedInstance].user_id) {
            NSString *messageQueuePath = [NSFileManager pathDBMessage];
            _messageQueue = [FMDatabaseQueue databaseQueueWithPath:messageQueuePath];
        }
    }
    return _messageQueue;
}

- (BOOL)createTable:(NSString *)tableName withSQL:(NSString *)sqlString
{
    __block BOOL ok = YES;
    [self.messageQueue inDatabase:^(FMDatabase *db) {
        if(![db tableExists:tableName]){
            ok = [db executeUpdate:sqlString];
        }
    }];
    return ok;
}

/**
*  判断表中是否存在该字段，如果不存在则添加
*/
- (BOOL)inertColumnInTable:(NSString *)tableName columnName:(NSString *)columnName
{
    __block BOOL ok = NO;
    if(self.messageQueue) {
        [self.messageQueue inDatabase:^(FMDatabase *db) {
            if(![db columnExists:columnName inTableWithName:tableName]) {
                NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT",tableName,columnName];
                ok = [db executeUpdate:sql];
            }else {
                ok = YES;
            }
        }];
    }
    return ok;
}

- (BOOL)excuteSQL:(NSString *)sqlString withArrParameter:(NSArray *)arrParameter
{
    __block BOOL ok = NO;
    if (self.messageQueue) {
        [self.messageQueue inDatabase:^(FMDatabase *db) {
            ok = [db executeUpdate:sqlString withArgumentsInArray:arrParameter];
        }];
    }
    return ok;
}

- (BOOL)excuteSQL:(NSString *)sqlString withDicParameter:(NSDictionary *)dicParameter
{
    __block BOOL ok = NO;
    if (self.messageQueue) {
        [self.messageQueue inDatabase:^(FMDatabase *db) {
            ok = [db executeUpdate:sqlString withParameterDictionary:dicParameter];
        }];
    }
    return ok;
}

- (BOOL)excuteSQL:(NSString *)sqlString,...
{
    __block BOOL ok = NO;
    if (self.messageQueue) {
        va_list args;
        va_list *p_args;
        p_args = &args;
        va_start(args, sqlString);
        [self.messageQueue inDatabase:^(FMDatabase *db) {
            ok = [db executeUpdate:sqlString withVAList:*p_args];
        }];
        va_end(args);
    }
    return ok;
}

- (void)excuteQuerySQL:(NSString*)sqlStr resultBlock:(void(^)(FMResultSet * rsSet))resultBlock
{
    if (self.messageQueue) {
        [self.messageQueue inDatabase:^(FMDatabase *db) {
            FMResultSet * retSet = [db executeQuery:sqlStr];
            if (resultBlock) {
                resultBlock(retSet);
            }
        }];
    }
}

- (void)accountChanged
{
    [_messageQueue close];
    _messageQueue = nil;
}

@end
