//
//  MSUIConversationCellData.m
//  BlackFireIM
//
//  Created by benny wang on 2021/5/28.
//

#import "MSUIConversationCellData.h"
#import "MSIMSDK-UIKit.h"

@implementation MSUIConversationCellData

- (NSAttributedString *)subTitle
{
    NSString *lastMsgStr = [self getDisplayString:self.conv.show_msg];
    if (lastMsgStr.length == 0 && self.conv.draftText.length == 0) {
        return nil;
    }
    NSMutableAttributedString *attr;
    if (self.conv.draftText.length > 0) {
        NSString *show_msg = [NSString stringWithFormat:@"%@ %@",TUILocalizableString(TUIKitMessageTypeDraft),self.conv.draftText];
        attr = [[NSMutableAttributedString alloc]initWithString:show_msg];
        [attr setAttributes:@{NSForegroundColorAttributeName: [UIColor d_systemGrayColor],NSFontAttributeName: [UIFont systemFontOfSize:14]} range:NSMakeRange(0, attr.length)];
        [attr setAttributes:@{NSForegroundColorAttributeName: [UIColor redColor],NSFontAttributeName: [UIFont systemFontOfSize:14]} range:NSMakeRange(0, TUILocalizableString(TUIKitMessageTypeDraft).length)];
    }else {
        attr = [[NSMutableAttributedString alloc]initWithString:lastMsgStr];
        [attr setAttributes:@{NSForegroundColorAttributeName: [UIColor d_systemGrayColor],NSFontAttributeName: [UIFont systemFontOfSize:14]} range:NSMakeRange(0, attr.length)];
    }
    return attr;
}

- (NSString *)getDisplayString:(MSIMMessage *)message
{
    NSString *str;
    if (message.type == MSIM_MSG_TYPE_REVOKE) {
        if (message.isSelf) {
            str = TUILocalizableString(TUIKitMessageTipsYouRecallMessage);
        }else {
            str = TUILocalizableString(TUIkitMessageTipsOthersRecallMessage);
        }
    }else if (message.isSnapChat) {
        str = TUILocalizableString(TUIkitMessageTipsSnapChatMessage);
    }else {
        switch (message.type) {
            case MSIM_MSG_TYPE_TEXT:
            {
                str = message.textElem.text;
            }
                break;
            case MSIM_MSG_TYPE_IMAGE:
            {
                str = TUILocalizableString(TUIkitMessageTypeImage);
            }
                break;
            case MSIM_MSG_TYPE_VOICE:
            {
                str = TUILocalizableString(TUIKitMessageTypeVoice);
            }
                break;
            case MSIM_MSG_TYPE_VIDEO:
            {
                str = TUILocalizableString(TUIkitMessageTypeVideo);
            }
                break;
            case MSIM_MSG_TYPE_LOCATION:
            {
                str = TUILocalizableString(TUIkitMessageTypeLocation);
            }
                break;
            case MSIM_MSG_TYPE_EMOTION:
            {
                str = TUILocalizableString(TUIKitMessageTypeAnimateEmoji);
            }
                break;
            case MSIM_MSG_TYPE_CUSTOM_IGNORE_UNREADCOUNT_RECALL:
            case MSIM_MSG_TYPE_CUSTOM_UNREADCOUNT_NO_RECALL:
            case MSIM_MSG_TYPE_CUSTOM_UNREADCOUNT_RECAL:
            {
                str = [self getCustomElemContent:message];
            }
                break;
            default:
            {
                str = TUILocalizableString(TUIkitMessageTipsUnknowMessage);
            }
                break;
        }
    }
    return str;
}

///配置自定义消息在会话中展示的内容
- (NSString *)getCustomElemContent:(MSIMMessage *)message
{
    MSIMCustomElem *customElem = message.customElem;
    NSDictionary *dic = [customElem.jsonStr el_convertToDictionary];
    if ([dic[@"type"]integerValue] == MSIMCustomSubTypeVoiceCall) {
        return [MSCallManager parseToConversationShow:dic callType:MSCallType_Voice isSelf:message.isSelf];
    }else if ([dic[@"type"]integerValue] == MSIMCustomSubTypeVideoCall) {
        return [MSCallManager parseToConversationShow:dic callType:MSCallType_Video isSelf:message.isSelf];
    }else if ([dic[@"type"]integerValue] == MSIMCustomSubTypeLike) {
        return @"[Like]";
    }else {
        return TUILocalizableString(TUIKitMessageTipsUnsupportCustomMessage);
    }
}

- (NSString *)title
{
    return self.conv.userInfo.nick_name;
}

- (UIImage *)avatarImage
{
    if (self.conv.chat_type == MSIM_CHAT_TYPE_C2C) {
        return [UIImage bf_imageNamed:@"holder_avatar"];
    }else {
        return [UIImage bf_imageNamed:@"holder_avatar"];
    }
}

- (NSDate *)time
{
    if (self.conv.time == 0) {
        return nil;
    }
    return [NSDate dateWithTimeIntervalSince1970:self.conv.time/1000/1000];
}

@end
