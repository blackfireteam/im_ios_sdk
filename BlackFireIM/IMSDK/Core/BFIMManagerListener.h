//
//  BFIMProtocol.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/2.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@class BFIMConversation;
@protocol BFIMManagerListener <NSObject>

@optional

/// 网络连接成功
- (void)connectSucc;

/// 网络连接失败
/// @param code 错误码
/// @param errString 错误描述
- (void)connectFailed:(int)code err:(NSString *)errString;

/// 连接中
- (void)onConnecting;

@end

@protocol BFIMUserStatusListener <NSObject>

@optional

/**
 *  踢下线通知
 */
- (void)onForceOffline;

/**
 *  断线重连失败
 */
- (void)onReConnFailed:(int)code err:(NSString*)err;

/**
 *  用户登录的userSig过期（用户需要重新获取userSig后登录）
 */
- (void)onUserSigExpired;

@end

/**
 *  页面刷新接口（如有需要未读计数刷新，会话列表刷新等）
 */
@protocol TIMRefreshListener <NSObject>
@optional
/**
 *  刷新会话
 */
- (void)onRefresh;

/**
 *  刷新部分会话
 *
 *  @param conversations 会话（TIMConversation*）列表
 */
- (void)onRefreshConversations:(NSArray<BFIMConversation *>*)conversations;

@end

/**
 *  消息回调
 */
@protocol BFIMMessageListener <NSObject>
@optional
/**
 *  新消息回调通知
 *
 *  @param msgs 新消息列表，TIMMessage 类型数组
 */
- (void)onNewMessage:(NSArray *)msgs;

@end

@protocol BFIMMessageReceiptListener <NSObject>
@optional
/**
 *  收到了已读回执
 *
 *  @param receipts 已读回执（TIMMessageReceipt*）列表
 */
- (void) onRecvMessageReceipts:(NSArray *)receipts;
@end

/**
 *  消息修改回调
 */
@protocol BFIMMessageUpdateListener <NSObject>
@optional
/**
 *  消息修改通知
 *
 *  @param msgs 修改的消息列表，TIMMessage 类型数组
 */
- (void)onMessageUpdate:(NSArray *) msgs;
@end

@protocol BFIMMessageRevokeListener <NSObject>
@optional
/**
 *  消息撤回通知
 *
 *  @param locator 被撤回消息的标识
 */
//- (void)onRevokeMessage:(TIMMessageLocator *)locator;

@end


NS_ASSUME_NONNULL_END
