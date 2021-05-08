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
#import "MSIMMessageReceipt.h"


@implementation MSIMManager (Parse)


- (void)profilesResultHandler:(NSArray<Profile *> *)list
{
    NSMutableArray *arr = [NSMutableArray array];
    for (Profile *p in list) {
        MSProfileInfo *info = [MSProfileInfo createWithProto:p];
        [arr addObject:info];
    }
    [[MSProfileProvider provider] updateProfiles:arr];
    [self.profileListener onProfileUpdates:arr];
}

///服务器返回的会话列表数据处理
- (void)chatListResultHandler:(ChatList *)list
{
    NSArray *items = list.chatItemsArray;
    for (ChatItem *item in items) {
        MSIMConversation *conv = [[MSIMConversation alloc]init];
        conv.chat_type = BFIM_CHAT_TYPE_C2C;
        conv.partner_id = [NSString stringWithFormat:@"%lld",item.uid];
        conv.msg_end = item.msgEnd;
        conv.show_msg_sign = item.showMsgTime;
        conv.msg_last_read = item.msgLastRead;
        conv.unread_count = item.unread;
        conv.deleted = item.deleted;
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
        if (info == nil) {
            info = [[MSProfileInfo alloc]init];
            info.update_time = 0;
            info.user_id = [NSString stringWithFormat:@"%lld",item.uid];
        }
        [self.profileCaches addObject:info];
    }
    NSInteger update_time = list.updateTime;
    if (update_time) {//批量下发的会话结束,写入数据库
        //顺便同步下自己的Profile
        MSProfileInfo *me = [[MSProfileProvider provider]providerProfileFromLocal:[[MSIMTools sharedInstance].user_id integerValue]];
        if (!me) {
            me = [[MSProfileInfo alloc]init];
            me.user_id = [MSIMTools sharedInstance].user_id;
        }
        [self.profileCaches addObject:me];
        
        //更新Profile信息
        [[MSProfileProvider provider] synchronizeProfiles:self.profileCaches];
        //更新会话缓存
        [[MSConversationProvider provider]updateConversations:self.convCaches];
        //同步最后一页聊天数据,如果需要同步的会话太多时，只同步最多50条
        NSArray *firstPageConvs = (self.convCaches.count > self.config.chatListPageCount ? [self.convCaches subarrayWithRange:NSMakeRange(0, self.config.chatListPageCount)] : self.convCaches);
        [self updateConvLastMessage:firstPageConvs];
        self.isChatListResult = YES;
        [self updateChatListUpdateTime:MAX(self.chatUpdateTime, update_time)];
        //通知会话有更新
        if ([self.convListener respondsToSelector:@selector(onUpdateConversations:)]) {
            [self.convListener onUpdateConversations:firstPageConvs];
        }
        if ([self.convListener respondsToSelector:@selector(onSyncServerFinish)]) {
            [self.convListener onSyncServerFinish];
        }
        [self.convCaches removeAllObjects];
        [self.profileCaches removeAllObjects];
    }
}

- (void)elemNeedToUpdateConversations:(NSArray<MSIMElem *> *)elems increaseUnreadCount:(NSArray<NSNumber *> *)increases
{
    NSMutableArray *needConvs = [NSMutableArray array];
    NSMutableArray *needProfiles = [NSMutableArray array];
    for (NSInteger i = 0; i < elems.count; i++) {
        MSIMElem *elem = elems[i];
        BOOL increase = [increases[i] boolValue];
        MSIMConversation *conv = [[MSConversationProvider provider]providerConversation:elem.partner_id];
        if (conv == nil) {
            conv = [[MSIMConversation alloc]init];
            conv.chat_type = BFIM_CHAT_TYPE_C2C;
            conv.partner_id = elem.partner_id;
            conv.show_msg = elem;
            conv.show_msg_sign = elem.msg_sign;
            conv.msg_end = elem.msg_id;
            MSProfileInfo *profile = [[MSProfileProvider provider]providerProfileFromLocal:elem.partner_id.integerValue];
            if (profile == nil || profile.update_time == 0) {
                MSProfileInfo *info = [[MSProfileInfo alloc]init];
                info.user_id = elem.partner_id;
                [needProfiles addObject:info];
            }
            [needConvs addObject:conv];
        }
        if(elem.msg_sign >= conv.show_msg_sign) {
            conv.show_msg_sign = elem.msg_sign;
            conv.show_msg = elem;
            if (elem.msg_id > conv.msg_end) {
                conv.msg_end = elem.msg_id;
            }
            conv.deleted = 0;
            if (increase) {
                conv.unread_count += 1;
            }
            [needConvs addObject:conv];
        }
    }
    [[MSProfileProvider provider]synchronizeProfiles:needProfiles];
    if (needConvs.count) {
        [[MSConversationProvider provider]updateConversations:needConvs];
        [self.convListener onUpdateConversations:needConvs];
    }
}

