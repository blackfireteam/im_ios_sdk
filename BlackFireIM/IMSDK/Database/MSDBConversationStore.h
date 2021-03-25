//
//  MSDBConversationStore.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/3.
//

#import "MSDBBaseStore.h"
#import "MSIMConst.h"


NS_ASSUME_NONNULL_BEGIN

@class MSIMConversation;
@interface MSDBConversationStore : MSDBBaseStore

///添加会话记录
- (BOOL)addConversation:(MSIMConversation *)conv;

///批量添加会话记录
- (BOOL)addConversations:(NSArray<MSIMConversation *> *)convs;

///更新会话记录未读数
- (BOOL)updateConvesation:(NSString *)conv_id unread_count:(NSInteger)count;

///查询所有的会话记录
- (NSArray<MSIMConversation *> *)allConvesations;

///查询某一条会话
- (MSIMConversation *)searchConversation:(NSString *)conv_id;

/// 分页获取会话记录
- (void)conversationsWithLast_seq:(NSInteger)last_seq
                            count:(NSInteger)count
                         complete:(void(^)(NSArray<MSIMConversation *> *data,BOOL hasMore))complete;

///删除某一条会话，不清空聊天记录
- (BOOL)deleteConversation:(NSString *)conv_id;

@end

NS_ASSUME_NONNULL_END
