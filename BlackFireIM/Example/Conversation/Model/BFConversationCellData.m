//
//  BFConversationCellData.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/18.
//

#import "BFConversationCellData.h"
#import "BFHeader.h"


@implementation BFConversationCellData

- (NSAttributedString *)subTitle
{
    NSString *lastMsgStr = self.conv.show_msg.displayStr;
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

- (NSString *)title
{
    return self.conv.userInfo.nick_name;
}

- (UIImage *)avatarImage
{
    if (self.conv.chat_type == BFIM_CHAT_TYPE_C2C) {
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
