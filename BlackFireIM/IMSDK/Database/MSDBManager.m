//
//  MSDBManager.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/2.
//

#import "MSDBManager.h"
#import <FMDB.h>
#import "MSIMTools.h"
#import "NSFileManager+filePath.h"
#import "MSDBMessageStore.h"


@interface MSDBManager()


@end
@implementation MSDBManager

static MSDBManager *manager;
+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[MSDBManager alloc]init];
    });
    return manager;
}

- (FMDatabaseQueue *)messageQueue
{
    if(!_messageQueue) {
        if([MSIMTools sharedInstance].user_id) {
            NSString *messageQueuePath = [NSFileManager pathDBMessage];
            _messageQueue = [FMDatabaseQueue databaseQueueWithPath:messageQueuePath];
        }
    }
    return _messageQueue;
}

- (FMDatabaseQueue *)commonQueue
{
    if(!_commonQueue) {
        if([MSIMTools sharedInstance].user_id) {
            NSString *commonQueuePath = [NSFileManager pathDBCommon];
            _commonQueue = [FMDatabaseQueue databaseQueueWithPath:commonQueuePath];
        }
    }
    return _commonQueue;
}

- (void)accountChanged
{
    [self scanAllTables];
    [_messageQueue close];
    _messageQueue = nil;
}

///app启动或切换帐号时，扫描消息数据库中所有消息表，将消息发送中状态的消息改成发送失败
- (void)scanAllTables
{
    __block NSMutableArray *tables = [NSMutableArray array];
    [self.messageQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM sqlite_master where type='table';"];
        while ([resultSet next]) {
            NSString *tableName = [resultSet stringForColumnIndex:1];
            [tables addObject:tableName];
        }
        [resultSet close];
    }];
    MSDBMessageStore *msgStore = [[MSDBMessageStore alloc]init];
    for (NSString *tableName in tables) {
        if ([tableName hasPrefix:@"message_user_"]) {
            [msgStore cleanAllSendingMessage:tableName];
        }
    }
}

@end
