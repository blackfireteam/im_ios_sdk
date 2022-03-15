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
#import "MSCallViewController.h"

@interface MSVoipCenter()

@property(nonatomic,strong) NSMutableDictionary *uuids;

@property(nonatomic,strong) CXCallController *callVC;

/// 记录正在通话的calling
@property(nonatomic,copy) NSString *currentCalling;

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
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(recieveNeedToDismissVoipView:) name:@"kRecieveNeedToDismissVoipView" object:nil];
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

- (NSString *)roomIDWithUUID:(NSString *)uuid
{
    NSDictionary *dic = self.uuids[uuid];
    return dic[@"room_id"];
}

- (void)acceptCallWithUuid:(NSString *)uuid
{
    if (uuid.length == 0) return;
    NSDictionary *dic = self.uuids[uuid];
    if (dic == nil) return;
    MSCallType type = [dic[@"call_type"]integerValue];
    NSString *room_id = dic[@"room_id"];
    self.currentCalling = uuid;
    [[MSCallManager shareInstance] recieveCall:dic[@"from"] creator:dic[@"from"] callType:type action:CallAction_Call room_id:room_id];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[MSCallManager shareInstance]autoAcceptVoipCall:type room_id:room_id];
    });
}

- (void)endCallWithUuid:(NSString *)uuid
{
    if (uuid.length == 0) return;
    NSDictionary *dic = self.uuids[uuid];
    if (dic == nil) return;
    MSCallType type = [dic[@"call_type"]integerValue];
    NSString *room_id = dic[@"room_id"];
    if (self.currentCalling == nil) {
        [[MSCallManager shareInstance] sendMessageType:CallAction_Reject option:IMCUSTOM_SIGNAL room_id:room_id toReciever:dic[@"from"]];
    }else {
        [[MSCallManager shareInstance].callVC recieveVoipEnd:type room_id:room_id];
    }
    self.currentCalling = nil;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidEnterBackgroundNotification object:nil];
    });
}

- (void)muteCall:(BOOL)isMute uuid:(NSString *)uuid
{
    if (uuid.length == 0) return;
    NSDictionary *dic = self.uuids[uuid];
    if (dic == nil) return;
//    MSCallType type = [dic[@"call_type"]integerValue];
}

- (void)recieveNeedToDismissVoipView:(NSNotification *)note
{
    self.currentCalling = nil;
    for (NSString *uuid in self.uuids.allKeys) {
        [self.uuids removeObjectForKey:uuid];
        CXEndCallAction *action = [[CXEndCallAction alloc]initWithCallUUID:[[NSUUID alloc]initWithUUIDString:uuid]];
        CXTransaction *transaction = [[CXTransaction alloc]initWithAction:action];
        [self.callVC requestTransaction:transaction completion:^(NSError * _Nullable error) {
            MSLog(@"error: %@",error);
        }];
    }
}

- (void)didActivateAudioSession
{
    [[MSCallManager shareInstance].callVC didActivateAudioSession];
}

@end
