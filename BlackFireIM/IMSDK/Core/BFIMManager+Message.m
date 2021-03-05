//
//  BFIMManager+Message.m
//  BlackFireIM
//
//  Created by benny wang on 2021/2/26.
//

#import "BFIMManager+Message.h"
#import "BFIMTools.h"
#import "ChatProtobuf.pbobjc.h"


@implementation BFIMManager (Message)

/** 创建文本消息*/
- (BFIMTextElem *)prepareTextMessage:(NSString *)text toUid:(NSString *)to_uid
{
    BFIMTextElem *elem = [[BFIMTextElem alloc]init];
    elem.text = text;
    elem.type = BFIMMessageTypeText;
    elem.fromUid = [BFIMTools sharedInstance].user_id;
    elem.toUid = to_uid;
    elem.sendStatus = BFIM_MSG_STATUS_SENDING;
    elem.readStatus = BFIM_MSG_STATUS_UNREAD;
    elem.msg_sign = [BFIMTools sharedInstance].adjustLocalTimeInterval;
    return elem;
}

/** 创建图片消息（图片文件最大支持 28 MB）
    如果是系统相册拿的图片，需要先把图片导入 APP 的目录下
 */
- (BFIMImageElem *)prepareImageMessage:(BFIMImageElem *)elem toUid:(NSString *)to_uid
{
    elem.type = BFIMMessageTypeImage;
    elem.fromUid = [BFIMTools sharedInstance].user_id;
    elem.toUid = to_uid;
    elem.sendStatus = BFIM_MSG_STATUS_SENDING;
    elem.readStatus = BFIM_MSG_STATUS_UNREAD;
    elem.msg_sign = [BFIMTools sharedInstance].adjustLocalTimeInterval;
    return elem;
}

/// 发送单聊普通文本消息（最大支持 8KB
/// @param elem 文本消息
/// @param success 发送成功，返回消息的唯一标识ID
/// @param failed 发送失败
- (void)sendTextMessage:(BFIMTextElem *)elem
              successed:(void(^)(NSInteger msg_id))success
                 failed:(void(^)(NSInteger code,NSString *errorString))failed
{
    ChatS *chats = [[ChatS alloc]init];
    chats.sign = elem.msg_sign;
    chats.type = elem.type;
    chats.body = elem.text;
    [self send:[chats data] protoType:XMChatProtoTypeSend needToEncry:NO sign:chats.sign callback:^(NSInteger code, id  _Nullable response, NSString * _Nullable error) {
        if (code == 0) {
            
        }else {
            NSLog(@"发送失败");
        }
    }];
}

/// 发送单聊普通图片消息
/// @param elem 图片消息
/// @param success 发送成功，返回消息的唯一标识ID
/// @param failed 发送失败
- (void)sendImage:(BFIMImageElem *)elem
        successed:(void(^)(NSInteger msg_id))success
           failed:(void(^)(NSInteger code,NSString *errorString))failed
{
    ChatS *chats = [[ChatS alloc]init];
    chats.sign = elem.msg_sign;
    chats.type = elem.type;
    chats.body = elem.url;
    [self send:[chats data] protoType:XMChatProtoTypeSend needToEncry:NO sign:chats.sign callback:^(NSInteger code, id  _Nullable response, NSString * _Nullable error) {
        if (code == 0) {
            
        }else {
            NSLog(@"发送失败");
        }
    }];
}

///接收到新消息处理
- (void)recieveMessages:(NSArray<ChatR *> *)msgs
{
    for (ChatR *response in msgs) {
        switch (response.type) {
            case BFIMMessageTypeText://文字消息
            {
                
            }
                break;
            case BFIMMessageTypeImage://图片消息
            {
                
            }
                break;
            case BFIMMessageTypeMsgRecall://消息撤回
            {
                
            }
                break;
            default:
                break;
        }
    }
}

/**
 *  获取单聊历史消息
 *
 *  @param count 拉取消息的个数，不宜太多，会影响消息拉取的速度，这里建议一次拉取 20 个
 *  @param lastMsgSign 获取消息的起始消息，如果传 0，起始消息为会话的最新消息
 */
- (void)getC2CHistoryMessageList:(NSString *)userID count:(int)count lastMsg:(NSInteger)lastMsgSign succ:(BFIMMessageListSucc)succ fail:(BFIMFail)fail
{
    [self.messageStore messageByPartnerID:userID last_msg_sign:lastMsgSign count:count complete:^(NSArray<BFIMElem *> * _Nonnull data, BOOL hasMore) {
        if (succ) {
            succ(data);
        }
    }];
}

@end
