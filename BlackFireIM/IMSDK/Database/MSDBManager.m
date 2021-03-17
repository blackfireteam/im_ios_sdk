//
//  MSDBManager.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/2.
//

#import "MSDBManager.h"
#import <FMDB.h>
#import "MSIMTools.h"
#import "NSFileManager+filePath.h"

@interface MSDBManager()


@end
@implementation MSDBManager

static MSDBManager *manager;
+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[MSDBManager alloc]init];
    });
    return manager;
}

- (FMDatabaseQueue *)messageQueue
{
    if(!_messageQueue) {
        if([MSIMTools sharedInstance].user_id) {
            NSString *messageQueuePath = [NSFileManager pathDBMessage];
            _messageQueue = [FMDatabaseQueue databaseQueueWithPath:messageQueuePath];
        }
    }
    return _messageQueue;
}

- (FMDatabaseQueue *)commonQueue
{
    if(!_commonQueue) {
        if([MSIMTools sharedInstance].user_id) {
            NSString *commonQueuePath = [NSFileManager pathDBCommon];
            _commonQueue = [FMDatabaseQueue databaseQueueWithPath:commonQueuePath];
        }
    }
    return _commonQueue;
}

- (void)accountChanged
{
    [_messageQueue close];
    _messageQueue = nil;
}

@end
