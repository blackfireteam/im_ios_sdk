//
//  MSDBMessageStore.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/2.
//
/**
 消息存储实行分库分表制，每一个对话单独存一张表，表名规则：个人对话表名：message_user_123 群对话表名：message_group_123
 */
#import "MSDBBaseStore.h"
#import "MSIMElem.h"


NS_ASSUME_NONNULL_BEGIN

@interface MSDBMessageStore : MSDBBaseStore

///向数据库中添加一条记录
- (BOOL)addMessage:(MSIMElem *)elem;

///向数据库中添加批量记录
- (BOOL)addMessages:(NSArray<MSIMElem *> *)elems;

///更新某条消息的已读状态
- (BOOL)updateMessage:(NSInteger)msg_sign readStatus:(BFIMMessageReadStatus)status partnerID:(NSString *)partnerID;

///更新某一条消息的发送状态
- (BOOL)updateMessage:(NSInteger)msg_sign sendStatus:(BFIMMessageStatus)status partnerID:(NSString *)partnerID;

///标记某一条消息为撤回消息
- (BOOL)updateMessageRevoke:(NSInteger)msg_id partnerID:(NSString *)partnerID;

///取最后一条msg_id
- (MSIMElem *)lastMessageID:(NSString *)partner_id;

/// 分页获取聊天记录
/// @param partnerID 对方Uid
/// @param last_msg_id 上一页的结束标记.当取第一页时，last_msg_id = conversation.msg_end。
/// @param count 每页条数
/// @param complete 返回聊天记录数据
- (void)messageByPartnerID:(NSString *)partnerID
               last_msg_id:(NSInteger)last_msg_id
                     count:(NSInteger)count
                  complete:(void(^)(NSArray<MSIMElem *> *data,BOOL hasMore))complete;


///根据msg_id查询消息
- (MSIMElem *)searchMessage:(NSString *)partner_id msg_id:(NSInteger)msg_id;

@end

NS_ASSUME_NONNULL_END
