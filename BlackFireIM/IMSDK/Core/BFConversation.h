//
//  BFConversation.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/3.
//

#import <Foundation/Foundation.h>
#import "BFIMConst.h"


NS_ASSUME_NONNULL_BEGIN

@interface BFConversation : NSObject<NSCopying>

///会话id
@property(nonatomic,assign) NSInteger conversation_id;

///会话的对象uid
@property(nonatomic,assign) NSInteger partner_id;

///未读数
@property(nonatomic,assign) NSInteger unreadCount;

///最后一条聊天时间戳
@property(nonatomic,assign) NSInteger last_msg_seq;

///消息发送状态
@property(nonatomic,assign) BFIMMessageStatus sendStatus;

///显示的最后一条消息
@property(nonatomic,copy) NSString *content;

@end

NS_ASSUME_NONNULL_END
