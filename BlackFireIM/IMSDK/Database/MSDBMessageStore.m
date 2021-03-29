//
//  MSDBMessageStore.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/2.
//

#import "MSDBMessageStore.h"
#import <FMDB.h>
#import "NSString+Ext.h"
#import "ChatProtobuf.pbobjc.h"
#import "MSIMTools.h"
#import "MSIMManager.h"
#import "MSIMErrorCode.h"
#import "NSDictionary+Ext.h"
#import "MSDBConversationStore.h"
#import "MSIMConversation.h"
#import "MSConversationProvider.h"
#import "MSIMManager+Parse.h"

static NSString *msg_id = @"msg_id";
static NSString *msg_sign = @"msg_sign";
static NSString *f_id = @"f_id";
static NSString *t_id = @"t_id";
static NSString *msg_type = @"msg_type";
static NSString *send_status = @"send_status";
static NSString *read_status = @"read_status";
static NSString *block_id = @"block_id";
static NSString *code = @"code";
static NSString *reason = @"reason";
static NSString *ext_data = @"ext_data";
@implementation MSDBMessageStore

///向数据库中添加一条记录
- (BOOL)addMessage:(MSIMElem *)elem
{
    NSString *fid = elem.partner_id;
    NSString *tableName = [NSString stringWithFormat:@"message_user_%@",fid];
    NSString *createSQL = [NSString stringWithFormat:@"create table if not exists %@(msg_id INTEGER,msg_sign INTEGER NOT NULL,f_id TEXT,t_id TEXT,msg_type INTEGER,send_status INTEGER,read_status INTEGER,code INTEGER,reason TEXT,block_id INTEGER NOT NULL,ext_data TEXT,PRIMARY KEY(msg_sign))",tableName];
    BOOL isOK = [self createTable:tableName withSQL:createSQL];
    if (isOK == NO) {
        NSLog(@"创建表失败****%@",tableName);
        return NO;
    }
    MSIMElem *lastContainMsgIDElem = [self lastMessageID:fid];
    NSInteger block_id = 1;
    if (lastContainMsgIDElem) {
        if (elem.msg_id != 0) {
            MSIMElem *nextElem = [self searchMessage:fid msg_id:elem.msg_id+1];
            MSIMElem *preElem = [self searchMessage:fid msg_id:elem.msg_id-1];
            if (nextElem && preElem) {
                block_id = nextElem.block_id;
                [self updateBlockID:preElem.block_id toBlockID:nextElem.block_id partnerID:fid];
            }else if (nextElem) {
                block_id = nextElem.block_id;
            }else if (preElem) {
                block_id = preElem.block_id;
            }else {
                block_id = [self maxBlockID:fid] + 1;
            }
        }else {
            block_id = [self maxBlockID:fid];
        }
    }
    NSString *addSQL = @"replace into %@ (msg_id,msg_sign,f_id,t_id,msg_type,send_status,read_status,code,reason,block_id,ext_data) VALUES (?,?,?,?,?,?,?,?,?,?,?)";
    NSString *sqlStr = [NSString stringWithFormat:addSQL,tableName];
    NSArray *addParams = @[@(elem.msg_id),
                           @(elem.msg_sign),
                           elem.fromUid,
                           elem.toUid,
                           @(elem.type),
                           @(elem.sendStatus),
                           @(elem.readStatus),
                           @(elem.code),
                           XMNoNilString(elem.reason),
                           @(block_id),
                           XMNoNilString([elem.contentDic el_convertJsonString])];
    BOOL isAddOK = [self excuteSQL:sqlStr withArrParameter:addParams];
    return isAddOK;
}

///向数据库中添加批量记录
- (BOOL)addMessages:(NSArray<MSIMElem *> *)elems
{
    BOOL isOK = YES;
    for (MSIMElem *elem in elems) {
        BOOL isAdd = [self addMessage:elem];
        if (isAdd == NO) {
            isOK = isAdd;
        }
    }
    return isOK;
}

///标记某一条消息为撤回消息
- (BOOL)updateMessageRevoke:(NSInteger)msg_id partnerID:(NSString *)partnerID
{
    NSString *tableName = [NSString stringWithFormat:@"message_user_%@",partnerID];
    NSString *sqlStr = [NSString stringWithFormat:@"update %@ set msg_type = '%zd' where msg_id = '%zd'",tableName,BFIM_MSG_TYPE_REVOKE,msg_id];
    BOOL isOK = [self excuteSQL:sqlStr];
    return isOK;
}

