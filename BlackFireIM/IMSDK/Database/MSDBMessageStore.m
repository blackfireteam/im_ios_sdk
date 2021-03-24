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

static NSString *msg_id = @"msg_id";
static NSString *msg_sign = @"msg_sign";
static NSString *f_id = @"f_id";
static NSString *t_id = @"t_id";
static NSString *msg_type = @"msg_type";
static NSString *send_status = @"send_status";
static NSString *read_status = @"read_status";
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
    //根据msg_id将消息去重
    if (elem.msg_id && [self searchMessage:fid msg_id:elem.msg_id]) {
        return YES;
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
    NSString *addSQL = @"insert into %@ (msg_id,msg_sign,f_id,t_id,msg_type,send_status,read_status,code,reason,block_id,ext_data) VALUES (?,?,?,?,?,?,?,?,?,?,?)";
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
    //更新会话
    MSIMConversation *conv = [[MSConversationProvider provider] providerConversation:fid];
    if (conv) {
        if (conv.msg_end < elem.msg_id) {
            conv.msg_end = elem.msg_id;
        }
        if (elem.type != BFIM_MSG_TYPE_NULL && conv.show_msg_sign < elem.msg_sign) {
            conv.show_msg_sign = elem.msg_sign;
            conv.show_msg = elem;
        }
        [[MSConversationProvider provider]updateConversation:conv];
    }else {
        MSIMConversation *con = [[MSIMConversation alloc]init];
        con.partner_id = fid;
        con.chat_type = BFIM_CHAT_TYPE_C2C;
        con.show_msg = elem;
        con.show_msg_sign = elem.msg_sign;
        con.msg_end = elem.msg_id;
        [[MSConversationProvider provider]updateConversation:con];
    }
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
    NSString *sqlStr = [NSString stringWithFormat:@"update %@ set msg_type = '%zd' where msg_id = '%zd'",tableName,BFIM_MSG_TYPE_RECALL,msg_id];
    BOOL isOK = [self excuteSQL:sqlStr];
    //更新会话
    MSIMConversation *conv = [[MSConversationProvider provider] providerConversation:partnerID];
    if (conv && conv.msg_end == msg_id) {
        conv.show_msg.type = BFIM_MSG_TYPE_RECALL;
        [[MSConversationProvider provider]updateConversation:conv];
    }
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

///更新某一条消息的发送状态
- (BOOL)updateMessage:(NSInteger)msg_sign
           sendStatus:(BFIMMessageStatus)status
                 code:(NSInteger)code
               reason:(NSString *)reason
            partnerID:(NSString *)partnerID
{
    NSString *tableName = [NSString stringWithFormat:@"message_user_%@",partnerID];
    NSString *sqlStr = [NSString stringWithFormat:@"update %@ set send_status = '%zd',code = '%zd',reason = '%@' where msg_sign = '%zd'",tableName,status,code,XMNoNilString(reason),msg_sign];
    BOOL isOK = [self excuteSQL:sqlStr];
    //更新会话
    MSIMConversation *conv = [[MSConversationProvider provider] providerConversation:partnerID];
    if (conv && conv.show_msg_sign == msg_sign) {
        conv.show_msg.sendStatus = status;
        [[MSConversationProvider provider]updateConversation:conv];
    }
    return isOK;
}

///服务器同步过来的历史消息，中间有可能会丢失，为了兼容，我会在丢失的位置本地插入一条空消息占位
- (NSArray *)fillHistoryList:(NSArray<ChatR *> *)historys
               fromStartSign:(NSInteger)startSign
              fromStartMsgID:(NSInteger)startMsgID
                      offset:(NSInteger)offset
{
    NSMutableArray *tempArr = [NSMutableArray array];
    NSInteger tempSign = startSign == 0 ? [MSIMTools sharedInstance].adjustLocalTimeInterval : startSign;
    for (NSInteger i = startMsgID-1; i <= startMsgID-offset; i++) {
        BOOL isExist = NO;
        ChatR *existR = nil;
        for (ChatR *r in historys) {
            if (i == r.msgId) {
                isExist = YES;
                existR = r;
                break;
            }
        }
        if (isExist == NO) {
            tempSign -= 1;
            MSIMElem *item = [[MSIMElem alloc]init];
            item.msg_id = i;
            item.type = BFIM_MSG_TYPE_NULL;
            item.msg_sign =  tempSign;
            [tempArr addObject:item];
        }else {
            tempSign = existR.msgTime-1;
        }
    }
    return tempArr;
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

- (void)fetchHistoryMessageWithDataArray:(NSMutableArray *)arr
                              max_msg_id:(NSInteger)maxID
                             lastMessage:(MSIMElem *)elem
                                   count:(NSInteger)count
                               partnerID:(NSString *)partnerID
                                complete:(void(^)(NSArray<MSIMElem *> *data,BOOL hasMore))complete
{
    if (maxID > 0) {
        MSIMElem *lastMessageID = [self latestMessageIDBeforeMsgSign:elem.msg_sign partnerID:partnerID];
        if (lastMessageID.msg_id >= maxID) {
            //取本地
            NSArray<MSIMElem *> *datas = [self localMessageGroupByBlockID:elem.block_id partnerID:partnerID maxCount:count-arr.count];
            NSInteger tempMaxID = 0;
            for (MSIMElem *e in datas) {
                if (e.type != BFIM_MSG_TYPE_NULL) {
                    [arr addObject:e];
                }
                if (e.msg_id) {
                    tempMaxID = e.msg_id;
                }
            }
            if (tempMaxID <= 1 || arr.count >= count) {
                complete(arr,tempMaxID > 1);
                return;
            }
            //不够,继续往上取
            MSIMElem *nextElem = [[MSIMElem alloc]init];
            nextElem.msg_sign = datas.lastObject.msg_sign-1;
            nextElem.block_id = datas.lastObject.block_id+1;
            [self fetchHistoryMessageWithDataArray:arr max_msg_id:tempMaxID-1 lastMessage:nextElem count:count-arr.count partnerID:partnerID complete:complete];
        }else {
            //取网络
            //本地与服务器之间的差异
            GetHistory *history = [[GetHistory alloc]init];
            history.sign = [MSIMTools sharedInstance].adjustLocalTimeInterval;
            history.toUid = partnerID.integerValue;
            history.msgEnd = maxID;
            if (lastMessageID.msg_id == 0) {
                history.offset = MIN(count-arr.count, maxID);
            }else {
                history.offset = MIN(count-arr.count, maxID-lastMessageID.msg_id+1);
            }
            
            [[MSIMManager sharedInstance]send:[history data] protoType:XMChatProtoTypeGetHistoryMsg needToEncry:NO sign:history.sign callback:^(NSInteger code, id  _Nullable response, NSString * _Nullable error) {
                if (code == ERR_SUCC) {
                    ChatRBatch *batch = response;
                    NSArray<MSIMElem *> *tempArr = [self fillHistoryList:batch.msgsArray fromStartSign:elem.msg_sign fromStartMsgID:maxID offset:history.offset];
                    NSInteger tempMaxID = 0;
                    for (MSIMElem *e in tempArr) {
                        if (e.type != BFIM_MSG_TYPE_NULL) {
                            [arr addObject:e];
                        }
                        if (e.msg_id) {
                            tempMaxID = e.msg_id;
                        }
                        [self addMessage:e];
                    }
                    if (tempMaxID <= 1 || arr.count >= count) {
                        complete(arr,tempMaxID > 1);
                        return;
                    }
                    //不够,继续往上取
                    MSIMElem *nextElem = [[MSIMElem alloc]init];
                    nextElem.msg_sign = tempArr.lastObject.msg_sign-1;
                    nextElem.block_id = tempArr.lastObject.block_id+1;
                    [self fetchHistoryMessageWithDataArray:arr max_msg_id:tempMaxID-1 lastMessage:nextElem count:count-arr.count partnerID:partnerID complete:complete];
                    
                }else {
                    complete(arr,YES);
                }
            }];
        }
    }else {
        //取本地
        NSArray *tempArr = [self messageFromLocalByPartnerID:partnerID last_msg_id:elem.msg_sign+1 count:count];
        [arr addObjectsFromArray:tempArr];
        complete(arr,NO);
        return;
    }
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
    MSIMElem *lastElem;
    if (last_msg_sign) {
        lastElem = [self searchMessage:partnerID msg_sign:last_msg_sign];
    }else {
        lastElem = [self lastMessage:partnerID];
    }
    NSMutableArray *arr = [NSMutableArray array];
    [self fetchHistoryMessageWithDataArray:arr max_msg_id:msg_end lastMessage:lastElem count:count partnerID:partnerID complete:complete];
}

- (NSArray<MSIMElem *> *)messageFromLocalByPartnerID:(NSString *)partnerID
                                         last_msg_id:(NSInteger)last_msg_id
                                               count:(NSInteger)count
{
    NSString *tableName = [NSString stringWithFormat:@"message_user_%@",partnerID];
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@ where msg_sign < '%zd' and msg_type != '%zd' order by msg_sign desc limit '%zd'",tableName,last_msg_id,BFIM_MSG_TYPE_NULL,count+1];
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
    MSIMElem *elem = nil;
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
    if (elem) {
        elem.msg_id = [rsSet longLongIntForColumn:msg_id];
        elem.msg_sign = [rsSet longLongIntForColumn:msg_sign];
        elem.type = type;
        elem.fromUid = [rsSet stringForColumn:f_id];
        elem.toUid = [rsSet stringForColumn:t_id];
        elem.sendStatus = [rsSet intForColumn:send_status];
        elem.readStatus = [rsSet intForColumn:read_status];
        elem.code = [rsSet intForColumn:code];
        elem.reason = [rsSet stringForColumn:reason];
    }
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
