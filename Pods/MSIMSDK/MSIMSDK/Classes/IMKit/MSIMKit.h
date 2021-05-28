//
//  MSIMKit.h
//  BlackFireIM
//
//  Created by benny wang on 2021/3/19.
//

#import <Foundation/Foundation.h>
#import "MSIMSDK.h"


NS_ASSUME_NONNULL_BEGIN

@interface MSIMKit : NSObject

/**
 *  共享实例
 *  TUIKit为单例
 */
+ (instancetype)sharedInstance;


- (void)initWithConfig:(IMSDKConfig *)config;


@end

NS_ASSUME_NONNULL_END
