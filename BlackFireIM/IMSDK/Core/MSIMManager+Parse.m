//
//  MSIMManager+Parse.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/16.
//

#import "MSIMManager+Parse.h"
#import "ChatProtobuf.pbobjc.h"
#import "MSProfileProvider.h"
#import "MSIMErrorCode.h"
#import "MSIMConversation.h"
#import "MSIMManager+Message.h"
#import "MSIMTools.h"
#import "MSConversationProvider.h"

@implementation MSIMManager (Parse)


- (void)profilesResultHandler:(ProfileList *)list
{
    for (Profile *p in list.profilesArray) {
        MSProfileInfo *info = [MSProfileInfo createWithProto:p];
        [[MSProfileProvider provider] updateProfile:info];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.profileListener onProfileUpdate:info];
        });
    }
}

///服务器返回的会话列表数据处理
- (void)chatListResultHandler:(ChatList *)list
{
    NSArray *items = list.chatItemsArray;
    NSMutableArray *profiles = [NSMutableArray array];
    for (ChatItem *item in items) {
        MSIMConversation *conv = [[MSIMConversation alloc]init];
        conv.chat_type = BFIM_CHAT_TYPE_C2C;
        conv.partner_id = [NSString stringWithFormat:@"%lld",item.uid];
        conv.msg_end = item.msgEnd;
        conv.msg_last_read = item.msgLastRead;
        conv.unread_count = item.unread;
        MSCustomExt *ext = [[MSCustomExt alloc]init];
        ext.matched = item.matched;
        ext.i_block_u = item.iBlockU;
        ext.new_msg = item.newMsg;
        ext.my_move = item.myMove;
        ext.ice_break = item.iceBreak;
        ext.tip_free = item.tipFree;
        ext.top_album = item.topAlbum;
        conv.ext = ext;
        [self.convCaches addObject:conv];
        MSProfileInfo *info = [[MSProfileProvider provider] providerProfileFromLocal:item.uid];
        if (info) {
            [profiles addObject:info];
        }else {
            MSProfileInfo *tempP = [[MSProfileInfo alloc]init];
            tempP.update_time = 0;
            tempP.user_id = [NSString stringWithFormat:@"%lld",item.uid];
            [profiles addObject:tempP];
        }
    }
    NSInteger update_time = list.updateTime;
    if (update_time) {//批量下发的会话结束,写入数据库
        [[MSIMTools sharedInstance] updateConversationTime:update_time];
        //更新Profile信息
        [[MSProfileProvider provider] synchronizeProfiles:profiles];
        //更新会话缓存
        [[MSConversationProvider provider]updateConversations:self.convCaches];
        [self updateConvLastMessage:self.convCaches];
        //通知会话有更新
        if ([self.convListener respondsToSelector:@selector(onUpdateConversations:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.convListener onUpdateConversations:self.convCaches];
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.convListener respondsToSelector:@selector(onSyncServerFinish)]) {
                [self.convListener onSyncServerFinish];
            }
        });
        [self.convCaches removeAllObjects];
    }
}

- (BOOL)elemNeedToUpdateConversation:(MSIMElem *)elem increaseUnreadCount:(BOOL)increase
{
    MSIMConversation *conv = [[MSConversationProvider provider]providerConversation:elem.partner_id];
    if (conv == nil) {
        conv = [[MSIMConversation alloc]init];
        conv.chat_type = BFIM_CHAT_TYPE_C2C;
        conv.partner_id = elem.partner_id;
        conv.show_msg = elem;
        conv.show_msg_sign = elem.msg_sign;
        conv.msg_end = elem.msg_id;
        if (increase) {
            conv.unread_count += 1;
        }
        MSProfileInfo *profile = [[MSProfileProvider provider]providerProfileFromLocal:elem.partner_id.integerValue];
        if (profile == nil) {
            MSProfileInfo *info = [[MSProfileInfo alloc]init];
            info.user_id = elem.partner_id;
            [[MSProfileProvider provider]synchronizeProfiles:@[info]];
        }
        [self.convListener onUpdateConversations:@[conv]];
        [[MSConversationProvider provider]updateConversation:conv];
        return YES;
    }
    if(elem.msg_sign >= conv.show_msg_sign) {
        conv.show_msg_sign = elem.msg_sign;
        conv.show_msg = elem;
        if (elem.msg_id > conv.msg_end) {
            conv.msg_end = elem.msg_id;
        }
        if (increase) {
            conv.unread_count += 1;
        }
        [self.convListener onUpdateConversations:@[conv]];
        [[MSConversationProvider provider]updateConversation:conv];
        return YES;
    }
    return NO;
}

- (void)updateConvLastMessage:(NSArray *)convs
{
    //拉取最后一页聊天记录
    WS(weakSelf)
    for (MSIMConversation *conv in convs) {
        [self getC2CHistoryMessageList:conv.partner_id count:20 lastMsg:0 succ:^(NSArray<MSIMElem *> * _Nonnull msgs, BOOL isFinished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                MSIMElem *lastElem = msgs.firstObject;
                [weakSelf elemNeedToUpdateConversation:lastElem increaseUnreadCount:NO];
            });
                } fail:^(NSInteger code, NSString * _Nonnull desc) {
        }];
    }
}

