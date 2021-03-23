//
//  MSIMTools.h
//  BlackFireIM
//
//  Created by benny wang on 2021/2/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MSIMTools : NSObject

+ (MSIMTools *)sharedInstance;

@property(nonatomic,copy) NSString *user_id;

@property(nonatomic,assign,readonly) NSInteger currentLocalTimeInterval;

@property(nonatomic,assign,readonly) NSInteger adjustLocalTimeInterval;

- (void)updateServerTime:(NSInteger)s_time;

@end

NS_ASSUME_NONNULL_END
