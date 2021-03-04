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
- (BFIMTextElem *)prepareTextMessage:(NSString *)text toUid:(NSInteger)to_uid
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
- (BFIMImageElem *)prepareImageMessage:(BFIMImageElem *)elem toUid:(NSInteger)to_uid
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

@end
