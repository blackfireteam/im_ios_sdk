//
//  NSFileManager+filePath.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFileManager (filePath)

/**
 *  数据库 — 聊天
 */
+ (NSString *)pathDBMessage;

@end

NS_ASSUME_NONNULL_END
