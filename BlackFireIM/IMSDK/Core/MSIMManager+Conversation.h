//
//  MSIMManager+Conversation.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/8.
//

#import "MSIMManager.h"
#import "MSIMConversation.h"

NS_ASSUME_NONNULL_BEGIN

/// 获取历史消息成功回调
typedef void (^MSIMConversationListSucc)(NSArray<MSIMConversation *> * convs,NSInteger nexSeq,BOOL isFinished);

@interface MSIMManager (Conversation)


///每次建立长链接时，会自动触发跟服务器同步最新的会话列表信息
///该请求不会直接获取到会话列表，而是告知服务器：我需要从什么时间开始的会话列表。
///服务器会异步将该时间后的会话列表发送给客户端sdk，如果会话列表很长，服务器会分批次的发送
- (void)synchronizeConversationList;


/// 分页拉取会话列表
/// @param nextSeq 分页拉取游标，第一次默认取传 0，后续分页拉传上一次分页拉取回调里的 nextSeq
/// @param count 分页拉取的个数，一次分页拉取不宜太多，会影响拉取的速度，建议每次拉取 100 个会话
/// @param succ 拉取成功
/// @param fail 拉取失败
- (void)getConversationList:(NSInteger)nextSeq
                      count:(int)count
                       succ:(MSIMConversationListSucc)succ
                       fail:(MSIMFail)fail;

///删除某一条会话
///删除会话只会删除会话记录，不会删除会话对应的聊天内容
- (void)deleteConversation:(MSIMConversation *)conv
                      succ:(MSIMSucc)succed
                    failed:(MSIMFail)failed;

///标记消息已读状态
///msgID 标记的对方发给我的消息的 id
- (void)markC2CMessageAsRead:(NSString *)user_id
                   lastMsgID:(NSInteger)msgID
                        succ:(MSIMSucc)succed
                      failed:(MSIMFail)failed;

@end

NS_ASSUME_NONNULL_END
