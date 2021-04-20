//
//  MSIMManager+Parse.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/16.
//

#import "MSIMManager.h"

NS_ASSUME_NONNULL_BEGIN

@class Profile;
@class ChatR;
@class ChatList;
@class ProfileOnline;
@class UsrOffline;
@interface MSIMManager (Parse)

///收到服务器下发的消息处理
- (void)recieveMessage:(ChatR *)response;

///服务器返回的批量用户信息处理
- (void)profilesResultHandler:(NSArray<Profile *> *)list;

///服务器返回的会话列表数据处理 
- (void)chatListResultHandler:(ChatList *)list;

///服务器返回的未读数结果处理
- (void)chatUnreadCountChanged:(LastReadMsg *)result;

///服务器返回的用户上线通知处理
- (void)userOnLineHandler:(ProfileOnline *)online;

///服务器返回的用户下线通知处理
- (void)userOfflineHandler:(UsrOffline *)offline;

///服务器返回的历史数据处理
- (NSArray<MSIMElem *> *)chatHistoryHandler:(NSArray<ChatR *> *)responses;

///服务器返回的删除会话的处理
- (void)deleteChatHandler:(DelChat *)result; 

- (BOOL)elemNeedToUpdateConversation:(MSIMElem *)elem increaseUnreadCount:(BOOL)increase;

@end

NS_ASSUME_NONNULL_END
