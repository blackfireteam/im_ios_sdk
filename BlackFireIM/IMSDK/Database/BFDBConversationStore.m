//
//  BFDBConversationStore.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/3.
//

#import "BFDBConversationStore.h"
#import "BFDBManager.h"
#import "BFConversation.h"
#import <FMDB.h>


static NSString *CONV_TABLE_NAME = @"conversation";
static NSString *conv_id = @"conv_id";
static NSString *f_id = @"f_id";
static NSString *last_sign = @"last_sign";
static NSString *unread_count = @"unread_count";
static NSString *send_status = @"send_status";
static NSString *content = @"content";

@implementation BFDBConversationStore

///添加会话记录
- (BOOL)addConversation:(BFConversation *)conv
{
    NSString *createSQL = [NSString stringWithFormat:@"create table if not exists %@(conv_id INTEGER,f_id INTEGER,last_sign INTEGER,unread_count INTEGER,send_status INTEGER,content TEXT,PRIMARY KEY(conv_id,f_id))",CONV_TABLE_NAME];
    BOOL isOK = [[BFDBManager sharedInstance] createTable:CONV_TABLE_NAME withSQL:createSQL];
    if (isOK == NO) {
        NSLog(@"创建表失败****%@",CONV_TABLE_NAME);
        return NO;
    }
    NSString *addSQL = @"REPLACE into %@ (conv_id,f_id,last_sign,unread_count,send_status,content) VALUES (?,?,?,?,?,?)";
    NSString *sqlStr = [NSString stringWithFormat:addSQL,CONV_TABLE_NAME];
    NSArray *addParams = @[@(conv.conversation_id),@(conv.partner_id),@(conv.last_msg_seq),@(conv.unreadCount),@(conv.sendStatus),conv.content];
    BOOL isAddOK = [[BFDBManager sharedInstance] excuteSQL:sqlStr withArrParameter:addParams];
    return isAddOK;
}

///更新会话记录未读数
- (BOOL)updateConvesation:(NSInteger)conv_id partner_id:(NSInteger)f_id unread_count:(NSInteger)count
{
    NSString *sqlStr = [NSString stringWithFormat:@"update %@ set unread_count = '%zd' where conv_id = '%zd' and f_id = '%zd'",CONV_TABLE_NAME,count,conv_id,f_id];
    BOOL isOK = [[BFDBManager sharedInstance] excuteSQL:sqlStr];
    return isOK;
}

///更新会话消息发送状态
- (BOOL)updateConvesation:(NSInteger)conv_id partner_id:(NSInteger)f_id send_status:(BFIMMessageStatus)status
{
    NSString *sqlStr = [NSString stringWithFormat:@"update %@ set send_status = '%zd' where conv_id = '%zd' and f_id = '%zd'",CONV_TABLE_NAME,status,conv_id,f_id];
    BOOL isOK = [[BFDBManager sharedInstance] excuteSQL:sqlStr];
    return isOK;
}

///查询所有的会话记录
- (NSArray<BFConversation *> *)allConvesations
{
    __block NSMutableArray *data = [[NSMutableArray alloc] init];
    NSString *sqlString = [NSString stringWithFormat: @"SELECT * FROM %@ ORDER BY conv_id DESC", CONV_TABLE_NAME];
    
    [[BFDBManager sharedInstance] excuteQuerySQL:sqlString resultBlock:^(FMResultSet * _Nonnull rsSet) {
        while ([rsSet next]) {
            BFConversation *conv = [[BFConversation alloc]init];
            conv.conversation_id = [rsSet longLongIntForColumn:conv_id];
            conv.partner_id = [rsSet longLongIntForColumn:f_id];
            conv.unreadCount = [rsSet intForColumn:unread_count];
            conv.last_msg_seq = [rsSet longLongIntForColumn:last_sign];
            conv.sendStatus = [rsSet intForColumn:unread_count];
            conv.content = [rsSet stringForColumn:content];
            [data addObject:conv];
        }
        [rsSet close];
    }];
    return data;
}

///删除某一条会话，不清空聊天记录
- (BOOL)deleteConversation:(NSInteger)conv_id partner_id:(NSInteger)f_id
{
    NSString *sqlString = [NSString stringWithFormat:@"DELETE FROM %@ WHERE conv_id = '%zd' and f_id = '%zd'", CONV_TABLE_NAME, conv_id, f_id];
    BOOL ok = [[BFDBManager sharedInstance] excuteSQL:sqlString];
    return ok;
}

@end
