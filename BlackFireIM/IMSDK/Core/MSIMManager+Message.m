//
//  MSIMManager+Message.m
//  BlackFireIM
//
//  Created by benny wang on 2021/2/26.
//

#import "MSIMManager+Message.h"
#import "MSIMTools.h"
#import "MSIMErrorCode.h"
#import "MSDBImageFileStore.h"
#import "NSString+Ext.h"
#import "NSFileManager+filePath.h"
#import "MSIMManager+Parse.h"


@implementation MSIMManager (Message)

/** 创建文本消息*/
- (MSIMTextElem *)createTextMessage:(NSString *)text
{
    MSIMTextElem *elem = [[MSIMTextElem alloc]init];
    elem.text = text;
    elem.type = BFIM_MSG_TYPE_TEXT;
    elem.fromUid = [MSIMTools sharedInstance].user_id;
    elem.sendStatus = BFIM_MSG_STATUS_SENDING;
    elem.readStatus = BFIM_MSG_STATUS_READ;
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
    elem.readStatus = BFIM_MSG_STATUS_READ;
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
        MSIMTextElem *textElem = (MSIMTextElem *)elem;
        if (textElem.text.length == 0) {
            failed(ERR_USER_PARAMS_ERROR,@"文本消息内容为空");
            return;
        }
        if ([textElem.text dataUsingEncoding:NSUTF8StringEncoding].length > 8 * 1024) {
            failed(ERR_IM_TEXT_MAX_ERROR,@"文本消息大小最大支持8k");
            return;
        }
        [self sendTextMessage:(MSIMTextElem *)elem isResend:NO successed:success failed:failed];
    }else if (elem.type == BFIM_MSG_TYPE_IMAGE) {
        [self sendImageMessage:(MSIMImageElem *)elem isResend:NO successed:success failed:failed];
    }else {
        failed(ERR_USER_PARAMS_ERROR,@"参数异常");
    }
}

/// 发送单聊普通文本消息（最大支持 8KB
/// @param elem 文本消息
/// @param success 发送成功，返回消息的唯一标识ID
/// @param failed 发送失败
- (void)sendTextMessage:(MSIMTextElem *)elem
               isResend:(BOOL)isResend
              successed:(void(^)(NSInteger msg_id))success
                 failed:(void(^)(NSInteger code,NSString *errorString))failed
{
    if (isResend == NO) {
        [self.messageStore addMessage:elem];
        [self.msgListener onNewMessages:@[elem]];
    }
    ChatS *chats = [[ChatS alloc]init];
    chats.sign = elem.msg_sign;
    chats.type = elem.type;
    chats.body = elem.text;
    chats.toUid = elem.toUid.integerValue;
    WS(weakSelf)
    NSLog(@"[发送消息]ChatS:\n%@",chats);
    [self send:[chats data] protoType:XMChatProtoTypeSend needToEncry:NO sign:chats.sign callback:^(NSInteger code, id  _Nullable response, NSString * _Nullable error) {
        STRONG_SELF(strongSelf)
        if (code == ERR_SUCC) {
            ChatSR *result = response;
            success(result.msgId);
            elem.sendStatus = BFIM_MSG_STATUS_SEND_SUCC;
            elem.msg_id = result.msgId;
            [strongSelf.messageStore updateMessageToSuccss:chats.sign msg_id:elem.msg_id partnerID:elem.partner_id];
            [strongSelf.msgListener onMessageUpdateSendStatus:elem];
            [strongSelf elemNeedToUpdateConversation:elem];
        }else {
            NSLog(@"发送失败");
            failed(code,error);
            elem.sendStatus = BFIM_MSG_STATUS_SEND_FAIL;
            elem.code = code;
            elem.reason = error;
            [strongSelf.messageStore updateMessageToFail:chats.sign code:elem.code reason:elem.reason partnerID:elem.toUid];
            [strongSelf.msgListener onMessageUpdateSendStatus:elem];
            [strongSelf elemNeedToUpdateConversation:elem];
        }
    }];
}

/// 发送单聊普通图片消息
/// @param elem 图片消息
/// @param success 发送成功，返回消息的唯一标识ID
/// @param failed 发送失败
- (void)sendImageMessage:(MSIMImageElem *)elem
                isResend:(BOOL)isResend
               successed:(void(^)(NSInteger msg_id))success
                  failed:(void(^)(NSInteger code,NSString *errorString))failed
{
    if (elem.url.length == 0 || ![elem.url hasPrefix:@"http"]) {
        if (elem.uuid.length > 0) {
            MSDBImageFileStore *store = [[MSDBImageFileStore alloc]init];
            MSImageInfo *imageInfo = [store searchRecord:elem.uuid];
            if ([imageInfo.url hasPrefix:@"http"]) {
                elem.url = imageInfo.url;
                [self.msgListener onNewMessages:@[elem]];
                [self.messageStore addMessage:elem];
                [self elemNeedToUpdateConversation:elem];
                [self sendImageMessageByTCP:elem successed:success failed:failed];
            }else {
                [self uploadImage:elem successed:success failed:failed];
            }
        }else {
            [self uploadImage:elem successed:success failed:failed];
        }
        return;
    }
    if (isResend == NO) {
        [self.msgListener onNewMessages:@[elem]];
        [self.messageStore addMessage:elem];
        [self elemNeedToUpdateConversation:elem];
    }
    [self sendImageMessageByTCP:elem successed:success failed:failed];
}

