//
//  BFDBConversationStore.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/3.
//

#import <Foundation/Foundation.h>
#import "BFIMConst.h"


NS_ASSUME_NONNULL_BEGIN

@class BFConversation;
@interface BFDBConversationStore : NSObject

///添加会话记录
- (BOOL)addConversation:(BFConversation *)conv;

///更新会话记录未读数
- (BOOL)updateConvesation:(NSInteger)conv_id partner_id:(NSInteger)f_id unread_count:(NSInteger)count;

///更新会话消息发送状态
- (BOOL)updateConvesation:(NSInteger)conv_id partner_id:(NSInteger)f_id send_status:(BFIMMessageStatus)status;

///查询所有的会话记录
- (NSArray<BFConversation *> *)allConvesations;

///删除某一条会话，不清空聊天记录
- (BOOL)deleteConversation:(NSInteger)conv_id partner_id:(NSInteger)f_id;

@end

NS_ASSUME_NONNULL_END