///取最后一条msg_id
- (MSIMElem *)lastMessageID:(NSString *)partner_id
{
    if (partner_id.length == 0) {
        return nil;
    }
    __block MSIMElem *elem = nil;
    NSString *tableName = [NSString stringWithFormat:@"message_user_%@",partner_id];
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@ where msg_id > 0 order by msg_id desc limit 1",tableName];
    [self excuteQuerySQL:sqlStr resultBlock:^(FMResultSet * _Nonnull rsSet) {
        while ([rsSet next]) {
            elem = [self bf_componentElem:rsSet];
        }
        [rsSet close];
    }];
    return elem;
}

///取最后一条msg_sign
- (MSIMElem *)lastMessage:(NSString *)partner_id
{
    if (partner_id.length == 0) {
        return nil;
    }
    __block MSIMElem *elem = nil;
    NSString *tableName = [NSString stringWithFormat:@"message_user_%@",partner_id];
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@ order by msg_sign desc limit 1",tableName];
    WS(weakSelf)
    [self excuteQuerySQL:sqlStr resultBlock:^(FMResultSet * _Nonnull rsSet) {
        STRONG_SELF(strongSelf)
        while ([rsSet next]) {
            elem = [strongSelf bf_componentElem:rsSet];
        }
        [rsSet close];
    }];
    return elem;
}

///取最后一条可显示的消息
- (MSIMElem *)lastShowMessage:(NSString *)partner_id
{
    if (partner_id.length == 0) {
        return nil;
    }
    __block MSIMElem *elem = nil;
    NSString *tableName = [NSString stringWithFormat:@"message_user_%@",partner_id];
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@ where msg_type != '%zd' order by msg_sign desc limit 1",tableName,BFIM_MSG_TYPE_NULL];
    WS(weakSelf)
    [self excuteQuerySQL:sqlStr resultBlock:^(FMResultSet * _Nonnull rsSet) {
        STRONG_SELF(strongSelf)
        while ([rsSet next]) {
            elem = [strongSelf bf_componentElem:rsSet];
        }
        [rsSet close];
    }];
    return elem;
}

///取表中最大的block_id
- (NSInteger)maxBlockID:(NSString *)partner_id
{
    if (partner_id.length == 0) {
        return 1;
    }
    __block NSInteger block_id = 1;
    NSString *tableName = [NSString stringWithFormat:@"message_user_%@",partner_id];
    NSString *sqlStr = [NSString stringWithFormat:@"select block_id from %@ order by block_id desc limit 1",tableName];
    [self excuteQuerySQL:sqlStr resultBlock:^(FMResultSet * _Nonnull rsSet) {
        while ([rsSet next]) {
            block_id = [rsSet intForColumn:@"block_id"];
        }
        [rsSet close];
    }];
    return block_id;
}

///更新block_id
- (BOOL)updateBlockID:(NSInteger)fromBlockID toBlockID:(NSInteger)toBlockID partnerID:(NSString *)partnerID
{
    NSString *tableName = [NSString stringWithFormat:@"message_user_%@",partnerID];
    NSString *sqlStr = [NSString stringWithFormat:@"update %@ set block_id = '%zd' where block_id = '%zd'",tableName,fromBlockID,toBlockID];
    BOOL isOK = [self excuteSQL:sqlStr];
    return isOK;
}

///根据msg_id查询消息
- (MSIMElem *)searchMessage:(NSString *)partner_id msg_id:(NSInteger)msg_id
{
    if (partner_id.length == 0) {
        return nil;
    }
    __block MSIMElem *elem = nil;
    NSString *tableName = [NSString stringWithFormat:@"message_user_%@",partner_id];
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@ where msg_id = '%zd'",tableName,msg_id];
    WS(weakSelf)
    [self excuteQuerySQL:sqlStr resultBlock:^(FMResultSet * _Nonnull rsSet) {
        STRONG_SELF(strongSelf)
        while ([rsSet next]) {
            elem = [strongSelf bf_componentElem:rsSet];
        }
        [rsSet close];
    }];
    return elem;
}

///根据msg_sign查询消息
- (MSIMElem *)searchMessage:(NSString *)partner_id msg_sign:(NSInteger)msg_sign
{
    if (partner_id.length == 0) {
        return nil;
    }
    __block MSIMElem *elem = nil;
    NSString *tableName = [NSString stringWithFormat:@"message_user_%@",partner_id];
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@ where msg_sign = '%zd'",tableName,msg_sign];
    WS(weakSelf)
    [self excuteQuerySQL:sqlStr resultBlock:^(FMResultSet * _Nonnull rsSet) {
        STRONG_SELF(strongSelf)
        while ([rsSet next]) {
            elem = [strongSelf bf_componentElem:rsSet];
        }
        [rsSet close];
    }];
    return elem;
}

