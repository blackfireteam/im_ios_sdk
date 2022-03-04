//
//  MSVoipCenter.m
//  BlackFireIM
//
//  Created by benny wang on 2022/3/2.
//

#import "MSVoipCenter.h"
#import <MSIMSDK/MSIMSDK.h>
#import "MSCallManager.h"
#import <CallKit/CallKit.h>

@interface MSVoipCenter()

@property(nonatomic,strong) NSMutableDictionary *uuids;

@property(nonatomic,strong) CXCallController *callVC;

@end
@implementation MSVoipCenter

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    static MSVoipCenter * g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[MSVoipCenter alloc] init];
    });
    return g_sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _uuids = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSString *)createUUIDWithRoomID:(NSString *)room_id fromUid:(NSString *)fromUid subType:(MSCallType)callType
{
    NSString *uuid = [NSUUID UUID].UUIDString;
    self.uuids[uuid] = @{@"room_id": room_id,@"from": fromUid,@"call_type": @(callType)};
    self.callVC = [[CXCallController alloc]initWithQueue:dispatch_get_main_queue()];
    return uuid;
}

- (void)startCallWithUuid:(NSString *)uuid
{
    if (uuid.length == 0) return;
    NSDictionary *dic = self.uuids[uuid];
    MSCallType type = [dic[@"call_type"]integerValue];
    [[MSCallManager shareInstance] recieveCall:dic[@"from"] creator:[MSCallManager getCreatorFrom:dic[@"room_id"]] callType:type action:CallAction_Call room_id:dic[@"room_id"]];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[MSCallManager shareInstance] acceptBtnDidClick: type];
    });
}

- (void)endCallWithUuid:(NSString *)uuid
{
    if (uuid.length == 0) return;
    NSDictionary *dic = self.uuids[uuid];
    MSCallType type = [dic[@"call_type"]integerValue];
    [[MSCallManager shareInstance] callToPartner:dic[@"from"] creator:[MSCallManager getCreatorFrom:dic[@"room_id"]] callType:type action:CallAction_Reject room_id:dic[@"room_id"]];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[MSCallManager shareInstance] rejectBtnDidClick: type];
    });
}

- (void)muteCall:(BOOL)isMute
{
    [[MSCallManager shareInstance]setMuTeCall:isMute];
}

- (void)acceptBtnDidClick:(MSCallType)type room_id:(NSString *)room_id
{

}


- (void)rejectBtnDidClick:(MSCallType)type room_id:(NSString *)room_id
{

}

- (void)hangupBtnDidClick:(MSCallType)type room_id:(NSString *)room_id
{
    NSUUID *UUID;
    for (NSString *uuid in self.uuids.allKeys) {
        NSDictionary *dic = self.uuids[uuid];
        if ([dic[@"room_id"] isEqualToString:room_id]) {
            UUID = [[NSUUID alloc]initWithUUIDString:uuid];
            break;
        }
    }
    if (UUID) {
        [self.uuids removeObjectForKey:UUID.UUIDString];
        CXEndCallAction *action = [[CXEndCallAction alloc]initWithCallUUID:UUID];
        CXTransaction *transaction = [[CXTransaction alloc]initWithAction:action];
        [self.callVC requestTransaction:transaction completion:^(NSError * _Nullable error) {
            MSLog(@"error: %@",error);
        }];
    }
}

- (void)cancelBtnDidClick:(MSCallType)type room_id:(NSString *)room_id
{
    NSUUID *UUID;
    for (NSString *uuid in self.uuids.allKeys) {
        NSDictionary *dic = self.uuids[uuid];
        if ([dic[@"room_id"] isEqualToString:room_id]) {
            UUID = [[NSUUID alloc]initWithUUIDString:uuid];
            break;
        }
    }
    if (UUID) {
        [self.uuids removeObjectForKey:UUID.UUIDString];
        CXEndCallAction *action = [[CXEndCallAction alloc]initWithCallUUID:UUID];
        CXTransaction *transaction = [[CXTransaction alloc]initWithAction:action];
        [self.callVC requestTransaction:transaction completion:^(NSError * _Nullable error) {
            MSLog(@"error: %@",error);
        }];
    }
}

@end
