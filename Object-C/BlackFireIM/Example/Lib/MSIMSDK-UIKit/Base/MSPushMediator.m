//
//  MSPushMediator.m
//  BlackFireIM
//
//  Created by benny wang on 2021/6/23.
//

#import "MSPushMediator.h"
#import <UserNotifications/UserNotifications.h>
#import <MSIMSDK/MSIMSDK.h>
#import "MSIMSDK-UIKit.h"
#import <PushKit/PushKit.h>
#import <CallKit/CallKit.h>
#import "MSVoipCenter.h"


@interface MSPushMediator()<UNUserNotificationCenterDelegate,PKPushRegistryDelegate,CXProviderDelegate>

@property(nonatomic,strong) PKPushRegistry *voipRegistry;

@property(nonatomic,strong) CXProvider *voipProvider;

@end
@implementation MSPushMediator

static MSPushMediator *_manager;
+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _manager = [[MSPushMediator alloc]init];
    });
    return _manager;
}

- (void)applicationDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions imConfig: (IMSDKConfig *)config
{
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {

        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            }else {
                MSLog(@"用户没有开通通知权限!");
                NSString *voipToken = [[NSUserDefaults standardUserDefaults]stringForKey:kVoipTokenKey];
                [[MSIMManager sharedInstance]refreshPushToken:nil voipToken:voipToken];
            }
        });
    }];
    ///用户手动去设置界面更改了推送权限
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {

        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL granted = (settings.authorizationStatus == UNAuthorizationStatusAuthorized);
            if (granted) {
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            }else {
                MSLog(@"用户没有开通通知权限!");
                NSString *voipToken = [[NSUserDefaults standardUserDefaults]stringForKey:kVoipTokenKey];
                [[MSIMManager sharedInstance]refreshPushToken:nil voipToken:voipToken];
            }
        });
    }];
    NSDictionary *userInfo = [launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if(userInfo){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(didReceiveNotificationResponse:)]) {
                [self.delegate didReceiveNotificationResponse:userInfo];
            }
        });
    }
    if (config.voipEnable) {
        [self registerForVoIPPushes];
    }
}

- (void)registerForVoIPPushes
{
   self.voipRegistry = [[PKPushRegistry alloc] initWithQueue:dispatch_get_main_queue()];
   self.voipRegistry.delegate = self;
   self.voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
    
    CXProviderConfiguration *config = [[CXProviderConfiguration alloc]initWithLocalizedName:@"voipCall"];
    config.maximumCallsPerCallGroup = 1;
    config.supportsVideo = YES;
    self.voipProvider = [[CXProvider alloc]initWithConfiguration:config];
    [self.voipProvider setDelegate:self queue:dispatch_get_main_queue()];
}


#pragma mark - UNUserNotificationCenterDelegate
///** 请求APNs建立连接并获得deviceToken*/
- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    if (![deviceToken isKindOfClass:[NSData class]]) return;
    NSMutableString *deviceTokenString = [NSMutableString string];
    const char *bytes = deviceToken.bytes;
    NSInteger count = deviceToken.length;
    for (int i = 0; i < count; i++) {
        [deviceTokenString appendFormat:@"%02x", bytes[i]&0x000000FF];
    }
    MSLog(@"APNS TOKEN:%@",deviceTokenString);
    
    [[NSUserDefaults standardUserDefaults]setObject:deviceTokenString forKey:kApnsTokenKey];
    NSString *voipToken = [[NSUserDefaults standardUserDefaults] stringForKey:kVoipTokenKey];
    [[MSIMManager sharedInstance] refreshPushToken:deviceTokenString voipToken:voipToken];
}

///获取device-token失败
- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:kApnsTokenKey];
    NSString *voipToken = [[NSUserDefaults standardUserDefaults] stringForKey:kVoipTokenKey];
    [[MSIMManager sharedInstance] refreshPushToken:nil voipToken:voipToken];
  MSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

///App在前台运行时收到推送消息的回调
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    completionHandler(UNNotificationPresentationOptionAlert);
}

///用户点击推送消息的回调
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler
{
    UNNotification *noti = ((UNNotificationResponse *)response).notification;
    NSDictionary *userInfo = noti.request.content.userInfo;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(didReceiveNotificationResponse:)]) {
            [self.delegate didReceiveNotificationResponse:userInfo];
        }
    });
    completionHandler();
}

#pragma mark - PKPushRegistryDelegate

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)pushCredentials forType:(PKPushType)type
{
    NSData *voipData = pushCredentials.token;
    if (![voipData isKindOfClass:[NSData class]]) return;
    NSMutableString *voipTokenString = [NSMutableString string];
    const char *bytes = voipData.bytes;
    NSInteger count = voipData.length;
    for (int i = 0; i < count; i++) {
        [voipTokenString appendFormat:@"%02x", bytes[i]&0x000000FF];
    }
    MSLog(@"VOIP TOKEN: %@",voipTokenString);
    [[NSUserDefaults standardUserDefaults]setObject:voipTokenString forKey:kVoipTokenKey];
    NSString *apnsToken = [[NSUserDefaults standardUserDefaults] stringForKey:kApnsTokenKey];
    [[MSIMManager sharedInstance] refreshPushToken:apnsToken voipToken:voipTokenString];
}

- (void)pushRegistry:(PKPushRegistry *)registry didInvalidatePushTokenForType:(PKPushType)type
{
    MSLog(@"获取VOIP TOKEN 失败: %@",type);
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kVoipTokenKey];
    NSString *apnsToken = [[NSUserDefaults standardUserDefaults] stringForKey:kApnsTokenKey];
    [[MSIMManager sharedInstance] refreshPushToken:apnsToken voipToken:nil];
}

