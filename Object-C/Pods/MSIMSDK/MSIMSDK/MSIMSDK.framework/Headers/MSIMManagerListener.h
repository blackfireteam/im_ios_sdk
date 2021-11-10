//
//  BFIMProtocol.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/2.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@class MSIMConversation;
@class MSIMElem;
@class MSProfileInfo;
@class MSIMMessageReceipt;
@class MSGroupEvent;
@protocol MSIMSDKListener <NSObject>

@optional

/// 网络连接成功
- (void)connectSucc;

/// 网络连接失败
/// @param code 错误码
/// @param errString 错误描述
- (void)connectFailed:(NSInteger)code err:(NSString *)errString;

/// 连接中
- (void)onConnecting;

/**
 *  踢下线通知
 */
- (void)onForceOffline;

/**
 *  用户登录的userSig过期（用户需要重新获取userSig后登录）
 */
- (void)onUserSigExpired;

@end


@protocol MSIMConversationListener <NSObject>

@optional

/**
 * 同步服务器会话开始，SDK 会在登录成功或者断网重连后自动同步服务器会话，您可以监听这个事件做一些 UI 进度展示操作。
 */
- (void)onSyncServerStart;

/**
 * 同步服务器会话完成，如果会话有变更，会通过 onNewConversation | onConversationChanged 回调告知客户
 */
- (void)onSyncServerFinish;

/**
 * 同步服务器会话失败
 */
- (void)onSyncServerFailed;

///新增会话或会话发生变化
- (void)onUpdateConversations:(NSArray<MSIMConversation*> *) conversationList;

///收到会话被删除时通知
- (void)conversationDidDelete:(NSString *)partner_id;

@end

@protocol MSIMMessageListener <NSObject>

@required

/// 收到新消息（除了信令消息）
- (void)onNewMessages:(NSArray<MSIMElem *> *)msgs;

/// 收到删除的消息
- (void)onDeleteMessages:(NSArray<NSNumber *> *)msg_ids;

/// 收到信令消息
- (void)onRecieveSignalMessages:(NSArray<MSIMElem *> *)msgs;

/**
 *  消息发送状态变化通知
 */
- (void)onMessageUpdateSendStatus:(MSIMElem *)elem;

///收到一条对方撤回的消息
- (void)onRevokeMessage:(MSIMElem *)elem;

///收到消息已读回执（仅单聊有效） 
- (void)onRecvC2CReadReceipt:(MSIMMessageReceipt *)receipt;

@end

@protocol MSIMChatRoomMessageListener <NSObject>

@required

/// 收到新消息（除了信令消息）
- (void)onNewChatRoomMessages:(NSArray<MSIMElem *> *)msgs;

///收到一条对方撤回的消息
- (void)onChatroomRevokeMessage:(MSIMElem *)elem;

/**
 *  消息发送状态变化通知
 */
- (void)onChatRoomMessageUpdateSendStatus:(MSIMElem *)elem;

/// 聊天室事件通知
- (void)onNewChatRoomEvent:(MSGroupEvent *)event;

@end

@protocol MSIMProfileListener <NSObject>

@required

/**
 *  用户头像昵称等修改通知
 *
 *  @param infos 用户数据
 */
- (void)onProfileUpdates:(NSArray<MSProfileInfo *> *)infos;

@end



NS_ASSUME_NONNULL_END
