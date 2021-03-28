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

- (BOOL)elemNeedToUpdateConversation:(MSIMElem *)elem
{
    MSIMConversation *conv = [[MSConversationProvider provider]providerConversation:elem.partner_id];
    if (conv == nil) {
        conv = [[MSIMConversation alloc]init];
        conv.chat_type = BFIM_CHAT_TYPE_C2C;
        conv.partner_id = elem.partner_id;
        conv.show_msg = elem;
        conv.show_msg_sign = elem.msg_sign;
        conv.msg_end = elem.msg_id;
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
                [weakSelf elemNeedToUpdateConversation:lastElem];
            });
                } fail:^(NSInteger code, NSString * _Nonnull desc) {
        }];
    }
}

///收到服务器下发的消息处理
- (void)recieveMessages:(NSArray<ChatR *> *)responses
{
    NSArray<MSIMElem *> *msgs = [self chatHistoryHandler:responses];
    msgs = [msgs sortedArrayUsingComparator:^NSComparisonResult(MSIMElem *obj1, MSIMElem *obj2) {
        if (obj1.msg_id > obj2.msg_id) {
            return NSOrderedDescending;
        }
        return NSOrderedAscending;
    }];
    MSIMElem *lastElem = msgs.lastObject;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (lastElem.type == BFIM_MSG_TYPE_NULL) {
            MSIMElem *showElem = [self.messageStore lastShowMessage:lastElem.partner_id];
            showElem.msg_id = lastElem.msg_id;
            [self elemNeedToUpdateConversation:showElem];
        }else {
            [self elemNeedToUpdateConversation:lastElem];
        }
    });
    //更新会话更新时间
    [[MSIMTools sharedInstance]updateConversationTime:lastElem.msg_sign];
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
            [self.messageStore updateMessageRevoke:[response.body integerValue] partnerID:elem.partner_id];
            if (response.sign > 0) {//收到申请撤回的结果
                [self sendMessageResponse:response.sign resultCode:ERR_SUCC resultMsg:@"消息已撤回" response:response];
            }
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
    [self.convStore updateConvesation:[NSString stringWithFormat:@"%lld",result.fromUid] unread_count:result.unread];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.convListener && [self.convListener respondsToSelector:@selector(onUpdateUnreadCountInConversation:unreadCount:)]) {
            [self.convListener onUpdateUnreadCountInConversation:[NSString stringWithFormat:@"c2c_%lld",result.fromUid] unreadCount:result.unread];
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