- (void)updateConvLastMessage:(NSArray *)convs
{
    //拉取最后一页聊天记录
    WS(weakSelf)
    NSMutableArray *tempConvs = [NSMutableArray array];
    NSMutableArray *tempIncreases = [NSMutableArray array];
    NSInteger convsCount = convs.count;
    __block NSInteger total = 0;
    for (MSIMConversation *conv in convs) {
        [self.messageStore messageByPartnerID:conv.partner_id last_msg_sign:0 count:20 complete:^(NSArray<MSIMElem *> * _Nonnull data, BOOL hasMore) {
            //重新取出数据表中最后一条消息
            MSIMElem *lastElem = [weakSelf.messageStore lastShowMessage:conv.partner_id];
            if (lastElem) {
                [tempConvs addObject:lastElem];
                [tempIncreases addObject:@(NO)];
            }else {
                MSLog(@"拉取最后一页聊天记录失败");
            }
            total += 1;
            if (total >= convsCount) {
                [weakSelf elemNeedToUpdateConversations:tempConvs increaseUnreadCount:tempIncreases];
                [tempConvs removeAllObjects];
                [tempIncreases removeAllObjects];
            }
        }];
    }
}

///收到服务器下发的消息处理
- (void)recieveMessage:(ChatR *)response
{
    MSIMElem *elem = [self chatHistoryHandler:@[response]].lastObject;
    if (elem.type == BFIM_MSG_TYPE_NULL) {
        MSIMElem *showElem = [self.messageStore lastShowMessage:elem.partner_id];
        showElem.msg_id = elem.msg_id;
        [self elemNeedToUpdateConversations:@[showElem] increaseUnreadCount:@[@(NO)]];
    }else {
        if ([self.msgListener respondsToSelector:@selector(onNewMessages:)]) {
            [self.msgListener onNewMessages:@[elem]];
        }
        [self elemNeedToUpdateConversations:@[elem] increaseUnreadCount:(elem.isSelf ? @[@(NO)] : @[@(YES)])];
    }
    //更新会话更新时间
    [self updateChatListUpdateTime:elem.msg_sign];
    //更新profile
    MSProfileInfo *fromProfile = [[MSProfileProvider provider]providerProfileFromLocal:response.fromUid];
    if (!fromProfile) {
        fromProfile = [[MSProfileInfo alloc]init];
    }
    if (fromProfile.update_time < response.sput) {
        [[MSProfileProvider provider]synchronizeProfiles:@[fromProfile].mutableCopy];
    }
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
            
            if ([self.msgListener respondsToSelector:@selector(onRevokeMessage:)]) {
                [self.msgListener onRevokeMessage:elem];
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
        }else if (response.type == BFIM_MSG_TYPE_VIDEO) {
            MSIMVideoElem *videoElem = [[MSIMVideoElem alloc]init];
            videoElem.width = response.width;
            videoElem.height = response.height;
            videoElem.videoUrl = response.body;
            videoElem.coverUrl = response.thumb;
            videoElem.duration = response.duration;
            videoElem.type = BFIM_MSG_TYPE_VIDEO;
            elem = videoElem;
        }else if (response.type == BFIM_MSG_TYPE_VOICE) {
            MSIMVoiceElem *voiceElem = [[MSIMVoiceElem alloc]init];
            voiceElem.url = response.body;
            voiceElem.duration = response.duration;
            voiceElem.type = BFIM_MSG_TYPE_VOICE;
            elem = voiceElem;
        }else if (response.type == BFIM_MSG_TYPE_REVOKE) {
            elem = [[MSIMElem alloc]init];
            elem.type = BFIM_MSG_TYPE_REVOKE;
        }else if (response.type == BFIM_MSG_TYPE_CUSTOM) {
            MSIMCustomElem *customElem = [[MSIMCustomElem alloc]init];
            customElem.data = [response.body dataUsingEncoding:NSUTF8StringEncoding];
            customElem.type = BFIM_MSG_TYPE_CUSTOM;
            elem = customElem;
        }else {//未知消息
            MSIMElem *unknowElem = [[MSIMElem alloc]init];
            unknowElem.type = BFIM_MSG_TYPE_UNKNOWN;
            elem = unknowElem;
        }
        elem.fromUid = [NSString stringWithFormat:@"%lld",response.fromUid];
        elem.toUid = [NSString stringWithFormat:@"%lld",response.toUid];
        elem.msg_id = response.msgId;
        elem.msg_sign = response.msgTime;
        elem.sendStatus = BFIM_MSG_STATUS_SEND_SUCC;
        MSIMConversation *conv = [[MSConversationProvider provider]providerConversation:elem.partner_id];
        if (elem.isSelf && elem.msg_id > conv.msg_last_read) {
            elem.readStatus = BFIM_MSG_STATUS_UNREAD;
        }else {
            elem.readStatus = BFIM_MSG_STATUS_READ;
        }
        [recieves addObject:elem];
    }
    [self.messageStore addMessages:recieves];
    return recieves;
}