///收到服务器下发的消息处理
- (void)recieveMessage:(ChatR *)response
{
    MSIMElem *elem = [self chatHistoryHandler:@[response]].lastObject;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (elem.type == BFIM_MSG_TYPE_NULL) {
            MSIMElem *showElem = [self.messageStore lastShowMessage:elem.partner_id];
            showElem.msg_id = elem.msg_id;
            [self elemNeedToUpdateConversation:showElem increaseUnreadCount:NO];
        }else {
            if ([self.msgListener respondsToSelector:@selector(onNewMessages:)]) {
                [self.msgListener onNewMessages:@[elem]];
            }
            [self elemNeedToUpdateConversation:elem increaseUnreadCount:YES];
        }
    });
    //更新会话更新时间
    [[MSIMTools sharedInstance]updateConversationTime:elem.msg_sign];
}

///服务器返回的历史数据处理
- (NSArray<MSIMElem *> *)chatHistoryHandler:(NSArray<ChatR *> *)responses
{
    NSMutableArray *recieves = [NSMutableArray array];
    for (ChatR *response in responses) {
        MSIMElem *elem = nil;
        if (response.type == BFIM_MSG_TYPE_RECALL) {//消息撤回
            elem = [[MSIMElem alloc]init];
            elem.type = BFIM_MSG_TYPE_NULL;
            
            //将之前的消息标记为撤回消息
            elem.fromUid = [NSString stringWithFormat:@"%lld",response.fromUid];
            elem.toUid = [NSString stringWithFormat:@"%lld",response.toUid];
            elem.revoke_msg_id = response.body.integerValue;
            [self.messageStore updateMessageRevoke:elem.revoke_msg_id partnerID:elem.partner_id];
            [self sendMessageResponse:response.sign resultCode:ERR_SUCC resultMsg:@"消息已撤回" response:response];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.msgListener respondsToSelector:@selector(onRevokeMessage:)]) {
                    [self.msgListener onRevokeMessage:elem];
                }
            });
        }else if (response.type == BFIM_MSG_TYPE_TEXT) {
            MSIMTextElem *textElem = [[MSIMTextElem alloc]init];
            textElem.text = response.body;
            textElem.type = BFIM_MSG_TYPE_TEXT;
            elem = textElem;
            
        }else if (response.type == BFIM_MSG_TYPE_IMAGE) {
            MSIMImageElem *imageElem = [[MSIMImageElem alloc]init];
            imageElem.width = response.width;
            imageElem.height = response.height;
            imageElem.url = response.body;
            imageElem.type = BFIM_MSG_TYPE_IMAGE;
            elem = imageElem;
        }else if (response.type == BFIM_MSG_TYPE_VIDEO) {
            MSIMVideoElem *videoElem = [[MSIMVideoElem alloc]init];
            videoElem.width = response.width;
            videoElem.height = response.height;
            videoElem.videoUrl = response.body;
            videoElem.coverUrl = response.thumb;
            videoElem.duration = response.duration;
            videoElem.type = BFIM_MSG_TYPE_VIDEO;
            elem = videoElem;
        }else if (response.type == BFIM_MSG_TYPE_REVOKE) {
            elem = [[MSIMElem alloc]init];
            elem.type = BFIM_MSG_TYPE_REVOKE;
        }
        if (elem) {
            elem.fromUid = [NSString stringWithFormat:@"%lld",response.fromUid];
            elem.toUid = [NSString stringWithFormat:@"%lld",response.toUid];
            elem.msg_id = response.msgId;
            elem.msg_sign = response.msgTime;
            elem.sendStatus = BFIM_MSG_STATUS_SEND_SUCC;
            elem.readStatus = BFIM_MSG_STATUS_UNREAD;
            [recieves addObject:elem];
        }
    }
    [self.messageStore addMessages:recieves];
    return recieves;
}

- (void)chatUnreadCountChanged:(LastReadMsg *)result
{
    MSIMConversation *conv = [[MSConversationProvider provider]providerConversation:[NSString stringWithFormat:@"%lld",result.fromUid]];
    conv.unread_count = result.unread;
    [[MSConversationProvider provider]updateConversation:conv];
    //更新会话更新时间
    [[MSIMTools sharedInstance]updateConversationTime:result.updateTime];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.convListener && [self.convListener respondsToSelector:@selector(onUpdateConversations:)]) {
            [self.convListener onUpdateConversations:@[conv]];
        }
    });
}

///服务器返回的用户上线通知处理
- (void)userOnLineHandler:(ProfileOnline *)online
{
    MSProfileInfo *info = [[MSProfileInfo alloc]init];
    info.user_id = [NSString stringWithFormat:@"%lld",online.uid];
    info.nick_name = online.nickName;
    info.avatar = online.avatar;
    info.gold = online.gold;
    info.verified = online.verified;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"MSUIKitNotification_Profile_online" object:info];
    });
}

///服务器返回的用户下线通知处理
- (void)userOfflineHandler:(UsrOffline *)offline
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *user_id = [NSString stringWithFormat:@"%lld",offline.uid];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"MSUIKitNotification_Profile_offline" object:user_id];
    });
}

@end
