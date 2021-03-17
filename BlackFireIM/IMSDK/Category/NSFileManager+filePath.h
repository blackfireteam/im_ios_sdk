//
//  NSFileManager+filePath.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFileManager (filePath)

///聊天数据库
+ (NSString *)pathDBMessage;

///能用数据库
+ (NSString *)pathDBCommon;

@end

NS_ASSUME_NONNULL_END
