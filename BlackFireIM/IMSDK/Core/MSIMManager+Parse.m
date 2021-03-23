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
        conv.msg_start = item.msgStart;
        conv.msg_end = item.msgEnd;
        conv.show_msg_id = item.showMsgId;
        conv.msg_last_read = item.msgLastRead;
        conv.unread_count = item.unread;
        conv.userInfo = [[MSProfileProvider provider] providerProfileFromLocal:item.uid];
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
        //拉取最后一页聊天记录
        WS(weakSelf)
        [self getC2CHistoryMessageList:conv.partner_id count:20 lastMsg:item.msgEnd succ:^(NSArray<MSIMElem *> * _Nonnull msgs, BOOL isFinished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                MSIMElem *lastElem = nil;
                for (MSIMElem *msg in msgs) {
                    if ([msg.partner_id isEqualToString:conv.partner_id]) {
                        lastElem = msg;
                    }
                }
                if (lastElem && weakSelf.convListener && [weakSelf.convListener respondsToSelector:@selector(onUpdateConversations:)]) {
                    conv.show_msg = lastElem;
                    [weakSelf.convListener onUpdateConversations:@[conv]];
                }
            });
                } fail:^(NSInteger code, NSString * _Nonnull desc) {
                    
        }];
    }
    NSInteger update_time = list.updateTime;
    if (update_time) {//批量下发的会话结束,写入数据库
        //更新Profile信息
        [[MSProfileProvider provider] synchronizeProfiles:profiles];
        BOOL isOK = [self.convStore addConversations:self.convCaches];
        //通知会话有更新
        if (isOK && self.convListener && [self.convListener respondsToSelector:@selector(onUpdateConversations:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.convListener onUpdateConversations:self.convCaches];
            });
        }
        if (self.convListener && [self.convListener respondsToSelector:@selector(onSyncServerFinish)]) {
            [self.convListener onSyncServerFinish];
        }
        [self.convCaches removeAllObjects];
    }
}

///收到服务器下发的消息处理
- (void)recieveMessages:(NSArray<ChatR *> *)responses
{
    NSMutableArray *recieves = [NSMutableArray array];
    for (ChatR *response in responses) {
        MSIMElem *elem = nil;
        if (response.type == BFIM_MSG_TYPE_RECALL) {//消息撤回
            elem = [[MSIMElem alloc]init];
            elem.type = BFIM_MSG_TYPE_NULL;
            //将之前的消息标记为撤回消息
            NSInteger f_id = [[NSString stringWithFormat:@"%lld",response.fromUid] isEqualToString:[MSIMTools sharedInstance].user_id] ? response.toUid : response.fromUid;
            [self.messageStore updateMessageRevoke:[response.body integerValue] partnerID:[NSString stringWithFormat:@"%zd",f_id]];
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
    if (recieves.count > 0) {
        BOOL isOK = [self.messageStore addMessages:recieves];
        if (isOK) {//数据库保存成功，通知和代理同时下发
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.msgListener && [self.msgListener respondsToSelector:@selector(onNewMessages:)]) {
                    [self.msgListener onNewMessages:recieves];
                }
            });
        }
    }
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

@end
