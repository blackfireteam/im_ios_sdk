//
//  MSIMTools.m
//  BlackFireIM
//
//  Created by benny wang on 2021/2/26.
//

#import "MSIMTools.h"

@interface MSIMTools()

@property(nonatomic,assign) NSInteger diff;

@end
@implementation MSIMTools

static MSIMTools *_tools;
+ (MSIMTools *)sharedInstance
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _tools = [[MSIMTools alloc]init];
    });
    return _tools;
}

- (NSInteger)currentLocalTimeInterval
{
    NSTimeInterval stamp = [[NSDate date] timeIntervalSince1970];
    return stamp * 1000 * 1000;
}

- (NSInteger)adjustLocalTimeInterval
{
    NSTimeInterval stamp = self.currentLocalTimeInterval + self.diff;
    return stamp;
}



- (void)updateServerTime:(NSInteger)s_time
{
    self.diff = s_time - self.currentLocalTimeInterval;
}

@end
