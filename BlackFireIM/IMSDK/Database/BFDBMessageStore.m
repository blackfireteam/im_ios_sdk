//
//  BFDBMessageStore.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/2.
//

#import "BFDBMessageStore.h"
#import "BFDBManager.h"


@implementation BFDBMessageStore

///向数据库中添加一条记录
- (BOOL)addMessage:(BFIMElem *)elem
{
    NSInteger fid = elem.isSelf ? elem.toUid : elem.fromUid;
    NSString *tableName = [NSString stringWithFormat:@"message_user_%zd",fid];
    NSString *createSQL = [NSString stringWithFormat:@"create table if not exists %@(msg_id INTEGER,msg_sign INTEGER NOT NULL,f_id INTEGER,t_id INTEGER,msg_type INTEGER,send_status INTEGER,read_status BOOLEAN,ext_data TEXT,PRIMARY KEY(msg_sign))",tableName];
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



@end
