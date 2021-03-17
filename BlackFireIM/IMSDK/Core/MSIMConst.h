//
//  MSIMConst.h
//  BlackFireIM
//
//  Created by benny wang on 2021/2/25.
//

#ifndef MSIMConst_h
#define MSIMConst_h


#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
#define STRONG_SELF(strongSelf) if (!weakSelf) return; \
__strong typeof(weakSelf) strongSelf = weakSelf;


#define XMNoNilString(str)  (str.length > 0 ? str : @"")

//**proto编码对应表**
typedef NS_ENUM(NSInteger, XMChatProtoType) {
    XMChatProtoTypeHeadBeat = 0,//向服务器发送心跳
    XMChatProtoTypeLogin = 1,//im登录
    XMChatProtoTypeLogout = 2,//im登出
    XMChatProtoTypeResult = 3,//返回结果
    XMChatProtoTypeSend = 4,//发送消息
    XMChatProtoTypeResponse = 5,//消息回执
    XMChatProtoTypeRecieve = 6,//接收消息
    XMChatProtoTypeMassRecieve = 7,//接收批量消息
    XMChatProtoTypeGetHistoryMsg = 8,//请求历史消息
    XMChatProtoTypeRecall = 9,//消息撤回
    XMChatProtoTypeMsgread = 10,//发送消息已读
    XMChatProtoTypeLastReadMsg = 11,//消息已读状态发生变更通知（客户端收到这个才去变更）
    XMChatProtoTypeDeleteChat = 12,//删除某一会话
    XMChatProtoTypeGetChatList = 13,//拉会话记录
    XMChatProtoTypeGetChatListResponse = 15,//会话记录结果
    XMChatProtoTypeGetProfile = 16,//请求用户信息
    XMChatProtoTypeGetProfiles = 17,//批量请求用户信息
    XMChatProtoTypeGetProfileResult = 18,//请求单个用户信息返回
    XMChatProtoTypeGetProfilesResult = 19,//请求批量用户信息返回
};

/** 消息发送状态*/
typedef NS_ENUM(NSInteger ,BFIMMessageStatus){
    
    BFIM_MSG_STATUS_SENDING = 0, //消息发送中
    
    BFIM_MSG_STATUS_SEND_SUCC = 1,//消息发送成功
    
    BFIM_MSG_STATUS_SEND_FAIL = 2,//消息发送失败
    
    BFIM_MSG_STATUS_HAS_DELETED = 3,//消息被删除
    
    BFIM_MSG_STATUS_HAS_REVOKED = 4,//消息被撤销
};

/** 聊天类型*/
typedef NS_ENUM(NSInteger ,BFIMAChatType){
    
    BFIM_CHAT_TYPE_C2C = 0, //单聊
    
    BFIM_CHAT_TYPE_GROUP = 1,//群聊
};

/** 消息状态*/
typedef NS_ENUM(NSInteger ,BFIMMessageReadStatus){
    
    BFIM_MSG_STATUS_UNREAD = 0, //消息未读
    
    BFIM_MSG_STATUS_READ = 1,//消息已读
};

/** 消息类型*/
typedef NS_ENUM(NSInteger ,BFIMMessageType){
    
    BFIM_MSG_TYPE_TEXT = 0, //文本消息
    
    BFIM_MSG_TYPE_IMAGE = 1,//图片消息
    
    BFIM_MSG_TYPE_VOICE = 2,//音频消息
    
    BFIM_MSG_TYPE_VIDEO = 3,//视频消息
    
    BFIM_MSG_TYPE_LOCATION = 4,//位置消息
    
    BFIM_MSG_TYPE_USER_CARD = 6,//用户名片消息
    
    BFIM_MSG_TYPE_RECALL = 64,//消息撤回
    
    BFIM_MSG_TYPE_NULL = 999,//空消息，用于占位
};

#define BFIMNotification_onRecvNewMessage @"BFIMNotification_onRecvNewMessage"
#define BFIMNotification_MessageRevoke @"BFIMNotification_MessageRevoke"
#define TUIKitNotification_onRecvMessageReceipts @"TUIKitNotification_onRecvMessageReceipts"


#endif /* MSIMConst_h */

