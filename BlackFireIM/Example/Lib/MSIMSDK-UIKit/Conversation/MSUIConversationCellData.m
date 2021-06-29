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

- (NSString *)getDisplayString:(MSIMElem *)elem
{
    NSString *str;
    if (elem.type == MSIM_MSG_TYPE_REVOKE) {
        if (elem.isSelf) {
            str = TUILocalizableString(TUIKitMessageTipsYouRecallMessage);
        }else {
            str = TUILocalizableString(TUIkitMessageTipsOthersRecallMessage);
        }
    }else {
        switch (elem.type) {
            case MSIM_MSG_TYPE_TEXT:
            {
                str = ((MSIMTextElem *)elem).text;
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
            case MSIM_MSG_TYPE_CUSTOM_IGNORE_UNREADCOUNT_RECALL:
            case MSIM_MSG_TYPE_CUSTOM_UNREADCOUNT_NO_RECALL:
            case MSIM_MSG_TYPE_CUSTOM_UNREADCOUNT_RECAL:
            {
                str = [self getCustomElemContent:elem];
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
- (NSString *)getCustomElemContent:(MSIMElem *)elem
{
    MSIMCustomElem *customElem = (MSIMCustomElem *)elem;
    if (customElem.pushExt.body.length) {
        return customElem.pushExt.body;
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
        return [UIImage bf_imageNamed:@"default_c2c_head"];
    }else {
        return [UIImage bf_imageNamed:@"default_group_head"];
    }
}

- (NSDate *)time
{
    return [NSDate dateWithTimeIntervalSince1970:self.conv.time/1000/1000];
}

@end
