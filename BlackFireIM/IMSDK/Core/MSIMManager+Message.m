//
//  MSIMManager+Message.m
//  BlackFireIM
//
//  Created by benny wang on 2021/2/26.
//

#import "MSIMManager+Message.h"
#import "MSIMTools.h"
#import "MSIMErrorCode.h"


@implementation MSIMManager (Message)

/** 创建文本消息*/
- (MSIMTextElem *)createTextMessage:(NSString *)text
{
    MSIMTextElem *elem = [[MSIMTextElem alloc]init];
    elem.text = text;
    elem.type = BFIM_MSG_TYPE_TEXT;
    elem.fromUid = [MSIMTools sharedInstance].user_id;
    elem.sendStatus = BFIM_MSG_STATUS_SENDING;
    elem.readStatus = BFIM_MSG_STATUS_UNREAD;
    elem.msg_sign = [MSIMTools sharedInstance].adjustLocalTimeInterval;
    return elem;
}

/** 创建图片消息（图片文件最大支持 28 MB）
    如果是系统相册拿的图片，需要先把图片导入 APP 的目录下
 */
- (MSIMImageElem *)createImageMessage:(MSIMImageElem *)elem
{
    elem.type = BFIM_MSG_TYPE_IMAGE;
    elem.fromUid = [MSIMTools sharedInstance].user_id;
    elem.sendStatus = BFIM_MSG_STATUS_SENDING;
    elem.readStatus = BFIM_MSG_STATUS_UNREAD;
    elem.msg_sign = [MSIMTools sharedInstance].adjustLocalTimeInterval;
    return elem;
}

/// 发送单聊消息
/// @param elem 消息体
/// @param reciever 接收者Uid
/// @param success 发送成功，返回消息的唯一标识ID
/// @param failed 发送失败
- (void)sendC2CMessage:(MSIMElem *)elem
            toReciever:(NSString *)reciever
             successed:(void(^)(NSInteger msg_id))success
                failed:(MSIMFail)failed
{
    if (elem == nil) {
        failed(ERR_USER_SEND_EMPTY,@"消息为空");
        return;
    }
    if (reciever == nil || elem.msg_sign == 0) {
        failed(ERR_USER_PARAMS_ERROR,@"参数异常");
        return;
    }
    elem.toUid = reciever;
    if (elem.type == BFIM_MSG_TYPE_TEXT) {
        [self sendTextMessage:(MSIMTextElem *)elem successed:success failed:failed];
    }else if (elem.type == BFIM_MSG_TYPE_IMAGE) {
        [self sendImageMessage:(MSIMImageElem *)elem successed:success failed:failed];
    }else {
        failed(ERR_USER_PARAMS_ERROR,@"参数异常");
    }
}

/// 发送单聊普通文本消息（最大支持 8KB
/// @param elem 文本消息
/// @param success 发送成功，返回消息的唯一标识ID
/// @param failed 发送失败
- (void)sendTextMessage:(MSIMTextElem *)elem
              successed:(void(^)(NSInteger msg_id))success
                 failed:(void(^)(NSInteger code,NSString *errorString))failed
{
    if (elem.text.length == 0) {
        failed(ERR_USER_PARAMS_ERROR,@"文本消息内容为空");
        return;
    }
    //先写入数据库
    BOOL isOK = [self.messageStore addMessage:elem];
    if (isOK) {
        ChatS *chats = [[ChatS alloc]init];
        chats.sign = elem.msg_sign;
        chats.type = elem.type;
        chats.body = elem.text;
        chats.toUid = elem.toUid.integerValue;
        WS(weakSelf)
        [self send:[chats data] protoType:XMChatProtoTypeSend needToEncry:NO sign:chats.sign callback:^(NSInteger code, id  _Nullable response, NSString * _Nullable error) {
            STRONG_SELF(strongSelf)
            if (code == ERR_SUCC) {
                ChatSR *result = response;
                success(result.msgId);
                [strongSelf.messageStore updateMessage:chats.sign sendStatus:BFIM_MSG_STATUS_SEND_SUCC partnerID:elem.toUid];
            }else {
                NSLog(@"发送失败");
                failed(code,error);
                [strongSelf.messageStore updateMessage:chats.sign sendStatus:BFIM_MSG_STATUS_SEND_FAIL partnerID:elem.toUid];
            }
        }];
    }else {
        failed(ERR_SDK_DB_WRITE_FAIL,@"数据库写入失败");
    }
}

