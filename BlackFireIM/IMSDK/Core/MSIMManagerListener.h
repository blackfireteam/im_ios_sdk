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
 *  断线重连失败
 */
- (void)onReConnFailed:(NSInteger)code err:(NSString*)err;

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

@end

@protocol MSIMMessageListener <NSObject>

@required

/// 收到新消息
- (void)onNewMessages:(NSArray<MSIMElem *> *)msgs;

/**
 *  收到了已读回执
 *
 *  @param receipts 已读回执（TIMMessageReceipt*）列表
 */
- (void) onRecvMessageReceipts:(NSArray *)receipts;

/**
 *  消息发送状态变化通知
 */
- (void)onMessageUpdateSendStatus:(MSIMElem *)elem;

@end

@protocol MSIMProfileListener <NSObject>

@required

/**
 *  用户头像昵称等修改通知
 *
 *  @param info 用户数据
 */
- (void)onProfileUpdate:(MSProfileInfo *)info;

@end



NS_ASSUME_NONNULL_END