///更新某条消息的已读状态
- (BOOL)updateMessage:(NSInteger)msg_sign readStatus:(BFIMMessageReadStatus)status partnerID:(NSString *)partnerID
{
    NSString *tableName = [NSString stringWithFormat:@"message_user_%@",partnerID];
    NSString *sqlStr = [NSString stringWithFormat:@"update %@ set read_status = '%zd' where msg_sign = '%zd'",tableName,status,msg_sign];
    BOOL isOK = [self excuteSQL:sqlStr];
    return isOK;
}

- (BOOL)updateMessageToSuccss:(NSInteger)msg_sign
                       msg_id:(NSInteger)msg_id
                    partnerID:(NSString *)partnerID
{
    NSString *tableName = [NSString stringWithFormat:@"message_user_%@",partnerID];
    NSString *sqlStr = [NSString stringWithFormat:@"update %@ set send_status = '%zd',msg_id = '%zd' where msg_sign = '%zd'",tableName,BFIM_MSG_STATUS_SEND_SUCC,msg_id,msg_sign];
    BOOL isOK = [self excuteSQL:sqlStr];
    return isOK;
}

- (BOOL)updateMessageToFail:(NSInteger)msg_sign
                 code:(NSInteger)code
               reason:(NSString *)reason
            partnerID:(NSString *)partnerID
{
    NSString *tableName = [NSString stringWithFormat:@"message_user_%@",partnerID];
    NSString *sqlStr = [NSString stringWithFormat:@"update %@ set send_status = '%zd',code = '%zd',reason = '%@' where msg_sign = '%zd'",tableName,BFIM_MSG_STATUS_SEND_FAIL,code,XMNoNilString(reason),msg_sign];
    BOOL isOK = [self excuteSQL:sqlStr];
    return isOK;
}

- (BOOL)updateMessageToSending:(NSInteger)msg_sign
                     partnerID:(NSString *)partnerID
{
    NSString *tableName = [NSString stringWithFormat:@"message_user_%@",partnerID];
    NSString *sqlStr = [NSString stringWithFormat:@"update %@ set send_status = '%zd',code = 0,reason = '%@' where msg_sign = '%zd'",tableName,BFIM_MSG_STATUS_SENDING,@"",msg_sign];
    BOOL isOK = [self excuteSQL:sqlStr];
    return isOK;
}

- (NSArray<MSIMElem *> *)localMessageGroupByBlockID:(NSInteger)blockID partnerID:(NSString *)partnerID maxCount:(NSInteger)count
{
    NSString *tableName = [NSString stringWithFormat:@"message_user_%@",partnerID];
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@ where block_id = '%zd' order by msg_sign desc limit '%zd'",tableName,blockID,count];
    __block NSMutableArray *data = [[NSMutableArray alloc] init];
    [self excuteQuerySQL:sqlStr resultBlock:^(FMResultSet * _Nonnull rsSet) {
        while ([rsSet next]) {
            [data addObject:[self bf_componentElem:rsSet]];
        }
        [rsSet close];
    }];
    return data;
}

- (MSIMElem *)latestMessageIDBeforeMsgSign:(NSInteger)msg_sign partnerID:(NSString *)partnerID
{
    NSString *tableName = [NSString stringWithFormat:@"message_user_%@",partnerID];
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@ where msg_sign <= '%zd' and msg_id != 0 order by msg_sign desc limit 1",tableName,msg_sign];
    __block MSIMElem *elem = nil;
    [self excuteQuerySQL:sqlStr resultBlock:^(FMResultSet * _Nonnull rsSet) {
        while ([rsSet next]) {
            elem = [self bf_componentElem:rsSet];
        }
        [rsSet close];
    }];
    return elem;
}

- (MSIMElem *)greaterMessageIDBeforeMsgSign:(NSInteger)msg_sign partnerID:(NSString *)partnerID
{
    NSString *tableName = [NSString stringWithFormat:@"message_user_%@",partnerID];
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@ where msg_sign >= '%zd' and msg_id != 0 order by msg_sign asc limit 1",tableName,msg_sign];
    __block MSIMElem *elem = nil;
    [self excuteQuerySQL:sqlStr resultBlock:^(FMResultSet * _Nonnull rsSet) {
        while ([rsSet next]) {
            elem = [self bf_componentElem:rsSet];
        }
        [rsSet close];
    }];
    return elem;
}

