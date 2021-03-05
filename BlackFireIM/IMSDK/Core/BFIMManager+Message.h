//
//  BFIMManager+Message.h
//  BlackFireIM
//
//  Created by benny wang on 2021/2/26.
//

#import "BFIMManager.h"
#import "BFIMElem.h"

NS_ASSUME_NONNULL_BEGIN

@class ChatR;

@interface BFIMManager (Message)

/////////////////////////////////////////////////////////////////////////////////
//
//                         创建和发送文本、图片等消息接口
//
/////////////////////////////////////////////////////////////////////////////////
/** 创建文本消息*/
- (BFIMTextElem *)prepareTextMessage:(NSString *)text toUid:(NSString *)to_uid;

/** 创建图片消息（图片文件最大支持 28 MB）
    如果是系统相册拿的图片，需要先把图片导入 APP 的目录下
 */
- (BFIMImageElem *)prepareImageMessage:(BFIMImageElem *)elem toUid:(NSString *)to_uid;

/// 发送单聊普通文本消息（最大支持 8KB）
/// @param elem 文本消息
/// @param success 发送成功，返回消息的唯一标识ID
/// @param failed 发送失败
- (void)sendTextMessage:(BFIMTextElem *)elem
              successed:(void(^)(NSInteger msg_id))success
                 failed:(void(^)(NSInteger code,NSString *errorString))failed;

/// 发送单聊普通图片消息
/// @param elem 图片消息
/// @param success 发送成功，返回消息的唯一标识ID
/// @param failed 发送失败
- (void)sendImage:(BFIMImageElem *)elem
        successed:(void(^)(NSInteger msg_id))success
           failed:(void(^)(NSInteger code,NSString *errorString))failed;

///接收到新消息处理
- (void)recieveMessages:(NSArray<ChatR *> *)msgs;

/////////////////////////////////////////////////////////////////////////////////
//
//                         获取历史消息、撤回、删除、标记已读等接口
//
/////////////////////////////////////////////////////////////////////////////////
/**
 *  获取单聊历史消息
 *
 *  @param count 拉取消息的个数，不宜太多，会影响消息拉取的速度，这里建议一次拉取 20 个
 *  @param lastMsgSign 获取消息的起始消息，如果传 0，起始消息为会话的最新消息
 */
- (void)getC2CHistoryMessageList:(NSString *)userID count:(int)count lastMsg:(NSInteger)lastMsgSign succ:(BFIMMessageListSucc)succ fail:(BFIMFail)fail;

@end

NS_ASSUME_NONNULL_END
