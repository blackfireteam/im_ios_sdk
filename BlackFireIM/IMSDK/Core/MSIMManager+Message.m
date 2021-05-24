//
//  MSIMManager+Message.m
//  BlackFireIM
//
//  Created by benny wang on 2021/2/26.
//

#import "MSIMManager+Message.h"
#import "MSIMTools.h"
#import "MSIMErrorCode.h"
#import "MSDBFileRecordStore.h"
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
    [self initDefault:elem];
    return elem;
}

/** 创建图片消息
    如果是系统相册拿的图片，需要先把图片导入 APP 的目录下
 */
- (MSIMImageElem *)createImageMessage:(MSIMImageElem *)elem
{
    elem.type = BFIM_MSG_TYPE_IMAGE;
    [self initDefault:elem];
    return elem;
}

/** 创建音频消息
 */
- (MSIMVoiceElem *)createVoiceMessage:(MSIMVoiceElem *)elem
{
    elem.type = BFIM_MSG_TYPE_VOICE;
    [self initDefault:elem];
    return elem;
}

/** 创建视频消息
    如果是系统相册拿的视频，需要先把视频导入 APP 的目录下
 */
- (MSIMVideoElem *)createVideoMessage:(MSIMVideoElem *)elem
{
    elem.type = BFIM_MSG_TYPE_VIDEO;
    [self initDefault:elem];
    return elem;
}

/** 创建自定义消息 */
- (MSIMCustomElem *)createCustomMessage:(NSString *)jsonStr
{
    MSIMCustomElem *elem = [[MSIMCustomElem alloc]init];
    elem.jsonStr = jsonStr;
    elem.type = BFIM_MSG_TYPE_CUSTOM;
    [self initDefault:elem];
    return elem;
}

