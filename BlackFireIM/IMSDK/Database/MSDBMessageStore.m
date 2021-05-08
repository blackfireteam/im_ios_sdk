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
#import "MSDBManager.h"

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

@interface MSDBMessageStore()

@end
@implementation MSDBMessageStore

- (BOOL)createTableWithName:(NSString *)name
{
    if (name == nil) return NO;
    NSNumber *isExist = [[MSDBManager sharedInstance].tableCache objectForKey:name];
    if (isExist.boolValue) return YES;
    NSString *createSQL = [NSString stringWithFormat:@"create table if not exists %@(msg_id INTEGER UNIQUE,msg_sign INTEGER NOT NULL,f_id TEXT,t_id TEXT,msg_type INTEGER,send_status INTEGER,read_status INTEGER,code INTEGER,reason TEXT,block_id INTEGER NOT NULL,ext_data blob,PRIMARY KEY(msg_sign))",name];
    BOOL isOK = [self createTable:name withSQL:createSQL];
    if (isOK == NO) {
        NSLog(@"创建表失败****%@",name);
        return NO;
    }
    [[MSDBManager sharedInstance].tableCache setObject:@(YES) forKey:name];
    return YES;
}

- (NSInteger)createBlock_idWithElem:(MSIMElem *)elem tableName:(NSString *)tableName database:(FMDatabase *)db
{
    NSInteger block_id = 1;
    if (elem.msg_id != 0) {
        ///如果收到msg_id存在的消息，不覆盖
        NSString *searchNextSQL = [NSString stringWithFormat:@"select * from %@ where msg_id = '%zd'",tableName,elem.msg_id+1];
        FMResultSet *searchNextSet = [db executeQuery:searchNextSQL];
        MSIMElem *nextElem;
        while ([searchNextSet next]) {
            nextElem = [self bf_componentElem:searchNextSet];
            NSString *searchPreSQL = [NSString stringWithFormat:@"select * from %@ where msg_id = '%zd'",tableName,elem.msg_id-1];
            FMResultSet *searchPreSet = [db executeQuery:searchPreSQL];
            MSIMElem *preElem;
            while ([searchPreSet next]) {
                preElem = [self bf_componentElem:searchPreSet];
                block_id = MIN(nextElem.block_id, preElem.block_id);
                NSString *updateBlockSQL = [NSString stringWithFormat:@"update %@ set block_id = '%zd' where block_id = '%zd'",tableName,block_id,MAX(preElem.block_id, nextElem.block_id)];
                [db executeUpdate:updateBlockSQL];
            }
            if (preElem == nil) {
                block_id = nextElem.block_id;
            }
        }
        if (nextElem == nil) {
            NSString *searchPreSQL = [NSString stringWithFormat:@"select * from %@ where msg_id = '%zd'",tableName,elem.msg_id-1];
            FMResultSet *searchPreSet = [db executeQuery:searchPreSQL];
            MSIMElem *preElem;
            while ([searchPreSet next]) {
                preElem = [self bf_componentElem:searchPreSet];
                block_id = preElem.block_id;
            }
            if (preElem == nil) {
                NSString *maxBlockIDSQL = [NSString stringWithFormat:@"select block_id from %@ order by block_id desc limit 1",tableName];
                FMResultSet *maxBlockSet = [db executeQuery:maxBlockIDSQL];
                while ([maxBlockSet next]) {
                    block_id = [maxBlockSet intForColumn:@"block_id"] + 1;
                }
            }
        }
    }
    return block_id;
}

