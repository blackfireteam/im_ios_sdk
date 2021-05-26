//
//  MSIMHeader.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/19.
//

#ifndef MSIMHeader_h
#define MSIMHeader_h

//IM网络连接状态通知
#define MSUIKitNotification_ConnListener @"MSUIKitNotification_ConnListener"
//用户登录状态通知
#define MSUIKitNotification_UserStatusListener @"MSUIKitNotification_UserStatusListener"

//会话列表有变更通知
#define MSUIKitNotification_ConversationUpdate @"MSUIKitNotification_ConversationUpdate"

//会话列表同步ga开始通知
#define MSUIKitNotification_ConversationSyncStart @"MSUIKitNotification_ConversationSyncStart"
//会话列表同步完成通知
#define MSUIKitNotification_ConversationSyncFinish @"MSUIKitNotification_ConversationSyncFinish"

//会话被删除时的通知
#define MSUIKitNotification_ConversationDelete @"MSUIKitNotification_ConversationDelete"

//有新消息通知
#define MSUIKitNotification_MessageListener @"MSUIKitNotification_MessageListener"
//消息状态有变更通知
#define MSUIKitNotification_MessageSendStatusUpdate @"MSUIKitNotification_MessageSendStatusUpdate"
//收到对方撤回消息的通知
#define MSUIKitNotification_MessageRecieveRevoke @"MSUIKitNotification_MessageRecieveRevoke"
//收到对方消息已读的通知
#define MSUIKitNotification_MessageReceipt @"MSUIKitNotification_MessageReceipt"

//用户信息更新通知
#define MSUIKitNotification_ProfileUpdate @"MSUIKitNotification_ProfileUpdate"

#endif /* MSIMHeader_h */