- (void)uploadImage:(MSIMImageElem *)elem
          successed:(void(^)(NSInteger msg_id))success
             failed:(void(^)(NSInteger code,NSString *errorString))failed
{
    if (elem.path == nil || ![[NSFileManager defaultManager]fileExistsAtPath:elem.path]) {
        failed(ERR_USER_PARAMS_ERROR,@"图片资源不存在");
    }else {
        //先压缩
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:elem.path]];
        if (imageData == nil) {
            failed(ERR_USER_PARAMS_ERROR,@"图片资源不存在");
            return;
        }
        NSString *imageExt = [NSString contentTypeForImageData:imageData];
        if ([imageExt isEqualToString:@"png"] || [imageExt isEqualToString:@"jpeg"]) {
            [self.msgListener onNewMessages:@[elem]];
            [self.messageStore addMessage:elem];
            [self elemNeedToUpdateConversation:elem];
            UIImage *image = [UIImage imageWithData:imageData];
            if (image.size.width > 1920 || image.size.height > 1920) {
                CGFloat aspectRadio = MIN(1920/image.size.width, 1920/image.size.height);
                CGFloat aspectWidth = image.size.width * aspectRadio;
                CGFloat aspectHeight = image.size.height * aspectRadio;
                
                UIGraphicsBeginImageContext(CGSizeMake(aspectWidth, aspectHeight));
                [image drawInRect:CGRectMake(0, 0, aspectWidth, aspectHeight)];
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                NSString *savePath = [[NSFileManager pathForIMImage] stringByAppendingPathComponent:[elem.path pathExtension]];
                [[NSFileManager defaultManager] createFileAtPath:savePath contents:imageData attributes:nil];
                elem.path = savePath;
                
                //再上传
            }else {
                //再上传
            }
        }else if ([imageExt isEqualToString:@"gif"]) {
            if (imageData.length > 28*1024*1028) {
                failed(ERR_IM_IMAGE_MAX_ERROR,@"图片大小超过限制");
                return;
            }
            [self.msgListener onNewMessages:@[elem]];
            [self.messageStore addMessage:elem];
            [self elemNeedToUpdateConversation:elem];
            //再上传
        }else {
            failed(ERR_IM_IMAGE_TYPE_ERROR,@"图片类型不支持");
        }
    }
}

- (void)sendImageMessageByTCP:(MSIMImageElem *)elem
                    successed:(void(^)(NSInteger msg_id))success
                       failed:(void(^)(NSInteger code,NSString *errorString))failed
{
    ChatS *chats = [[ChatS alloc]init];
    chats.sign = elem.msg_sign;
    chats.type = elem.type;
    chats.body = elem.url;
    chats.toUid = elem.toUid.integerValue;
    chats.width = elem.width;
    chats.height = elem.height;
    WS(weakSelf)
    NSLog(@"[发送消息]ChatS:\n%@",chats);
    [self send:[chats data] protoType:XMChatProtoTypeSend needToEncry:NO sign:chats.sign callback:^(NSInteger code, id  _Nullable response, NSString * _Nullable error) {
        STRONG_SELF(strongSelf)
        if (code == 0) {
            ChatSR *result = response;
            elem.sendStatus = BFIM_MSG_STATUS_SEND_SUCC;
            elem.msg_id = result.msgId;
            [strongSelf.messageStore updateMessageToSuccss:chats.sign msg_id:elem.msg_id partnerID:elem.toUid];
            [strongSelf.msgListener onMessageUpdateSendStatus:elem];
            [strongSelf elemNeedToUpdateConversation:elem];
            success(result.msgId);
        }else {
            NSLog(@"发送失败");
            failed(code,error);
            elem.sendStatus = BFIM_MSG_STATUS_SEND_FAIL;
            elem.code = code;
            elem.reason = error;
            [strongSelf.messageStore updateMessageToFail:chats.sign code:elem.code reason:elem.reason partnerID:elem.toUid];
            [strongSelf.msgListener onMessageUpdateSendStatus:elem];
            [strongSelf elemNeedToUpdateConversation:elem];
        }
    }];
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
    NSLog(@"[发送消息]Revoke:\n%@",revoke);
    [self send:[revoke data] protoType:XMChatProtoTypeRecall needToEncry:NO sign:revoke.sign callback:^(NSInteger code, id  _Nullable response, NSString * _Nullable error) {
        
        if (code == ERR_SUCC) {
            
            success();
        }else {
            failed(code,error);
        }
    }];
}

/// 单聊消息重发
/// @param elem 消息体
/// @param reciever 接收者Uid
/// @param success 发送成功，返回消息的唯一标识ID
/// @param failed 发送失败
- (void)resendC2CMessage:(MSIMElem *)elem
              toReciever:(NSString *)reciever
               successed:(void(^)(NSInteger msg_id))success
                  failed:(MSIMFail)failed
{
    elem.sendStatus = BFIM_MSG_STATUS_SENDING;
    [self.messageStore updateMessageToSending:elem.msg_sign partnerID:reciever];
    [self.msgListener onMessageUpdateSendStatus:elem];
    if (elem.type == BFIM_MSG_TYPE_TEXT) {
        [self sendTextMessage:(MSIMTextElem *)elem isResend:YES successed:success failed:failed];
    }else if (elem.type == BFIM_MSG_TYPE_IMAGE) {
        [self sendImageMessage:(MSIMImageElem *)elem isResend:YES successed:success failed:failed];
    }else {
        failed(ERR_USER_PARAMS_ERROR,@"参数异常");
    }
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
    [self.messageStore messageByPartnerID:user_id last_msg_sign:lastMsgID count:count complete:^(NSArray<MSIMElem *> * _Nonnull data, BOOL hasMore) {
            if (succ) {
                succ(data,hasMore ? NO : YES);
            }
    }];
}

@end