/// 发送单聊普通图片消息
/// @param elem 图片消息
/// @param success 发送成功，返回消息的唯一标识ID
/// @param failed 发送失败
- (void)sendImageMessage:(MSIMImageElem *)elem
               successed:(void(^)(NSInteger msg_id))success
                  failed:(void(^)(NSInteger code,NSString *errorString))failed;
{
    if (elem.url.length == 0) {
        failed(ERR_USER_PARAMS_ERROR,@"图片消息Url为空");
        return;
    }
    //先写入数据库
    BOOL isOK = [self.messageStore addMessage:elem];
    if (isOK) {
        ChatS *chats = [[ChatS alloc]init];
        chats.sign = elem.msg_sign;
        chats.type = elem.type;
        chats.body = elem.url;
        chats.toUid = elem.toUid.integerValue;
        chats.width = elem.width;
        chats.height = elem.height;
        WS(weakSelf)
        [self send:[chats data] protoType:XMChatProtoTypeSend needToEncry:NO sign:chats.sign callback:^(NSInteger code, id  _Nullable response, NSString * _Nullable error) {
            STRONG_SELF(strongSelf)
            if (code == 0) {
                ChatSR *result = response;
                [strongSelf.messageStore updateMessage:chats.sign sendStatus:BFIM_MSG_STATUS_SEND_SUCC partnerID:elem.toUid];
                success(result.msgId);
            }else {
                NSLog(@"发送失败");
                failed(code,error);
                [strongSelf.messageStore updateMessage:chats.sign sendStatus:BFIM_MSG_STATUS_SEND_FAIL partnerID:elem.toUid];
            }
        }];
    }else {
        failed(ERR_SDK_DB_WRITE_FAIL,@"数据库写入失败");
    }
}

/// 请求撤回某一条消息
/// @param reciever 会话对方的uid
/// @param msg_id 消息的唯一ID
/// @param success 撤回成功
/// @param failed 撤回失败
- (void)revokeMessage:(NSInteger)msg_id
           toReciever:(NSInteger)reciever
            successed:(MSIMSucc)success
               failed:(MSIMFail)failed
{
    if (!reciever || !msg_id) {
        failed(ERR_USER_PARAMS_ERROR,@"参数异常");
        return;
    }
    Revoke *revoke = [[Revoke alloc]init];
    revoke.sign = [MSIMTools sharedInstance].adjustLocalTimeInterval;
    revoke.toUid = reciever;
    revoke.msgId = msg_id;
    WS(weakSelf)
    [self send:[revoke data] protoType:XMChatProtoTypeRecall needToEncry:NO sign:revoke.sign callback:^(NSInteger code, id  _Nullable response, NSString * _Nullable error) {
        STRONG_SELF(strongSelf)
        if (code == ERR_SUCC) {
            ChatR *chatr = response;
            //将之前的消息标记为撤回消息
            [strongSelf.messageStore updateMessageRevoke:revoke.sign partnerID:[NSString stringWithFormat:@"%lld",revoke.toUid]];
            //再插入一条撤回消息
            MSIMElem *elem = [[MSIMElem alloc]init];
            elem.msg_id = chatr.msgId;
            elem.msg_sign = [MSIMTools sharedInstance].adjustLocalTimeInterval;
            elem.fromUid = [MSIMTools sharedInstance].user_id;
            elem.toUid = [NSString stringWithFormat:@"%lld",revoke.toUid];
            elem.type = BFIM_MSG_TYPE_RECALL;
            [strongSelf.messageStore addMessage:elem];
            success();
        }else {
            failed(code,error);
        }
    }];
}

/**
 *  获取单聊历史消息
 *
 *  @param count 拉取消息的个数，不宜太多，会影响消息拉取的速度，这里建议一次拉取 20 个
 *  @param lastMsgID 获取消息的起始消息
 */
- (void)getC2CHistoryMessageList:(NSString *)user_id
                           count:(int)count
                         lastMsg:(NSInteger)lastMsgID
                            succ:(BFIMMessageListSucc)succ
                            fail:(MSIMFail)fail
{
    if (user_id.length == 0 || count <= 0) {
        fail(ERR_USER_PARAMS_ERROR,@"参数异常");
        return;
    }
    [self.messageStore messageByPartnerID:user_id last_msg_id:lastMsgID count:count*2 complete:^(NSArray<MSIMElem *> * _Nonnull data, BOOL hasMore) {
        if (succ) {
            succ(data,hasMore ? NO : YES);
        }
    }];
}

@end