- (void)initDefault:(MSIMElem *)elem
{
    elem.fromUid = [MSIMTools sharedInstance].user_id;
    elem.sendStatus = BFIM_MSG_STATUS_SENDING;
    elem.readStatus = BFIM_MSG_STATUS_UNREAD;
    elem.msg_sign = [MSIMTools sharedInstance].adjustLocalTimeInterval;
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
        failed(ERR_USER_PARAMS_ERROR,@"params error");
        return;
    }
    elem.toUid = reciever;
    if (elem.type == BFIM_MSG_TYPE_TEXT) {
        [self sendTextMessage:(MSIMTextElem *)elem isResend:NO successed:success failed:failed];
    }else if (elem.type == BFIM_MSG_TYPE_IMAGE) {
        [self sendImageMessage:(MSIMImageElem *)elem isResend:NO successed:success failed:failed];
    }else if (elem.type == BFIM_MSG_TYPE_VIDEO) {
        [self sendVideoMessage:(MSIMVideoElem *)elem isResend:NO successed:success failed:failed];
    }else if (elem.type == BFIM_MSG_TYPE_VOICE) {
        [self sendVoiceMessage:(MSIMVoiceElem *)elem isResend:NO successed:success failed:failed];
    }else if (elem.type == BFIM_MSG_TYPE_CUSTOM) {
        [self sendCustomMessage:(MSIMCustomElem *)elem isResend:NO successed:success failed:failed];
    }else {
        failed(ERR_USER_PARAMS_ERROR,@"params error");
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
    if (elem.text.length == 0) {
        failed(ERR_USER_PARAMS_ERROR,@"文本消息内容为空");
        return;
    }
    if ([elem.text dataUsingEncoding:NSUTF8StringEncoding].length > 8 * 1024) {
        failed(ERR_IM_TEXT_MAX_ERROR,@"文本消息大小最大支持8k");
        return;
    }
    if (isResend == NO) {
        [self.messageStore addMessage:elem];
        [self.msgListener onNewMessages:@[elem]];
        [self elemNeedToUpdateConversations:@[elem] increaseUnreadCount:@[@(NO)] isConvLastMessage:NO];
    }
    ChatS *chats = [[ChatS alloc]init];
    chats.sign = elem.msg_sign;
    chats.type = elem.type;
    chats.body = elem.text;
    chats.toUid = elem.toUid.integerValue;
    WS(weakSelf)
    MSLog(@"[发送文本消息]ChatS:\n%@",chats);
    [self.socket send:[chats data] protoType:XMChatProtoTypeSend needToEncry:NO sign:chats.sign callback:^(NSInteger code, id  _Nullable response, NSString * _Nullable error) {
        STRONG_SELF(strongSelf)
        dispatch_async(dispatch_get_main_queue(), ^{
            if (code == ERR_SUCC) {
                ChatSR *result = response;
                if (success) success(result.msgId);
                [strongSelf sendMessageSuccessHandler:elem response:result];
            }else {
                if (failed) failed(code,error);
                [strongSelf sendMessageFailedHandler:elem code:code error:error];
            }
        });
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
    if (isResend == NO) {
        [self.msgListener onNewMessages:@[elem]];
        [self.messageStore addMessage:elem];
        [self elemNeedToUpdateConversations:@[elem] increaseUnreadCount:@[@(NO)] isConvLastMessage:NO];
    }
    if (elem.url.length == 0 || ![elem.url hasPrefix:@"http"]) {
        if (elem.uuid.length > 0) {
            MSDBFileRecordStore *store = [[MSDBFileRecordStore alloc]init];
            MSFileInfo *cacheElem = [store searchRecord:elem.uuid];
            if ([cacheElem.url hasPrefix:@"http"]) {
                elem.url = cacheElem.url;
                [self sendImageMessageByTCP:elem successed:success failed:failed];
            }else {
                [self uploadImage:elem successed:success failed:failed];
            }
        }else {
            [self uploadImage:elem successed:success failed:failed];
        }
        return;
    }
    [self sendImageMessageByTCP:elem successed:success failed:failed];
}

- (void)uploadImage:(MSIMImageElem *)elem
          successed:(void(^)(NSInteger msg_id))success
             failed:(void(^)(NSInteger code,NSString *errorString))failed
{
    WS(weakSelf)
    [self.uploadMediator ms_uploadWithObject:elem.image ? elem.image : elem.path
                                    fileType:BFIM_MSG_TYPE_IMAGE
                                    progress:^(CGFloat progress) {
        elem.progress = progress;
        [weakSelf.msgListener onMessageUpdateSendStatus:elem];
    }
                                        succ:^(NSString * _Nonnull url) {
        elem.progress = 1;
        elem.url = url;
        if (elem.uuid.length) {
            MSDBFileRecordStore *store = [[MSDBFileRecordStore alloc]init];
            MSFileInfo *info = [[MSFileInfo alloc]init];
            info.uuid = elem.uuid;
            info.url = elem.url;
            [store addRecord:info];
        }
        //上传成功，清除沙盒中的缓存
        [[NSFileManager defaultManager]removeItemAtPath:elem.path error:nil];
        
        [weakSelf.messageStore addMessage:elem];
        [weakSelf.msgListener onMessageUpdateSendStatus:elem];
        [weakSelf elemNeedToUpdateConversations:@[elem] increaseUnreadCount:@[@(NO)] isConvLastMessage:NO];
        [weakSelf sendImageMessageByTCP:elem successed:success failed:failed];
    }
                                        fail:^(NSInteger code, NSString * _Nonnull desc) {
        elem.progress = 0;
        [weakSelf sendMessageFailedHandler:elem code:code error:desc];
        if (failed) failed(code,desc);
    }];
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
    MSLog(@"[发送图片消息]ChatS:\n%@",chats);
    [self.socket send:[chats data] protoType:XMChatProtoTypeSend needToEncry:NO sign:chats.sign callback:^(NSInteger code, id  _Nullable response, NSString * _Nullable error) {
        STRONG_SELF(strongSelf)
        dispatch_async(dispatch_get_main_queue(), ^{
            if (code == ERR_SUCC) {
                ChatSR *result = response;
                [strongSelf sendMessageSuccessHandler:elem response:result];
                if (success) success(result.msgId);
            }else {
                if (failed) failed(code,error);
                [strongSelf sendMessageFailedHandler:elem code:code error:error];
            }
        });
    }];
}

/// 发送单聊普通视频消息
/// @param elem 视频消息
/// @param success 发送成功，返回消息的唯一标识ID
/// @param failed 发送失败
- (void)sendVideoMessage:(MSIMVideoElem *)elem
                isResend:(BOOL)isResend
               successed:(void(^)(NSInteger msg_id))success
                  failed:(void(^)(NSInteger code,NSString *errorString))failed
{
    if (isResend == NO) {
        [self.msgListener onNewMessages:@[elem]];
        [self.messageStore addMessage:elem];
        [self elemNeedToUpdateConversations:@[elem] increaseUnreadCount:@[@(NO)] isConvLastMessage:NO];
    }
    if (!([elem.videoUrl hasPrefix:@"http"] && [elem.coverUrl hasPrefix:@"http"])) {
        if (elem.uuid.length > 0) {
            MSDBFileRecordStore *store = [[MSDBFileRecordStore alloc]init];
            MSFileInfo *cacheElem = [store searchRecord:elem.uuid];
            if ([cacheElem.url hasPrefix:@"http"]) {
                elem.videoUrl = cacheElem.url;
            }
            [self uploadVideo:elem successed:success failed:failed];
        }else {
            [self uploadVideo:elem successed:success failed:failed];
        }
        return;
    }
    [self sendVideoMessageByTCP:elem successed:success failed:failed];
}

- (void)uploadVideo:(MSIMVideoElem *)elem
          successed:(void(^)(NSInteger msg_id))success
             failed:(void(^)(NSInteger code,NSString *errorString))failed
{
    WS(weakSelf)
    if ([elem.videoUrl hasPrefix:@"http"]) {
        //只需要上传图片
        [self.uploadMediator ms_uploadWithObject:elem.coverImage ? elem.coverImage : elem.coverPath
                                        fileType:BFIM_MSG_TYPE_IMAGE
                                        progress:^(CGFloat progress) {
            elem.progress = progress;
            [weakSelf.msgListener onMessageUpdateSendStatus:elem];
        }
                                            succ:^(NSString * _Nonnull url) {
            elem.progress = 1;
            elem.coverUrl = url;
            if (elem.uuid.length) {
                MSDBFileRecordStore *store = [[MSDBFileRecordStore alloc]init];
                MSFileInfo *info = [[MSFileInfo alloc]init];
                info.uuid = elem.uuid;
                info.url = elem.videoUrl;
                [store addRecord:info];
            }
            //上传成功，清除沙盒中的缓存
            [[NSFileManager defaultManager]removeItemAtPath:elem.coverPath error:nil];
            [[NSFileManager defaultManager]removeItemAtPath:elem.videoPath error:nil];
            
            [weakSelf.messageStore addMessage:elem];
            [weakSelf.msgListener onMessageUpdateSendStatus:elem];
            [weakSelf elemNeedToUpdateConversations:@[elem] increaseUnreadCount:@[@(NO)] isConvLastMessage:NO];
            [weakSelf sendVideoMessageByTCP:elem successed:success failed:failed];
        }
                                            fail:^(NSInteger code, NSString * _Nonnull desc) {
            elem.progress = 0;
            [weakSelf sendMessageFailedHandler:elem code:code error:desc];
            if (failed) failed(code,desc);
        }];
    }else {
        //先上传图片
        [self.uploadMediator ms_uploadWithObject:elem.coverImage ? elem.coverImage : elem.coverPath
                                        fileType:BFIM_MSG_TYPE_IMAGE
                                        progress:^(CGFloat coverProgress) {
            elem.progress = coverProgress*0.2;
            [weakSelf.msgListener onMessageUpdateSendStatus:elem];
        }
                                            succ:^(NSString * _Nonnull coverUrl) {
            elem.progress = 0.2;
            elem.coverUrl = coverUrl;
            //再上传视频
            [self.uploadMediator ms_uploadWithObject:elem.videoPath fileType:BFIM_MSG_TYPE_VIDEO progress:^(CGFloat videoProgress) {
                elem.progress = 0.2 + videoProgress*0.8;
                [weakSelf.msgListener onMessageUpdateSendStatus:elem];
            } succ:^(NSString * _Nonnull videoUrl) {
                
                elem.videoUrl = videoUrl;
                if (elem.uuid.length) {
                    MSDBFileRecordStore *store = [[MSDBFileRecordStore alloc]init];
                    MSFileInfo *info = [[MSFileInfo alloc]init];
                    info.uuid = elem.uuid;
                    info.url = elem.videoUrl;
                    [store addRecord:info];
                }
                //上传成功，清除沙盒中的缓存
                [[NSFileManager defaultManager]removeItemAtPath:elem.coverPath error:nil];
                [[NSFileManager defaultManager]removeItemAtPath:elem.videoPath error:nil];
                [weakSelf.messageStore addMessage:elem];
                [weakSelf.msgListener onMessageUpdateSendStatus:elem];
                [weakSelf elemNeedToUpdateConversations:@[elem] increaseUnreadCount:@[@(NO)] isConvLastMessage:NO];
                [weakSelf sendVideoMessageByTCP:elem successed:success failed:failed];
                
            } fail:^(NSInteger code, NSString * _Nonnull desc) {
                elem.progress = 0;
                [weakSelf sendMessageFailedHandler:elem code:code error:desc];
                if (failed) failed(code,desc);
            }];
        }
                                            fail:^(NSInteger code, NSString * _Nonnull desc) {
            elem.progress = 0;
            [weakSelf sendMessageFailedHandler:elem code:code error:desc];
            if (failed) failed(code,desc);
        }];
    }
}

- (void)sendVideoMessageByTCP:(MSIMVideoElem *)elem
                    successed:(void(^)(NSInteger msg_id))success
                       failed:(void(^)(NSInteger code,NSString *errorString))failed
{
    ChatS *chats = [[ChatS alloc]init];
    chats.sign = elem.msg_sign;
    chats.type = elem.type;
    chats.body = elem.videoUrl;
    chats.thumb = elem.coverUrl;
    chats.toUid = elem.toUid.integerValue;
    chats.width = elem.width;
    chats.height = elem.height;
    chats.duration = elem.duration;
    WS(weakSelf)
    MSLog(@"[发送视频消息]ChatS:\n%@",chats);
    [self.socket send:[chats data] protoType:XMChatProtoTypeSend needToEncry:NO sign:chats.sign callback:^(NSInteger code, id  _Nullable response, NSString * _Nullable error) {
        STRONG_SELF(strongSelf)
        dispatch_async(dispatch_get_main_queue(), ^{
            if (code == 0) {
                ChatSR *result = response;
                [strongSelf sendMessageSuccessHandler:elem response:result];
                if (success) success(result.msgId);
            }else {
                if (failed) failed(code,error);
                [strongSelf sendMessageFailedHandler:elem code:code error:error];
            }
        });
    }];
}

/// 发送单聊普通语音消息
/// @param elem 语音消息
/// @param success 发送成功，返回消息的唯一标识ID
/// @param failed 发送失败
- (void)sendVoiceMessage:(MSIMVoiceElem *)elem
                isResend:(BOOL)isResend
               successed:(void(^)(NSInteger msg_id))success
                  failed:(void(^)(NSInteger code,NSString *errorString))failed
{
    if (isResend == NO) {
        [self.msgListener onNewMessages:@[elem]];
        [self.messageStore addMessage:elem];
        [self elemNeedToUpdateConversations:@[elem] increaseUnreadCount:@[@(NO)] isConvLastMessage:NO];
    }
    if (elem.url.length == 0 || ![elem.url hasPrefix:@"http"]) {
        [self uploadVoice:elem successed:success failed:failed];
        return;
    }
    [self sendVoiceMessageByTCP:elem successed:success failed:failed];
}

- (void)uploadVoice:(MSIMVoiceElem *)elem
          successed:(void(^)(NSInteger msg_id))success
             failed:(void(^)(NSInteger code,NSString *errorString))failed
{
    WS(weakSelf)
    [self.uploadMediator ms_uploadWithObject:elem.path fileType:BFIM_MSG_TYPE_VOICE progress:^(CGFloat progress) {
        
    } succ:^(NSString * _Nonnull url) {
        elem.url = url;
        //上传成功，清除沙盒中的缓存
        [[NSFileManager defaultManager]removeItemAtPath:elem.path error:nil];
        
        [weakSelf.messageStore addMessage:elem];
        [weakSelf.msgListener onMessageUpdateSendStatus:elem];
        [weakSelf elemNeedToUpdateConversations:@[elem] increaseUnreadCount:@[@(NO)] isConvLastMessage:NO];
        [weakSelf sendVoiceMessageByTCP:elem successed:success failed:failed];
        
    } fail:^(NSInteger code, NSString * _Nonnull desc) {
        [weakSelf sendMessageFailedHandler:elem code:code error:desc];
        if (failed) failed(code,desc);
    }];
}

- (void)sendVoiceMessageByTCP:(MSIMVoiceElem *)elem
                    successed:(void(^)(NSInteger msg_id))success
                       failed:(void(^)(NSInteger code,NSString *errorString))failed
{
    ChatS *chats = [[ChatS alloc]init];
    chats.sign = elem.msg_sign;
    chats.type = elem.type;
    chats.body = elem.url;
    chats.duration = elem.duration;
    chats.toUid = elem.toUid.integerValue;
    WS(weakSelf)
    MSLog(@"[发送语音消息]ChatS:\n%@",chats);
    [self.socket send:[chats data] protoType:XMChatProtoTypeSend needToEncry:NO sign:chats.sign callback:^(NSInteger code, id  _Nullable response, NSString * _Nullable error) {
        STRONG_SELF(strongSelf)
        dispatch_async(dispatch_get_main_queue(), ^{
            if (code == 0) {
                ChatSR *result = response;
                [strongSelf sendMessageSuccessHandler:elem response:result];
                if (success) success(result.msgId);
            }else {
                [strongSelf sendMessageFailedHandler:elem code:code error:error];
                if (failed) failed(code,error);
            }
        });
    }];
}

/// 发送单聊自定义消息
/// @param elem 自定义消息
/// @param success 发送成功，返回消息的唯一标识ID
/// @param failed 发送失败
- (void)sendCustomMessage:(MSIMCustomElem *)elem
                 isResend:(BOOL)isResend
                successed:(void(^)(NSInteger msg_id))success
                   failed:(void(^)(NSInteger code,NSString *errorString))failed
{
    if (elem.jsonStr.length == 0) {
        failed(ERR_USER_PARAMS_ERROR,@"params error");
        return;
    }
    if (isResend == NO) {
        [self.messageStore addMessage:elem];
        [self.msgListener onNewMessages:@[elem]];
        [self elemNeedToUpdateConversations:@[elem] increaseUnreadCount:@[@(NO)] isConvLastMessage:NO];
    }
    ChatS *chats = [[ChatS alloc]init];
    chats.sign = elem.msg_sign;
    chats.type = elem.type;
    chats.body = elem.jsonStr;
    chats.toUid = elem.toUid.integerValue;
    WS(weakSelf)
    MSLog(@"[发送自定义消息]ChatS:\n%@",chats);
    [self.socket send:[chats data] protoType:XMChatProtoTypeSend needToEncry:NO sign:chats.sign callback:^(NSInteger code, id  _Nullable response, NSString * _Nullable error) {
        STRONG_SELF(strongSelf)
        dispatch_async(dispatch_get_main_queue(), ^{
            if (code == ERR_SUCC) {
                ChatSR *result = (ChatSR *)response;
                [strongSelf sendMessageSuccessHandler:elem response:result];
                if (success) success(result.msgId);
            }else {
                [strongSelf sendMessageFailedHandler:elem code:code error:error];
                if (failed) failed(code,error);
            }
        });
    }];
}

- (void)sendMessageSuccessHandler:(MSIMElem *)elem response:(ChatSR *)response
{
    elem.sendStatus = BFIM_MSG_STATUS_SEND_SUCC;
    elem.msg_id = response.msgId;
    [self.messageStore addMessage:elem];
    [self.msgListener onMessageUpdateSendStatus:elem];
    [self elemNeedToUpdateConversations:@[elem] increaseUnreadCount:@[@(NO)] isConvLastMessage:NO];
}

- (void)sendMessageFailedHandler:(MSIMElem *)elem code:(NSInteger)code error:(NSString *)error
{
    elem.sendStatus = BFIM_MSG_STATUS_SEND_FAIL;
    elem.code = code;
    elem.reason = error;
    [self.messageStore addMessage:elem];
    [self.msgListener onMessageUpdateSendStatus:elem];
    [self elemNeedToUpdateConversations:@[elem] increaseUnreadCount:@[@(NO)] isConvLastMessage:NO];
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
        failed(ERR_USER_PARAMS_ERROR,@"params error");
        return;
    }
    Revoke *revoke = [[Revoke alloc]init];
    revoke.sign = [MSIMTools sharedInstance].adjustLocalTimeInterval;
    revoke.toUid = reciever;
    revoke.msgId = msg_id;
    MSLog(@"[发送消息]Revoke:\n%@",revoke);
    [self.socket send:[revoke data] protoType:XMChatProtoTypeRecall needToEncry:NO sign:revoke.sign callback:^(NSInteger code, id  _Nullable response, NSString * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (code == ERR_SUCC) {
                
                success();
            }else {
                failed(code,error);
            }
        });
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
    [self.messageStore addMessage:elem];
    [self.msgListener onMessageUpdateSendStatus:elem];
    if (elem.type == BFIM_MSG_TYPE_TEXT) {
        [self sendTextMessage:(MSIMTextElem *)elem isResend:YES successed:success failed:failed];
    }else if (elem.type == BFIM_MSG_TYPE_IMAGE) {
        [self sendImageMessage:(MSIMImageElem *)elem isResend:YES successed:success failed:failed];
    }else if (elem.type == BFIM_MSG_TYPE_VIDEO) {
        [self sendVideoMessage:(MSIMVideoElem *)elem isResend:YES successed:success failed:failed];
    }else if (elem.type == BFIM_MSG_TYPE_VOICE) {
        [self sendVoiceMessage:(MSIMVoiceElem *)elem isResend:YES successed:success failed:failed];
    }else if (elem.type == BFIM_MSG_TYPE_CUSTOM) {
        [self sendCustomMessage:(MSIMCustomElem *)elem isResend:YES successed:success failed:failed];
    }else {
        failed(ERR_USER_PARAMS_ERROR,@"params error");
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
        fail(ERR_USER_PARAMS_ERROR,@"params error");
        return;
    }
    NSInteger tempCount = MIN(100, count);
    [self.messageStore messageByPartnerID:user_id last_msg_sign:lastMsgID count:tempCount complete:^(NSArray<MSIMElem *> * _Nonnull data, BOOL hasMore) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (succ) {
                succ(data,hasMore ? NO : YES);
            }
        });
    }];
}

@end
