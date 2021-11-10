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

//会话列表同步开始通知
#define MSUIKitNotification_ConversationSyncStart @"MSUIKitNotification_ConversationSyncStart"
//会话列表同步完成通知
#define MSUIKitNotification_ConversationSyncFinish @"MSUIKitNotification_ConversationSyncFinish"

//会话被删除时的通知
#define MSUIKitNotification_ConversationDelete @"MSUIKitNotification_ConversationDelete"

//有新消息通知
#define MSUIKitNotification_MessageListener @"MSUIKitNotification_MessageListener"

//有指令消息通知
#define MSUIKitNotification_SignalMessageListener @"MSUIKitNotification_SignalMessageListener"

//消息状态有变更通知
#define MSUIKitNotification_MessageSendStatusUpdate @"MSUIKitNotification_MessageSendStatusUpdate"
//收到对方撤回消息的通知
#define MSUIKitNotification_MessageRecieveRevoke @"MSUIKitNotification_MessageRecieveRevoke"
//收到对方消息已读的通知
#define MSUIKitNotification_MessageReceipt @"MSUIKitNotification_MessageReceipt"

//收到一条消息被删除的通知
#define MSUIKitNotification_MessageRecieveDelete @"MSUIKitNotification_MessageRecieveDelete"

//用户信息更新通知
#define MSUIKitNotification_ProfileUpdate @"MSUIKitNotification_ProfileUpdate"


//聊天室有新聊天室消息通知
#define MSUIKitNotification_ChatRoom_MessageListener @"MSUIKitNotification_ChatRoom_MessageListener"

//聊天室消息状态有变更通知
#define MSUIKitNotification_ChatRoom_MessageSendStatusUpdate @"MSUIKitNotification_ChatRoom_MessageSendStatusUpdate"

//收到聊天室对方撤回消息的通知
#define MSUIKitNotification_ChatroomMessageRecieveRevoke @"MSUIKitNotification_ChatroomMessageRecieveRevoke"

//聊天室事件通知
#define MSUIKitNotification_ChatRoom_Event @"MSUIKitNotification_ChatRoom_Event"

#endif /* MSIMHeader_h */
