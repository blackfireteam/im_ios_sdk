//
//  MSIMManager+Conversation.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/8.
//

#import "MSIMManager+Conversation.h"
#import "MSIMTools.h"
#import "MSIMConst.h"
#import "MSIMErrorCode.h"
#import "MSProfileProvider.h"

@implementation MSIMManager (Conversation)


- (void)synchronizeConversationList
{
    GetChatList *request = [[GetChatList alloc]init];
    request.sign = [MSIMTools sharedInstance].adjustLocalTimeInterval;
    request.updateTime = [self.convStore lastMessageEnd];
//    WS(weakSelf)
    [self send:[request data] protoType:XMChatProtoTypeGetChatList needToEncry:NO sign:request.sign callback:^(NSInteger code, id  _Nullable response, NSString * _Nullable error) {
//        STRONG_SELF(strongSelf)
        if (code == ERR_SUCC) {
        }else {
            NSLog(@"建立链接与服务器同步会话列表失败.%@", error);
        }
    }];
}

/// 分页拉取会话列表
/// @param nextSeq 分页拉取游标，第一次默认取传 0，后续分页拉传上一次分页拉取回调里的 nextSeq
/// @param count 分页拉取的个数，一次分页拉取不宜太多，会影响拉取的速度，建议每次拉取 100 个会话
/// @param succ 拉取成功
/// @param fail 拉取失败
- (void)getConversationList:(NSInteger)nextSeq
                      count:(int)count
                       succ:(MSIMConversationListSucc)succ
                       fail:(MSIMFail)fail
{
    if (nextSeq < 0 || count <= 0) {
        fail(ERR_USER_PARAMS_ERROR,@"参数异常");
        return;
    }
    [self.convStore conversationsWithLast_msg_id:nextSeq count:count complete:^(NSArray<MSIMConversation *> * _Nonnull data, BOOL hasMore) {
        //组装最后一条消息和头像昵称等信息
        for (MSIMConversation *conv in data) {
            MSIMElem *elem = [self.messageStore searchMessage:conv.partner_id msg_id:conv.show_msg_id];
            conv.show_msg = elem;
            MSProfileInfo *info = [[MSProfileProvider provider] providerProfileFromLocal:conv.partner_id.integerValue];
            conv.userInfo = info;
        }
        MSIMConversation *lastConv = data.lastObject;
        NSInteger nextSign = lastConv.msg_end;
        succ(data,nextSign,hasMore ? NO : YES);
    }];
}

///删除某一条会话
///删除会话不会只会删除会话记录，不会删除会话对应的聊天内容
- (void)deleteConversation:(MSIMConversation *)conv
                      succ:(MSIMSucc)succed
                    failed:(MSIMFail)failed
{
    if (conv == nil) {
        failed(ERR_USER_PARAMS_ERROR,@"参数异常");
        return;
    }
    DelChat *delRequest = [[DelChat alloc]init];
    delRequest.sign = [MSIMTools sharedInstance].adjustLocalTimeInterval;
    delRequest.toUid = conv.partner_id.integerValue;
    [self send:[delRequest data] protoType:XMChatProtoTypeDeleteChat needToEncry:NO sign:delRequest.sign callback:^(NSInteger code, id  _Nullable response, NSString * _Nullable error) {
        if (code == ERR_SUCC) {
            [self.convStore deleteConversation:conv.conversation_id];
            succed();
        }else {
            failed(ERR_SDK_DB_DEL_CONVERSATION_FAIL,@"删除会话失败");
        }
    }];
}

///标记消息已读状态
///msgID 标记的对方发给我的消息的 id
- (void)markC2CMessageAsRead:(NSString *)user_id
                   lastMsgID:(NSInteger)msgID
                        succ:(MSIMSucc)succed
                      failed:(MSIMFail)failed
{
    if (user_id.length == 0 || msgID <= 0) {
        failed(ERR_USER_PARAMS_ERROR,@"参数异常");
        return;
    }
    MsgRead *request = [[MsgRead alloc]init];
    request.sign = [MSIMTools sharedInstance].adjustLocalTimeInterval;
    request.toUid = user_id.integerValue;
    request.msgId = msgID;
    [self send:[request data] protoType:XMChatProtoTypeMsgread needToEncry:NO sign:request.sign callback:^(NSInteger code, id  _Nullable response, NSString * _Nullable error) {
        if (code == ERR_SUCC) {
            
        }
    }];
}

@end