///取出小于或等于msg_id的对方发出的消息的msg_id
- (NSInteger)latestMsgIDLessThan:(NSInteger)msg_id partner_id:(NSString *)partner_id
{
    NSString *tableName = [NSString stringWithFormat:@"message_user_%@",partner_id];
    NSString *sqlStr = [NSString stringWithFormat:@"select msg_id from %@ where msg_id <= '%zd' and f_id = '%@' and msg_id != 0 order by msg_sign desc limit 1",tableName,msg_id,partner_id];
    __block NSInteger minMsgID = 0;
    [self excuteQuerySQL:sqlStr resultBlock:^(FMResultSet * _Nonnull rsSet) {
        while ([rsSet next]) {
            minMsgID = [rsSet longLongIntForColumn:@"msg_id"];
        }
        [rsSet close];
    }];
    return minMsgID;
}

/// 分页获取聊天记录
- (void)messageByPartnerID:(NSString *)partnerID
             last_msg_sign:(NSInteger)last_msg_sign
                     count:(NSInteger)count
                  complete:(void(^)(NSArray<MSIMElem *> *data,BOOL hasMore))complete
{
    //先取出对应会话中记录的最后一条msg_id
    MSDBConversationStore *convStore = [[MSDBConversationStore alloc]init];
    MSIMConversation *conv = [convStore searchConversation:[NSString stringWithFormat:@"c2c_%@",partnerID]];
    NSInteger msg_end = conv.msg_end;
    if (last_msg_sign == 0) {//第一页
        MSIMElem *lastElem = [self lastMessageID:partnerID];
        if (msg_end <= lastElem.msg_id) {//直接本地取
            NSArray<MSIMElem *> *arr = [self messageFromLocalByPartnerID:partnerID last_msg_id:last_msg_sign block_id:lastElem.block_id];
            NSInteger minMsgID = [self minMsgIDInMessages:arr];
            complete(arr,minMsgID > 1 ? YES : NO);
        }else {
            [self fetchHistoryMessageFromEnd:0 toStart:lastElem.msg_id partner_Id:partnerID result:^(NSArray<MSIMElem *> *msgs) {
                if (lastElem.msg_id == 0 || msg_end - lastElem.msg_id > count) {
                    complete(msgs,YES);
                }else {
                    NSArray *arr = [self messageFromLocalByPartnerID:partnerID last_msg_id:last_msg_sign block_id:lastElem.block_id];
                    NSInteger minMsgID = [self minMsgIDInMessages:arr];
                    complete(arr,minMsgID > 1 ? YES : NO);
                }
            }];
        }
    }else {
        MSIMElem *preElem = [self searchMessage:partnerID msg_sign:last_msg_sign];
        NSArray<MSIMElem *> *arr = [self messageFromLocalByPartnerID:partnerID last_msg_id:last_msg_sign block_id:preElem.block_id];
        if (arr.count > count) {
            complete(arr,YES);
        }else {
            if (arr.count == 0) {
                MSIMElem *greaterMsdID = [self greaterMessageIDBeforeMsgSign:last_msg_sign partnerID:partnerID];
                NSInteger startID = count >= greaterMsdID.msg_id ? 0 : (greaterMsdID.msg_id-count);
                [self fetchHistoryMessageFromEnd:greaterMsdID.msg_id toStart:startID partner_Id:partnerID result:^(NSArray<MSIMElem *> *msgs) {
                    complete(msgs,(greaterMsdID.msg_id > count ? YES : NO));
                }];
            }else {
                NSInteger minMsgID = [self minMsgIDInMessages:arr];
                if (minMsgID <= 1) {
                    complete(arr,NO);
                }else {
                    MSIMElem *lastMsdID = [self latestMessageIDBeforeMsgSign:arr.lastObject.msg_sign partnerID:partnerID];
                    [self fetchHistoryMessageFromEnd:[self minMsgIDInMessages:arr] toStart:lastMsdID.msg_id partner_Id:partnerID result:^(NSArray<MSIMElem *> *msgs) {
                        NSMutableArray *tempArr = [NSMutableArray array];
                        [tempArr addObjectsFromArray:arr];
                        [tempArr addObjectsFromArray:msgs];
                        complete(tempArr,YES);
                    }];
                }
            }
        }
    }
}

- (NSInteger)minMsgIDInMessages:(NSArray *)msgs
{
    if (msgs.count == 0) return 0;
    NSInteger msgID = INT64_MAX;
    for (MSIMElem *elem in msgs) {
        if (elem.msg_id > 0 && elem.msg_id < msgID) {
            msgID = elem.msg_id;
        }
    }
    return msgID;
}

