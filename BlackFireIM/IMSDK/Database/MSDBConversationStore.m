//
//  MSDBConversationStore.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/3.
//

#import "MSDBConversationStore.h"
#import "MSIMConversation.h"
#import <FMDB.h>

static NSString *CONV_TABLE_NAME = @"conversation";

@implementation MSDBConversationStore

///添加会话记录
- (BOOL)addConversation:(MSIMConversation *)conv
{
    if (conv == nil || conv.conversation_id.length == 0) {
        return NO;
    }
    BOOL isOK = [self createTable];
    if (isOK == NO) {
        return NO;
    }
    NSString *addSQL = @"REPLACE into %@ (conv_id,chat_type,f_id,msg_start,msg_end,show_msg_id,msg_last_read,unread_count,ext) VALUES (?,?,?,?,?,?,?,?,?)";
    NSString *sqlStr = [NSString stringWithFormat:addSQL,CONV_TABLE_NAME];
    NSArray *addParams = @[conv.conversation_id,
                           @(conv.chat_type),
                           conv.partner_id,
                           @(conv.msg_start),
                           @(conv.msg_end),
                           @(conv.show_msg_id),
                           @(conv.msg_last_read),
                           @(conv.unread_count),
                           conv.extString];
    BOOL isAddOK = [self excuteSQL:sqlStr withArrParameter:addParams];
    return isAddOK;
}

- (BOOL)createTable
{
    NSString *createSQL = [NSString stringWithFormat:@"create table if not exists %@(conv_id TEXT,chat_type INTEGER,f_id TEXT,msg_start INTEGER,msg_end INTEGER,show_msg_id INTEGER,msg_last_read INTEGER,unread_count INTEGER,ext TEXT,PRIMARY KEY(conv_id))",CONV_TABLE_NAME];
    BOOL isOK = [self createTable:CONV_TABLE_NAME withSQL:createSQL];
    if (isOK == NO) {
        NSLog(@"创建表失败****%@",CONV_TABLE_NAME);
    }
    return isOK;
}

///批量添加会话记录
- (BOOL)addConversations:(NSArray<MSIMConversation *> *)convs
{
    BOOL isOK = YES;
    for (MSIMConversation *conv in convs) {
        BOOL isAdd = [self addConversation:conv];
        if (isAdd == NO) {
            isOK = isAdd;
        }
    }
    return isOK;
}

///更新会话记录未读数
- (BOOL)updateConvesation:(NSString *)conv_id unread_count:(NSInteger)count
{
    NSString *sqlStr = [NSString stringWithFormat:@"update %@ set unread_count = '%zd' where conv_id = '%@'",CONV_TABLE_NAME,count,conv_id];
    BOOL isOK = [self excuteSQL:sqlStr];
    return isOK;
}


///查询所有的会话记录
- (NSArray<MSIMConversation *> *)allConvesations
{
    __block NSMutableArray *convs = [[NSMutableArray alloc] init];
    NSString *sqlString = [NSString stringWithFormat: @"SELECT * FROM %@ ORDER BY show_msg_id DESC", CONV_TABLE_NAME];
    
    [self excuteQuerySQL:sqlString resultBlock:^(FMResultSet * _Nonnull rsSet) {
        while ([rsSet next]) {
            MSIMConversation *conv = [self bf_component_conv:rsSet];
            [convs addObject:conv];
        }
        [rsSet close];
    }];
    return convs;
}

/// 分页获取会话记录
- (void)conversationsWithLast_msg_id:(NSInteger)last_msg_id
                               count:(NSInteger)count
                            complete:(void(^)(NSArray<MSIMConversation *> *data,BOOL hasMore))complete
{
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@ where msg_end < '%zd' and order by msg_end desc limit '%zd'",CONV_TABLE_NAME,last_msg_id,count+1];
    __block NSMutableArray *data = [[NSMutableArray alloc] init];
    [self excuteQuerySQL:sqlStr resultBlock:^(FMResultSet * _Nonnull rsSet) {
        while ([rsSet next]) {
            [data addObject:[self bf_component_conv:rsSet]];
        }
        [rsSet close];
    }];
    BOOL hasMore = NO;
    if (data.count == count + 1) {
        hasMore = YES;
        [data removeObjectAtIndex:0];
    }
    complete(data,hasMore);
}

- (MSIMConversation *)bf_component_conv:(FMResultSet *)rsSet
{
    MSIMConversation *conv = [[MSIMConversation alloc]init];
    conv.partner_id = [rsSet stringForColumn:@"f_id"];
    conv.chat_type = [rsSet intForColumn:@"chat_type"];
    conv.msg_start = [rsSet longLongIntForColumn:@"msg_start"];
    conv.msg_end = [rsSet longLongIntForColumn:@"msg_end"];
    conv.show_msg_id = [rsSet longLongIntForColumn:@"show_msg_id"];
    conv.msg_last_read = [rsSet longLongIntForColumn:@"msg_last_read"];
    conv.unread_count = [rsSet intForColumn:@"unread_count"];
    NSString *extString = [rsSet stringForColumn:@"ext"];
    NSData *data = [extString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    conv.ext = [[MSCustomExt alloc]initWithDictionary:dic];
    return conv;
}

///删除某一条会话，不清空聊天记录
- (BOOL)deleteConversation:(NSString *)conv_id
{
    NSString *sqlString = [NSString stringWithFormat:@"DELETE FROM %@ WHERE conv_id = '%@'", CONV_TABLE_NAME, conv_id];
    BOOL ok = [self excuteSQL:sqlString];
    return ok;
}

///查询会话列表中最新的一条msg_id。用于跟服务器同步增量更新
- (NSInteger)lastMessageEnd
{
    __block NSInteger msg_end = 0;
    NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ order by msg_end desc limit 1", CONV_TABLE_NAME];
    [self excuteQuerySQL:sqlString resultBlock:^(FMResultSet * _Nonnull rsSet) {
        while ([rsSet next]) {
            msg_end = [rsSet longLongIntForColumn:@"msg_end"];
        }
    }];
    return msg_end;
}

@end
