//
//  BFIMConst.h
//  BlackFireIM
//
//  Created by benny wang on 2021/2/25.
//

#ifndef BFIMConst_h
#define BFIMConst_h


#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
#define STRONG_SELF if (!weakSelf) return; \
__strong typeof(weakSelf) strongSelf = weakSelf;


#define XMNoNilString(str)  (str.length > 0 ? str : @"")

//**proto编码对应表**
typedef NS_ENUM(NSInteger, XMChatProtoType) {
    XMChatProtoTypeToken = 0,//token鉴权
    XMChatProtoTypeHeadBeat = 1,//向服务器发送心跳
    XMChatProtoTypeResult = 2,//返回结果
    XMChatProtoTypeSend = 3,//发送消息
    XMChatProtoTypeResponse = 4,//消息回执
    XMChatProtoTypeRecieve = 5,//接收消息
    XMChatProtoTypeMassResponse = 6,//批量消息回执
    XMChatProtoTypeGetHistoryMsg = 7,//请求历史消息
    XMChatProtoTypeRecall = 8,//消息撤回
    XMChatProtoTypeMsgread = 9,//发送消息已读
    XMChatProtoTypeLastReadMsg = 10,//消息已读状态发生变更通知（客户端收到这个才去变更）
    XMChatProtoTypeDeleteChat = 11,//删除某一会话
    XMChatProtoTypeGetChatList = 12,//拉会话记录
    XMChatProtoTypeGetChatListRespnse = 13,//会话记录结果
};

/** 消息发送状态*/
typedef NS_ENUM(NSInteger ,BFIMMessageStatus){
    
    BFIM_MSG_STATUS_SENDING = 0, //消息发送中
    
    BFIM_MSG_STATUS_SEND_SUCC = 1,//消息发送成功
    
    BFIM_MSG_STATUS_SEND_FAIL = 2,//消息发送失败
    
    BFIM_MSG_STATUS_HAS_DELETED = 3,//消息被删除
    
    BFIM_MSG_STATUS_HAS_REVOKED = 4,//消息被撤销
};

/** 消息状态*/
typedef NS_ENUM(NSInteger ,BFIMMessageReadStatus){
    
    BFIM_MSG_STATUS_UNREAD = 0, //消息未读
    
    BFIM_MSG_STATUS_READ = 1,//消息已读
};

/** 消息类型*/
typedef NS_ENUM(NSInteger ,BFIMMessageType){
    
    BFIMMessageTypeText = 0, //文本消息
    
    BFIMMessageTypeImage = 1,//图片消息
    
    BFIMMessageTypeVoice = 2,//音频消息
    
    BFIMMessageTypeVideo = 3,//视频消息
    
    BFIMMessageTypeLocation = 4,//位置消息
    
    BFIMMessageTypeUserCard = 6,//用户名片消息
    
    BFIMMessageTypeMsgRecall = 64,//消息撤回
};

#endif /* BFIMConst_h */

