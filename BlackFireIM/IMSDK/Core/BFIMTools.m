//
//  BFIMTools.m
//  BlackFireIM
//
//  Created by benny wang on 2021/2/26.
//

#import "BFIMTools.h"

@interface BFIMTools()

@property(nonatomic,assign) NSInteger diff;

@end
@implementation BFIMTools

static BFIMTools *_tools;
+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _tools = [[BFIMTools alloc]init];
    });
    return _tools;
}

- (NSInteger)currentLocalTimeInterval
{
    NSInteger stamp = [[NSDate date] timeIntervalSince1970];
    return stamp * 10000;
}

- (NSInteger)adjustLocalTimeInterval
{
    NSInteger stamp = self.currentLocalTimeInterval + self.diff;
    return stamp;
}



- (void)updateServerTime:(NSInteger)s_time
{
    self.diff = s_time - self.currentLocalTimeInterval;
}

@end