//{
//"aps": {
//    "alert" : {
//        "title": "this is a push title",
//        "body": "this is a push body"
//    }
//    "mutable-content" : 1
//},
//"msim": {
//     "from": 123,
//     "to": 456,
//     "mtype": 0, //消息type
//     "body": "custom push data" //如果是自定义消息 则有这个值为body中的内容
//},
//}
- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type withCompletionHandler:(void (^)(void))completion
{
    NSDictionary *apsDic = payload.dictionaryPayload[@"aps"];
    NSDictionary *alertDic = apsDic[@"alert"];
    NSString *title = alertDic[@"title"];
    NSDictionary *msimDic = payload.dictionaryPayload[@"msim"];
    NSString *fromUid = [NSString stringWithFormat:@"%@",msimDic[@"from"]];
    NSString *bodyJson = msimDic[@"body"];
    NSDictionary *bodyDic = [bodyJson el_convertToDictionary];
    MSIMCustomSubType subType = [bodyDic[@"type"] integerValue];
    CallAction action = [bodyDic[@"event"] integerValue];
    NSString *room_id = bodyDic[@"room_id"];
    
    if (subType == MSIMCustomSubTypeVoiceCall || subType == MSIMCustomSubTypeVideoCall) {
        if (action == CallAction_Call) {
            MSCallType callType = (subType == MSIMCustomSubTypeVoiceCall ? MSCallType_Voice : MSCallType_Video);
            NSString *uuid = [[MSVoipCenter shareInstance]createUUIDWithRoomID:room_id fromUid:fromUid subType:callType];
            
            CXCallUpdate *update = [[CXCallUpdate alloc]init];
            update.localizedCallerName = title;
            update.supportsGrouping = NO;
            update.supportsDTMF = NO;
            update.supportsHolding = NO;
            update.hasVideo = (callType == MSCallType_Video);
            CXHandle *handle = [[CXHandle alloc]initWithType:CXHandleTypePhoneNumber value:room_id];
            update.remoteHandle = handle;
        
            [self.voipProvider reportNewIncomingCallWithUUID:[[NSUUID alloc]initWithUUIDString:uuid] update:update completion:^(NSError * _Nullable error) {
                if (error != nil) {
                    MSLog(@"error: %@",error);
                }
            }];
        }else if (action == CallAction_Cancel) {
            [[MSVoipCenter shareInstance]cancelBtnDidClick:(subType == MSIMCustomSubTypeVoiceCall ? MSCallType_Voice : MSCallType_Video) room_id:room_id];
        }
    }
}

#pragma mark - CXProviderDelegate

- (void)providerDidReset:(CXProvider *)provider
{
    
}


/// Called when the provider has been fully created and is ready to send actions and receive updates
- (void)providerDidBegin:(CXProvider *)provider
{
    
}

/// Called whenever a new transaction should be executed. Return whether or not the transaction was handled:
///
/// - NO: the transaction was not handled indicating that the perform*CallAction methods should be called sequentially for each action in the transaction
/// - YES: the transaction was handled and the perform*CallAction methods should not be called sequentially
///
/// If the method is not implemented, NO is assumed.
//- (BOOL)provider:(CXProvider *)provider executeTransaction:(CXTransaction *)transaction
//{
//    return YES;
//}

// If provider:executeTransaction:error: returned NO, each perform*CallAction method is called sequentially for each action in the transaction
- (void)provider:(CXProvider *)provider performStartCallAction:(CXStartCallAction *)action
{
}

- (void)provider:(CXProvider *)provider performAnswerCallAction:(CXAnswerCallAction *)action
{
    if (action.callUUID.UUIDString.length > 0) {
        [[MSVoipCenter shareInstance] startCallWithUuid:action.callUUID.UUIDString];
        [action fulfill];
    }else {
        [action fail];
    }
}

- (void)provider:(CXProvider *)provider performEndCallAction:(CXEndCallAction *)action
{
    if (action.callUUID.UUIDString.length > 0) {
        [[MSVoipCenter shareInstance] endCallWithUuid:action.callUUID.UUIDString];
        [action fulfill];
    }else {
        [action fail];
    }
}

- (void)provider:(CXProvider *)provider performSetHeldCallAction:(CXSetHeldCallAction *)action
{
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performSetMutedCallAction:(CXSetMutedCallAction *)action
{
    if (action.callUUID.UUIDString.length > 0) {
        [[MSVoipCenter shareInstance] muteCall:action.muted];
        [action fulfill];
    }else {
        [action fail];
    }
}

- (void)provider:(CXProvider *)provider performSetGroupCallAction:(CXSetGroupCallAction *)action
{
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performPlayDTMFCallAction:(CXPlayDTMFCallAction *)action
{
    [action fulfill];
}

/// Called when an action was not performed in time and has been inherently failed. Depending on the action, this timeout may also force the call to end. An action that has already timed out should not be fulfilled or failed by the provider delegate
- (void)provider:(CXProvider *)provider timedOutPerformingAction:(CXAction *)action
{
    [action fail];
}

/// Called when the provider's audio session activation state changes.
- (void)provider:(CXProvider *)provider didActivateAudioSession:(AVAudioSession *)audioSession
{
    
}

- (void)provider:(CXProvider *)provider didDeactivateAudioSession:(AVAudioSession *)audioSession
{
    
}

@end