///向数据库中添加批量记录
- (void)addMessages:(NSArray<MSIMElem *> *)elems
{
    for (MSIMElem *elem in elems) {
        NSString *tableName = [NSString stringWithFormat:@"message_user_%@",elem.partner_id];
        BOOL isTableExist = [self createTableWithName:tableName];
        if (isTableExist == NO) return;
    }
    WS(weakSelf)
    [self.dbQueue inDeferredTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        for (MSIMElem *elem in elems) {
            NSString *tableName = [NSString stringWithFormat:@"message_user_%@",elem.partner_id];
            NSString *lastMessageIDSQL = [NSString stringWithFormat:@"select * from %@ where msg_id > 0 order by msg_id desc limit 1",tableName];
            FMResultSet *lastMessageIDSet = [db executeQuery:lastMessageIDSQL];
            MSIMElem *lastContainMsgIDElem;
            while ([lastMessageIDSet next]) {
                lastContainMsgIDElem = [weakSelf bf_componentElem:lastMessageIDSet];
                if (elem.msg_id != 0) {
                    ///如果收到msg_id存在的消息，不覆盖
                    NSString *searchCurrentSQL = [NSString stringWithFormat:@"select * from %@ where msg_id = '%zd'",tableName,elem.msg_id];
                    FMResultSet *searchCurrentSet = [db executeQuery:searchCurrentSQL];
                    MSIMElem *currentElem;
                    while ([searchCurrentSet next]) {
                        currentElem = [weakSelf bf_componentElem:searchCurrentSet];
                        continue;
                    }
                    if (currentElem == nil) {
                        NSInteger blockId = [weakSelf createBlock_idWithElem:elem tableName:tableName database:db];
                        [weakSelf addMessageToDB:elem block_id:blockId tableName:tableName database:db];
                    }
                }else {
                    NSString *maxBlockIDSQL = [NSString stringWithFormat:@"select block_id from %@ order by block_id desc limit 1",tableName];
                    FMResultSet *maxBlockSet = [db executeQuery:maxBlockIDSQL];
                    while ([maxBlockSet next]) {
                        NSInteger block_id = [maxBlockSet intForColumn:@"block_id"];
                        [weakSelf addMessageToDB:elem block_id:block_id tableName:tableName database:db];
                    }
                }
            }
            if (lastContainMsgIDElem == nil) {
                [weakSelf addMessageToDB:elem block_id:1 tableName:tableName database:db];
            }
        }
    }];
}

///向数据库中添加一条记录
- (void)addMessage:(MSIMElem *)elem
{
    [self addMessages:@[elem]];
}

- (void)addMessageToDB:(MSIMElem *)elem block_id:(NSInteger)block_id tableName:(NSString *)tableName database:(FMDatabase *)db
{
    NSString *addSQL = @"replace into %@ (msg_id,msg_sign,f_id,t_id,msg_type,send_status,read_status,code,reason,block_id,ext_data) VALUES (?,?,?,?,?,?,?,?,?,?,?)";
    NSString *sqlStr = [NSString stringWithFormat:addSQL,tableName];
    NSArray *addParams = @[(elem.msg_id ? @(elem.msg_id) : [NSNull null]),
                           @(elem.msg_sign),
                           elem.fromUid,
                           elem.toUid,
                           @(elem.type),
                           @(elem.sendStatus),
                           @(elem.readStatus),
                           @(elem.code),
                           XMNoNilString(elem.reason),
                           @(block_id),
                           elem.extData ?:[NSNull  null]];
    [db executeUpdate:sqlStr withArgumentsInArray:addParams];
}

///标记某一条消息为撤回消息
- (BOOL)updateMessageRevoke:(NSInteger)msg_id partnerID:(NSString *)partnerID
{
    NSString *tableName = [NSString stringWithFormat:@"message_user_%@",partnerID];
    NSString *sqlStr = [NSString stringWithFormat:@"update %@ set msg_type = '%zd' where msg_id = '%zd'",tableName,BFIM_MSG_TYPE_REVOKE,msg_id];
    BOOL isOK = [self excuteSQL:sqlStr];
    return isOK;
}

