//
//  BFDBManager.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class FMDatabaseQueue;
@class FMResultSet;
@interface BFDBManager : NSObject

+ (instancetype)sharedInstance;

/**
 *  与IM相关的DB队列
 */
@property (nonatomic, strong) FMDatabaseQueue *messageQueue;

/**
 *  表创建
 */
- (BOOL)createTable:(NSString*)tableName withSQL:(NSString*)sqlString;

/**
*  判断表中是否存在该字段，如果不存在则添加.   字段类型： TXT
*/
- (BOOL)inertColumnInTable:(NSString *)tableName columnName:(NSString *)columnName;

/*
 *  执行带数组参数的sql语句 (增，删，改)
 */
- (BOOL)excuteSQL:(NSString*)sqlString withArrParameter:(NSArray*)arrParameter;

/*
 *  执行带字典参数的sql语句 (增，删，改)
 */
-(BOOL)excuteSQL:(NSString*)sqlString withDicParameter:(NSDictionary*)dicParameter;

/*
 *  执行格式化的sql语句 (增，删，改)
 */
- (BOOL)excuteSQL:(NSString *)sqlString,...;

/**
 *  执行查询指令
 */
- (void)excuteQuerySQL:(NSString*)sqlStr resultBlock:(void(^)(FMResultSet * rsSet))resultBlock;

/**
 针对用户切换帐号的情况
 */
- (void)accountChanged;

@end

NS_ASSUME_NONNULL_END
