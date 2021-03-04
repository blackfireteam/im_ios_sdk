//
//  BFDBMessageStore.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/2.
//
/**
 消息存储实行分库分表制，每一个对话单独存一张表，表名规则：个人对话表名：message_user_123 群对话表名：message_group_123
 */
#import <Foundation/Foundation.h>
#import "BFIMElem.h"


NS_ASSUME_NONNULL_BEGIN

@interface BFDBMessageStore : NSObject

///向数据库中添加一条记录
- (BOOL)addMessage:(BFIMElem *)elem;

@end

NS_ASSUME_NONNULL_END
