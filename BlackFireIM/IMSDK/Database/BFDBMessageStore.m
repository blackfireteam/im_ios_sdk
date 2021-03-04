//
//  BFDBMessageStore.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/2.
//

#import "BFDBMessageStore.h"
#import "BFDBManager.h"
#import <FMDB.h>
#import "NSString+Ext.h"

static NSString *msg_id = @"msg_id";
static NSString *msg_sign = @"msg_sign";
static NSString *f_id = @"f_id";
static NSString *t_id = @"t_id";
static NSString *msg_type = @"msg_type";
static NSString *send_status = @"send_status";
static NSString *read_status = @"read_status";
static NSString *ext_data = @"ext_data";
@implementation BFDBMessageStore

///向数据库中添加一条记录
- (BOOL)addMessage:(BFIMElem *)elem
{
    NSInteger fid = elem.isSelf ? elem.toUid : elem.fromUid;
    NSString *tableName = [NSString stringWithFormat:@"message_user_%zd",fid];
    NSString *createSQL = [NSString stringWithFormat:@"create table if not exists %@(msg_id INTEGER,msg_sign INTEGER NOT NULL,f_id INTEGER,t_id INTEGER,msg_type INTEGER,send_status INTEGER,read_status INTEGER,ext_data TEXT,PRIMARY KEY(msg_sign))",tableName];
    BOOL isOK = [[BFDBManager sharedInstance] createTable:tableName withSQL:createSQL];
    if (isOK == NO) {
        NSLog(@"创建表失败****%@",tableName);
        return NO;
    }
    //根据msg_id将消息去重
    if (elem.msg_id) {
        NSString *delSQL = [NSString stringWithFormat:@"delete from %@ where msg_id = '%zd'",tableName,elem.msg_id];
        [[BFDBManager sharedInstance] excuteSQL:delSQL];
    }
    NSString *addSQL = @"insert into %@ (msg_id,msg_sign,f_id,t_id,msg_type,send_status,read_status,ext_data) VALUES (?,?,?,?,?,?,?,?)";
    NSString *sqlStr = [NSString stringWithFormat:addSQL,tableName];
    NSArray *addParams = @[@(elem.msg_id),@(elem.msg_sign),@(elem.fromUid),@(elem.toUid),@(elem.type),@(elem.sendStatus),@(elem.readStatus),elem.contentDic];
    BOOL isAddOK = [[BFDBManager sharedInstance] excuteSQL:sqlStr withArrParameter:addParams];
    return isAddOK;
}

///更新某条消息的已读状态
- (BOOL)updateMessage:(NSInteger)msg_sign readStatus:(BFIMMessageReadStatus)status partnerID:(NSInteger)partnerID
{
    NSString *tableName = [NSString stringWithFormat:@"message_user_%zd",partnerID];
    NSString *sqlStr = [NSString stringWithFormat:@"update %@ set read_status = '%zd' where msg_sign = '%zd'",tableName,status,msg_sign];
    BOOL isOK = [[BFDBManager sharedInstance] excuteSQL:sqlStr];
    return isOK;
}

///更新某一条消息的发送状态
- (BOOL)updateMessage:(NSInteger)msg_sign sendStatus:(BFIMMessageStatus)status partnerID:(NSInteger)partnerID
{
    NSString *tableName = [NSString stringWithFormat:@"message_user_%zd",partnerID];
    NSString *sqlStr = [NSString stringWithFormat:@"update %@ set send_status = '%zd' where msg_sign = '%zd'",tableName,status,msg_sign];
    BOOL isOK = [[BFDBManager sharedInstance] excuteSQL:sqlStr];
    return isOK;
}


/// 分页获取聊天记录
/// @param partnerID 对方Uid
/// @param sign 上一页最后一条消息的标识
/// @param count 每页条数
/// @param complete 返回聊天记录数据
- (void)messageByPartnerID:(NSInteger)partnerID
             last_msg_sign:(NSInteger)sign
                     count:(NSInteger)count
                  complete:(void(^)(NSArray<BFIMElem *> *data,BOOL hasMore))complete
{
    NSString *tableName = [NSString stringWithFormat:@"message_user_%zd",partnerID];
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@ where msg_sign < '%zd' order by msg_sign desc limit '%zd'",tableName,sign,count+1];
    __block NSMutableArray *data = [[NSMutableArray alloc] init];
    [[BFDBManager sharedInstance] excuteQuerySQL:sqlStr resultBlock:^(FMResultSet * _Nonnull rsSet) {
        while ([rsSet next]) {
            BFIMElem *elem = [[BFIMElem alloc]init];
            elem.msg_id = [rsSet longLongIntForColumn:msg_id];
            elem.msg_sign = [rsSet longLongIntForColumn:msg_sign];
            elem.type = [rsSet intForColumn:msg_type];
            elem.fromUid = [rsSet longLongIntForColumn:f_id];
            elem.toUid = [rsSet longLongIntForColumn:t_id];
            elem.sendStatus = [rsSet intForColumn:send_status];
            elem.readStatus = [rsSet intForColumn:read_status];
            NSString *contentJson = [rsSet stringForColumn:ext_data];
            NSDictionary *dic = [contentJson el_convertToDictionary];
            if (elem.type == BFIMMessageTypeText) {
                BFIMTextElem *textElem = (BFIMTextElem *)elem;
                textElem.text = dic[@"text"];
                [data addObject:textElem];
            }else if (elem.type == BFIMMessageTypeImage) {
                BFIMImageElem *imageElem = (BFIMImageElem *)elem;
                imageElem.width = [dic[@"width"]integerValue];
                imageElem.height = [dic[@"height"]integerValue];
                imageElem.size = [dic[@"size"]integerValue];
                imageElem.path = dic[@"path"];
                imageElem.url = dic[@"url"];
                imageElem.uuid = dic[@"uuid"];
                [data addObject:imageElem];
            }
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

@end
