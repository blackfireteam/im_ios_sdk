//
//  MSIMManager+Parse.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/16.
//

#import "MSIMManager.h"

NS_ASSUME_NONNULL_BEGIN

@class ProfileList;
@class ChatR;
@class ChatList;
@class ProfileOnline;
@class UsrOffline;
@interface MSIMManager (Parse)

///收到服务器下发的消息处理
- (void)recieveMessages:(NSArray<ChatR *> *)responses;

///服务器返回的批量用户信息处理
- (void)profilesResultHandler:(ProfileList *)list;

///服务器返回的会话列表数据处理 
- (void)chatListResultHandler:(ChatList *)list;

///服务器返回的未读数结果处理
- (void)chatUnreadCountChanged:(LastReadMsg *)result;

///服务器返回的用户上线通知处理
- (void)userOnLineHandler:(ProfileOnline *)online;

///服务器返回的用户下线通知处理
- (void)userOfflineHandler:(UsrOffline *)offline;

@end

NS_ASSUME_NONNULL_END
