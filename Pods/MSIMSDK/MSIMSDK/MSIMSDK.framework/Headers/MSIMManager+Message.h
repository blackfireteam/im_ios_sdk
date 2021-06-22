//
//  MSIMManager+Message.h
//  BlackFireIM
//
//  Created by benny wang on 2021/2/26.
//
#import <MSIMSDK/MSIMManager.h>
#import <MSIMSDK/MSIMElem.h>



NS_ASSUME_NONNULL_BEGIN

@class ChatR;

/// 获取历史消息成功回调
typedef void (^BFIMMessageListSucc)(NSArray<MSIMElem *> * msgs,BOOL isFinished);

@interface MSIMManager (Message)

/////////////////////////////////////////////////////////////////////////////////
//
//                         创建和发送文本、图片等消息接口
//
/////////////////////////////////////////////////////////////////////////////////
/** 创建文本消息 文本最大支持 8k*/
- (MSIMTextElem *)createTextMessage:(NSString *)text;

/** 创建图片消息
    如果是系统相册拿的图片，需要先把图片导入 APP 的目录下
 */
- (MSIMImageElem *)createImageMessage:(MSIMImageElem *)elem;

/** 创建音频消息
 */
- (MSIMVoiceElem *)createVoiceMessage:(MSIMVoiceElem *)elem;


/** 创建视频消息
    如果是系统相册拿的视频，需要先把视频导入 APP 的目录下
 */
- (MSIMVideoElem *)createVideoMessage:(MSIMVideoElem *)elem;

/** 创建自定义消息 */
- (MSIMCustomElem *)createCustomMessage:(NSString *)jsonStr;

/// 发送单聊消息
/// @param elem 消息体
/// @param reciever 接收者Uid
/// @param success 发送成功，返回消息的唯一标识ID
/// @param failed 发送失败
- (void)sendC2CMessage:(MSIMElem *)elem
            toReciever:(NSString *)reciever
             successed:(void(^)(NSInteger msg_id))success
                failed:(MSIMFail)failed;



/// 请求撤回某一条消息
/// @param reciever 会话对方的uid
/// @param msg_id 消息的唯一ID
/// @param success 撤回成功
/// @param failed 撤回失败
- (void)revokeMessage:(NSInteger)msg_id
           toReciever:(NSInteger)reciever
            successed:(MSIMSucc)success
               failed:(MSIMFail)failed;


/// 单聊消息重发
/// @param elem 消息体
/// @param reciever 接收者Uid
/// @param success 发送成功，返回消息的唯一标识ID
/// @param failed 发送失败
- (void)resendC2CMessage:(MSIMElem *)elem
              toReciever:(NSString *)reciever
               successed:(void(^)(NSInteger msg_id))success
                  failed:(MSIMFail)failed;

/////////////////////////////////////////////////////////////////////////////////
//
//                         获取历史消息、撤回、删除、标记已读等接口
//
/////////////////////////////////////////////////////////////////////////////////
/**
 *  获取单聊历史消息
 *
 *  @param count 拉取消息的个数，不宜太多，会影响消息拉取的速度，这里建议一次拉取 20 个
 *  @param lastMsgID 获取消息的起始消息，如果传 0，起始消息为会话的最新消息
 */
- (void)getC2CHistoryMessageList:(NSString *)user_id
                           count:(int)count
                         lastMsg:(NSInteger)lastMsgID
                            succ:(BFIMMessageListSucc)succ
                            fail:(MSIMFail)fail;


@end

NS_ASSUME_NONNULL_END