- (void)fetchHistoryMessageFromEnd:(NSInteger)msgEnd toStart:(NSInteger)msgStart partner_Id:(NSString *)partner_id result:(void(^)(NSArray<MSIMElem *> *))result
{
    GetHistory *history = [[GetHistory alloc]init];
    history.sign = [MSIMTools sharedInstance].adjustLocalTimeInterval;
    history.toUid = partner_id.integerValue;
    history.msgEnd = msgEnd;
    history.msgStart = msgStart;
    NSLog(@"[发送消息]GetHistory:\n%@",history);
    [[MSIMManager sharedInstance]send:[history data] protoType:XMChatProtoTypeGetHistoryMsg needToEncry:NO sign:history.sign callback:^(NSInteger code, id  _Nullable response, NSString * _Nullable error) {
        if (code == ERR_SUCC) {
            ChatRBatch *batch = response;
            NSArray<MSIMElem *> *msgs = [[MSIMManager sharedInstance] chatHistoryHandler:batch.msgsArray];
            //将不显示的消息剔除
            NSMutableArray *tempArr = [NSMutableArray array];
            for (MSIMElem *elem in msgs) {
                if (elem.type != BFIM_MSG_TYPE_NULL) {
                    [tempArr addObject:elem];
                }
            }
            result(tempArr);
        }else {
            result(nil);
        }
    }];
}


- (NSArray<MSIMElem *> *)messageFromLocalByPartnerID:(NSString *)partnerID
                                         last_msg_id:(NSInteger)last_msg_id
                                            block_id:(NSInteger)block_id
{
    NSString *sqlStr;
    NSString *tableName = [NSString stringWithFormat:@"message_user_%@",partnerID];
    if (last_msg_id == 0) {
        sqlStr = [NSString stringWithFormat:@"select * from %@ where msg_type != '%zd' and block_id = 1 order by msg_sign desc limit 21",tableName,BFIM_MSG_TYPE_NULL];
    }else {
        sqlStr = [NSString stringWithFormat:@"select * from %@ where msg_sign < '%zd' and msg_type != '%zd' and block_id = '%zd' order by msg_sign desc limit 21",tableName,last_msg_id,BFIM_MSG_TYPE_NULL,block_id];
    }
    __block NSMutableArray *data = [[NSMutableArray alloc] init];
    [self excuteQuerySQL:sqlStr resultBlock:^(FMResultSet * _Nonnull rsSet) {
        while ([rsSet next]) {
            [data addObject:[self bf_componentElem:rsSet]];
        }
        [rsSet close];
    }];
    return data;
}

- (MSIMElem *)bf_componentElem:(FMResultSet *)rsSet
{
    MSIMElem *elem = [[MSIMElem alloc]init];
    BFIMMessageType type = [rsSet intForColumn:msg_type];
    NSString *contentJson = [rsSet stringForColumn:ext_data];
    NSDictionary *dic = [contentJson el_convertToDictionary];
    if (type == BFIM_MSG_TYPE_TEXT) {
        MSIMTextElem *textElem = [[MSIMTextElem alloc]init];
        textElem.text = dic[@"text"];
        elem = textElem;
    }else if (type == BFIM_MSG_TYPE_IMAGE) {
        MSIMImageElem *imageElem = [[MSIMImageElem alloc]init];
        imageElem.width = [dic[@"width"]integerValue];
        imageElem.height = [dic[@"height"]integerValue];
        imageElem.size = [dic[@"size"]integerValue];
        imageElem.path = dic[@"path"];
        imageElem.url = dic[@"url"];
        imageElem.uuid = dic[@"uuid"];
        elem = imageElem;
    }
    elem.msg_id = [rsSet longLongIntForColumn:@"msg_id"];
    elem.msg_sign = [rsSet longLongIntForColumn:@"msg_sign"];
    elem.type = type;
    elem.fromUid = [rsSet stringForColumn:@"f_id"];
    elem.toUid = [rsSet stringForColumn:@"t_id"];
    elem.sendStatus = [rsSet intForColumn:@"send_status"];
    elem.readStatus = [rsSet intForColumn:@"read_status"];
    elem.block_id = [rsSet intForColumn:@"block_id"];
    elem.code = [rsSet intForColumn:@"code"];
    elem.reason = [rsSet stringForColumn:@"reason"];
    return elem;
}

///将所有的发送中的消息置为发送失败
- (BOOL)cleanAllSendingMessage:(NSString *)tableName
{
    NSString *sqlStr = [NSString stringWithFormat:@"update %@ set send_status = '%zd' where send_status = '%zd'",tableName,BFIM_MSG_STATUS_SEND_FAIL,BFIM_MSG_STATUS_SENDING];
    BOOL isOK = [self excuteSQL:sqlStr];
    return isOK;
}

@end
