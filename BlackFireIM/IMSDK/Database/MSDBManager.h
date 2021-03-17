//
//  MSDBManager.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class FMDatabaseQueue;
@interface MSDBManager : NSObject

+ (instancetype)sharedInstance;

/**
 *  与IM相关的DB队列
 */
@property (nonatomic, strong) FMDatabaseQueue *messageQueue;

/**
 *  通用的DB队列
 */
@property (nonatomic, strong) FMDatabaseQueue *commonQueue;

/**
 针对用户切换帐号的情况
 */
- (void)accountChanged;

@end

NS_ASSUME_NONNULL_END