///服务器返回的用户上线通知处理
- (void)userOnLineHandler:(ProfileOnline *)online
{
    MSProfileInfo *info = [[MSProfileInfo alloc]init];
    info.user_id = [NSString stringWithFormat:@"%lld",online.uid];
    info.nick_name = online.nickName;
    info.avatar = online.avatar;
    info.gold = online.gold;
    info.update_time = online.updateTime;
    info.verified = online.verified;
    [[MSProfileProvider provider] updateProfiles:@[info]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"MSUIKitNotification_Profile_online" object:@(online.uid)];
    });
}

///服务器返回的用户下线通知处理
- (void)userOfflineHandler:(UsrOffline *)offline
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"MSUIKitNotification_Profile_offline" object:@(offline.uid)];
    });
}

///会话某些属性发生变更
- (void)chatListChanged:(ChatItemUpdate *)item
{
    if (item.event == 0) {//msg_last_read 变动
        
        [self chatMarkReadChanged:item];
        MSLog(@"[收到]msg_last_read 变动 : %@",item);
    }else if (item.event == 1) {//unread 数变动
        
        [self chatUnreadCountChanged:item];
        MSLog(@"[收到]unread 数变动 : %@",item);
    }else if (item.event == 2) {//i_block_u 变动
        
        [self chatListBlockChanged:item];
        MSLog(@"[收到]i_block_u 变动 : %@",item);
    }else if (item.event == 3) {//deleted 变动
        
        [self deleteChatHandler:item];
        MSLog(@"[收到]deleted 变动 : %@",item);
    }
}

///服务器返回的删除会话的处理
- (void)deleteChatHandler:(ChatItemUpdate *)result
{
    [self sendMessageResponse:result.sign resultCode:ERR_SUCC resultMsg:@"" response:result];
    NSString *partner_id = [NSString stringWithFormat:@"%lld",result.uid];
    [[MSConversationProvider provider]deleteConversation: partner_id];
    if (self.convListener && [self.convListener respondsToSelector:@selector(conversationDidDelete:)]) {
        [self.convListener conversationDidDelete:partner_id];
    }
    //更新会话更新时间
    [self updateChatListUpdateTime:result.updateTime];
}

- (void)chatListBlockChanged:(ChatItemUpdate *)result
{
    MSIMConversation *conv = [[MSConversationProvider provider]providerConversation:[NSString stringWithFormat:@"%lld",result.uid]];
    conv.ext.i_block_u = result.iBlockU;
    [[MSConversationProvider provider]updateConversations:@[conv]];
    [self.convListener onUpdateConversations:@[conv]];
    [self updateChatListUpdateTime:result.updateTime];
}

//我主动发起的标记消息已读
- (void)chatUnreadCountChanged:(ChatItemUpdate *)result
{
    NSString *fromUid = [NSString stringWithFormat:@"%lld",result.uid];
    MSIMConversation *conv = [[MSConversationProvider provider]providerConversation:fromUid];
    conv.unread_count = result.unread;
    [[MSConversationProvider provider]updateConversations:@[conv]];
    if (self.convListener && [self.convListener respondsToSelector:@selector(onUpdateConversations:)]) {
        [self.convListener onUpdateConversations:@[conv]];
    }
    [self updateChatListUpdateTime:result.updateTime];
}

//对方发起的标记消息已读
- (void)chatMarkReadChanged:(ChatItemUpdate *)result
{
    NSString *fromUid = [NSString stringWithFormat:@"%lld",result.uid];
    MSIMConversation *conv = [[MSConversationProvider provider]providerConversation:fromUid];
    conv.msg_last_read = result.msgLastRead;
    [[MSConversationProvider provider]updateConversations:@[conv]];
    [self.messageStore markMessageAsRead:result.msgLastRead partnerID:fromUid];
    
    MSIMMessageReceipt *receipt = [[MSIMMessageReceipt alloc]init];
    receipt.msg_id = result.msgLastRead;
    receipt.user_id = fromUid;
    if (self.msgListener && [self.convListener respondsToSelector:@selector(onRecvC2CReadReceipt:)]) {
        [self.msgListener onRecvC2CReadReceipt:receipt];
    }
    [self updateChatListUpdateTime:result.updateTime];
}

@end
