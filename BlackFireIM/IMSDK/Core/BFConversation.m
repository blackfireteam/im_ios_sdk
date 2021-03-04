//
//  BFConversation.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/3.
//

#import "BFConversation.h"

@implementation BFConversation

- (id)copyWithZone:(NSZone *)zone
{
    BFConversation *conv = [[[self class] allocWithZone:zone]init];
    conv.conversation_id = self.conversation_id;
    conv.partner_id = self.partner_id;
    conv.unreadCount = self.unreadCount;
    conv.sendStatus = self.sendStatus;
    conv.content = self.content;
    conv.last_msg_seq = self.last_msg_seq;
    return conv;
}

@end