///将表中所有消息id <= last_msg_id标记为已读
- (BOOL)markMessageAsRead:(NSInteger)last_msg_id partnerID:(NSString *)partnerID
{
    NSString *tableName = [NSString stringWithFormat:@"message_user_%@",partnerID];
    NSString *sqlStr = [NSString stringWithFormat:@"update %@ set read_status = '%zd' where msg_id <= '%zd'",tableName,BFIM_MSG_STATUS_READ,last_msg_id];
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
    WS(weakSelf)
    [self excuteQuerySQL:sqlStr resultBlock:^(FMResultSet * _Nonnull rsSet) {
        while ([rsSet next]) {
            elem = [weakSelf bf_componentElem:rsSet];
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
    NSString *sqlStr = [NSString stringWithFormat:@"update %@ set block_id = '%zd' where block_id = '%zd'",tableName,toBlockID,fromBlockID];
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

- (NSArray<MSIMElem *> *)localMessageGroupByBlockID:(NSInteger)blockID partnerID:(NSString *)partnerID maxCount:(NSInteger)count
{
    NSString *tableName = [NSString stringWithFormat:@"message_user_%@",partnerID];
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@ where block_id = '%zd' order by msg_sign desc limit '%zd'",tableName,blockID,count];
    __block NSMutableArray *data = [[NSMutableArray alloc] init];
    WS(weakSelf)
    [self excuteQuerySQL:sqlStr resultBlock:^(FMResultSet * _Nonnull rsSet) {
        while ([rsSet next]) {
            [data addObject:[weakSelf bf_componentElem:rsSet]];
        }
        [rsSet close];
    }];
    return data;
}

- (MSIMElem *)latestMessageIDBeforeMsgSign:(NSInteger)msg_sign partnerID:(NSString *)partnerID
{
    NSString *tableName = [NSString stringWithFormat:@"message_user_%@",partnerID];
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@ where msg_sign < '%zd' and msg_id != 0 order by msg_sign desc limit 1",tableName,msg_sign];
    __block MSIMElem *elem = nil;
    WS(weakSelf)
    [self excuteQuerySQL:sqlStr resultBlock:^(FMResultSet * _Nonnull rsSet) {
        while ([rsSet next]) {
            elem = [weakSelf bf_componentElem:rsSet];
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
    WS(weakSelf)
    [self excuteQuerySQL:sqlStr resultBlock:^(FMResultSet * _Nonnull rsSet) {
        while ([rsSet next]) {
            elem = [weakSelf bf_componentElem:rsSet];
        }
        [rsSet close];
    }];
    return elem;
}

///取出小于或等于msg_id的对方发出的消息的msg_id
- (NSInteger)latestMsgIDLessThan:(NSInteger)msg_id partner_id:(NSString *)partner_id
{
    NSString *tableName = [NSString stringWithFormat:@"message_user_%@",partner_id];
    NSString *sqlStr = [NSString stringWithFormat:@"select msg_id from %@ where msg_id < '%zd' and f_id = '%@' and msg_id != 0 order by msg_sign desc limit 1",tableName,msg_id,partner_id];
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
        NSInteger lastMsgSign = 0;
        if (lastElem == nil) {
            lastMsgSign = [self lastMessage:partnerID].msg_sign;
        }
        if (msg_end <= lastElem.msg_id) {//直接本地取
            WS(weakSelf)
            [self messageFromLocalByPartnerID:partnerID last_msg_sign:last_msg_sign count:count block_id:MAX(lastElem.block_id, 1) result:^(NSArray<MSIMElem *> *arr, BOOL hasMore) {
                NSInteger minMsgID = [weakSelf minMsgIDInMessages:arr];
                if (hasMore) {
                    complete(arr,YES);
                }else {
                    if (minMsgID <= 1) {
                        complete(arr,NO);
                    }else {
                        if (arr.count >= count) {
                            complete(arr,YES);
                        }else {
                            NSInteger preMsgID = [weakSelf latestMsgIDLessThan:minMsgID partner_id:partnerID];
                            [weakSelf requestHistoryMessageFromEnd:minMsgID toStart:preMsgID partner_Id:partnerID result:^(NSArray<MSIMElem *> *msgs) {
                                NSMutableArray *tempArr = [NSMutableArray array];
                                [tempArr addObjectsFromArray:arr];
                                [tempArr addObjectsFromArray:msgs];
                                if (tempArr.count < count && msgs.lastObject.msg_id <= 1 && lastMsgSign == 0) {
                                    complete(tempArr,NO);
                                }else {
                                    complete(tempArr,YES);
                                }
                            }];
                        }
                    }
                }
            }];
        }else {
            WS(weakSelf)
            [self requestHistoryMessageFromEnd:0 toStart:lastElem.msg_id partner_Id:partnerID result:^(NSArray<MSIMElem *> *msgs) {
                NSInteger minMsgID = [weakSelf minMsgIDInMessages:msgs];
                if (msgs.count >= count) {
                    if (minMsgID <= 1 && lastMsgSign == 0) {
                        complete(msgs,NO);
                    }else {
                        complete(msgs,YES);
                    }
                }else {
                    [weakSelf messageFromLocalByPartnerID:partnerID last_msg_sign:msgs.lastObject.msg_sign count:count-msgs.count block_id:MAX(lastElem.block_id, 1) result:^(NSArray<MSIMElem *> *localElems, BOOL hasMore) {
                        NSMutableArray *tempArr = [NSMutableArray array];
                        [tempArr addObjectsFromArray:msgs];
                        [tempArr addObjectsFromArray:localElems];
                        if (hasMore) {
                            complete(tempArr,YES);
                        }else {
                            if ([weakSelf minMsgIDInMessages:localElems] <= 1) {
                                complete(tempArr,NO);
                            }else {
                                complete(tempArr,YES);
                            }
                        }
                    }];
                }
            }];
        }
    }else {
        WS(weakSelf)
        MSIMElem *preElem = [self searchMessage:partnerID msg_sign:last_msg_sign];
        [self messageFromLocalByPartnerID:partnerID last_msg_sign:last_msg_sign count:count block_id:preElem.block_id result:^(NSArray<MSIMElem *> *arr, BOOL hasMore) {
            if (hasMore) {
                complete(arr,YES);
            }else {
                if (arr.count == 0) {
                    MSIMElem *greaterMsdID = [weakSelf greaterMessageIDBeforeMsgSign:last_msg_sign partnerID:partnerID];
                    NSInteger startID = count >= greaterMsdID.msg_id ? 0 : (greaterMsdID.msg_id-count);
                    [weakSelf requestHistoryMessageFromEnd:greaterMsdID.msg_id toStart:startID partner_Id:partnerID result:^(NSArray<MSIMElem *> *msgs) {
                        complete(msgs,(greaterMsdID.msg_id > count ? YES : NO));
                    }];
                }else {
                    NSInteger minMsgID = [weakSelf minMsgIDInMessages:arr];
                    if (minMsgID <= 1) {
                        complete(arr,NO);
                    }else {
                        MSIMElem *lastMsdID = [weakSelf latestMessageIDBeforeMsgSign:arr.lastObject.msg_sign partnerID:partnerID];
                        [weakSelf requestHistoryMessageFromEnd:[weakSelf minMsgIDInMessages:arr] toStart:lastMsdID.msg_id partner_Id:partnerID result:^(NSArray<MSIMElem *> *msgs) {
                            NSMutableArray *tempArr = [NSMutableArray array];
                            [tempArr addObjectsFromArray:arr];
                            [tempArr addObjectsFromArray:msgs];
                            complete(tempArr,YES);
                        }];
                    }
                }
            }
        }];
    }
}

- (NSInteger)minMsgIDInMessages:(NSArray *)msgs
{
    NSInteger msgID = 0;
    for (NSInteger i = 0; i < msgs.count; i++) {
        MSIMElem *elem = msgs[i];
        if (elem.msg_id == 0) continue;
        if (msgID == 0 || elem.msg_id < msgID) {
            msgID = elem.msg_id;
        }
    }
    return msgID;
}

- (void)requestHistoryMessageFromEnd:(NSInteger)msgEnd toStart:(NSInteger)msgStart partner_Id:(NSString *)partner_id result:(void(^)(NSArray<MSIMElem *> *elems))result
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


- (void)messageFromLocalByPartnerID:(NSString *)partnerID
                                       last_msg_sign:(NSInteger)last_msg_sign
                                               count:(NSInteger)count
                                            block_id:(NSInteger)block_id
                                              result:(void(^)(NSArray<MSIMElem *> *elems,BOOL hasMore))result
{
    NSString *sqlStr;
    NSString *tableName = [NSString stringWithFormat:@"message_user_%@",partnerID];
    if (last_msg_sign == 0) {
        sqlStr = [NSString stringWithFormat:@"select * from %@ where msg_type != '%zd' and block_id = '%zd' order by msg_sign desc limit '%zd'",tableName,BFIM_MSG_TYPE_NULL,block_id,count+1];
    }else {
        sqlStr = [NSString stringWithFormat:@"select * from %@ where msg_sign < '%zd' and msg_type != '%zd' and block_id = '%zd' order by msg_sign desc limit '%zd'",tableName,last_msg_sign,BFIM_MSG_TYPE_NULL,block_id,count+1];
    }
    __block NSMutableArray *data = [[NSMutableArray alloc] init];
    WS(weakSelf)
    [self excuteQuerySQL:sqlStr resultBlock:^(FMResultSet * _Nonnull rsSet) {
        while ([rsSet next]) {
            [data addObject:[weakSelf bf_componentElem:rsSet]];
        }
        [rsSet close];
    }];
    if (data.count > count) {
        [data removeLastObject];
        result(data,YES);
    }else {
        result(data,NO);
    }
}

- (MSIMElem *)bf_componentElem:(FMResultSet *)rsSet
{
    MSIMElem *elem = [[MSIMElem alloc]init];
    BFIMMessageType type = [rsSet intForColumn:msg_type];
    NSData *extData = [rsSet dataForColumn:@"ext_data"];
    NSDictionary *dic = [NSDictionary el_convertFromData:extData];
    if (type == BFIM_MSG_TYPE_TEXT) {
        MSIMTextElem *textElem = [[MSIMTextElem alloc]init];
        textElem.text = dic[@"text"];
        elem = textElem;
    }else if (type == BFIM_MSG_TYPE_IMAGE) {
        MSIMImageElem *imageElem = [[MSIMImageElem alloc]init];
        imageElem.width = [dic[@"width"]integerValue];
        imageElem.height = [dic[@"height"]integerValue];
        imageElem.size = [dic[@"size"]integerValue];
        imageElem.path = [self fixLocalImagePath:dic[@"path"]];
        imageElem.url = dic[@"url"];
        imageElem.uuid = dic[@"uuid"];
        elem = imageElem;
    }else if (type == BFIM_MSG_TYPE_VIDEO) {
        MSIMVideoElem *videoElem = [[MSIMVideoElem alloc]init];
        videoElem.width = [dic[@"width"]integerValue];
        videoElem.height = [dic[@"height"]integerValue];
        videoElem.videoUrl = dic[@"videoUrl"];
        videoElem.videoPath = [self fixLocalImagePath:dic[@"videoPath"]];
        videoElem.coverPath = [self fixLocalImagePath:dic[@"coverPath"]];
        videoElem.coverUrl = dic[@"coverUrl"];
        videoElem.duration = [dic[@"duration"] integerValue];
        videoElem.uuid = dic[@"uuid"];
        elem = videoElem;
    }else if (type == BFIM_MSG_TYPE_VOICE) {
        MSIMVoiceElem *voiceElem = [[MSIMVoiceElem alloc]init];
        voiceElem.url = dic[@"voiceUrl"];
        voiceElem.path = [self fixLocalImagePath:dic[@"voicePath"]];
        voiceElem.duration = [dic[@"duration"] integerValue];
        voiceElem.dataSize = [dic[@"size"] integerValue];
        elem = voiceElem;
    }else if (type == BFIM_MSG_TYPE_CUSTOM) {
        MSIMCustomElem *customElem = [[MSIMCustomElem alloc]init];
        customElem.data = extData;
        elem = customElem;
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


- (NSString *)fixLocalImagePath:(NSString *)path
{
    if (path.length == 0) return @"";
    NSString *homePath = NSHomeDirectory();
    if ([path hasPrefix:homePath]) {
        return path;
    }
    if ([path containsString:@"/Documents/"]) {
        NSRange range = [path rangeOfString:@"/Documents/"];
        path = [path substringFromIndex:range.location];
        path = [homePath stringByAppendingPathComponent:path];
        return path;
    }
    if ([path containsString:@"/Library/"]) {
        NSRange range = [path rangeOfString:@"/Library/"];
        path = [path substringFromIndex:range.location];
        path = [homePath stringByAppendingPathComponent:path];
        return path;
    }
    if ([path containsString:@"/tmp/"]) {
        NSRange range = [path rangeOfString:@"/tmp/"];
        path = [path substringFromIndex:range.location];
        path = [homePath stringByAppendingPathComponent:path];
        return path;
    }
    return @"";
}

@end
