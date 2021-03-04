//
//  BFDBMessageStore.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/2.
//
/**
 消息存储实行分库分表制，每一个对话单独存一张表，表名规则：个人对话表名：message_user_123 群对话表名：message_group_123
 */
#import <Foundation/Foundation.h>
#import "BFIMElem.h"


NS_ASSUME_NONNULL_BEGIN

@interface BFDBMessageStore : NSObject

///向数据库中添加一条记录
- (BOOL)addMessage:(BFIMElem *)elem;

///更新某条消息的已读状态
- (BOOL)updateMessage:(NSInteger)msg_sign readStatus:(BFIMMessageReadStatus)status partnerID:(NSInteger)partnerID;

///更新某一条消息的发送状态
- (BOOL)updateMessage:(NSInteger)msg_sign sendStatus:(BFIMMessageStatus)status partnerID:(NSInteger)partnerID;


/// 分页获取聊天记录
/// @param partnerID 对方Uid
/// @param sign 上一页最后一条消息的标识
/// @param count 每页条数
/// @param complete 返回聊天记录数据
- (void)messageByPartnerID:(NSInteger)partnerID
             last_msg_sign:(NSInteger)sign
                     count:(NSInteger)count
                  complete:(void(^)(NSArray<BFIMElem *> *data,BOOL hasMore))complete;


@end

NS_ASSUME_NONNULL_END
