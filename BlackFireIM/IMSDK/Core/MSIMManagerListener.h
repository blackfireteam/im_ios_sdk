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
@protocol MSIMManagerListener <NSObject>

@optional

/// 网络连接成功
- (void)connectSucc;

/// 网络连接失败
/// @param code 错误码
/// @param errString 错误描述
- (void)connectFailed:(int)code err:(NSString *)errString;

/// 连接中
- (void)onConnecting;

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

/**
 *  刷新会话
 */
- (void)onRefresh;

/**
 *  刷新部分会话
 *
 *  @param conversations 会话（TIMConversation*）列表
 */
- (void)onRefreshConversations:(NSArray<MSIMConversation *>*)conversations;

///未读数发生变化时通知
- (void)onUpdateUnreadCountInConversation:(NSString *)conv_id unreadCount:(NSInteger)count;

/**
 *  新消息回调通知
 *
 *  @param msgs 新消息列表，MSIMElem 类型数组
 */
- (void)onNewMessages:(NSArray<MSIMElem *> *)msgs;

/**
 *  收到了已读回执
 *
 *  @param receipts 已读回执（TIMMessageReceipt*）列表
 */
- (void) onRecvMessageReceipts:(NSArray *)receipts;

/**
 *  消息修改通知
 *
 *  @param msgs 修改的消息列表，TIMMessage 类型数组
 */
- (void)onMessageUpdate:(NSArray<MSIMElem *> *) msgs;

/**
 *  用户头像昵称等修改通知
 *
 *  @param info 用户数据
 */
- (void)onProfileUpdate:(MSProfileInfo *)info;


- (void)ms_uploadImage:(NSString *)path
              progress:(void(^)(CGFloat))progress
               success:(void(^)(NSString *))success
                failed:(void(^)(NSError *))failed;

@end



NS_ASSUME_NONNULL_END
