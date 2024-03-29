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
#import <AVFoundation/AVFoundation.h>
#import <Intents/Intents.h>


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
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
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
    }else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kVoipTokenKey];
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
    config.iconTemplateImageData = UIImagePNGRepresentation([UIImage imageNamed:@"live_broadcast_camera_on"]);
    config.supportedHandleTypes = [[NSSet alloc]initWithObjects:[NSNumber numberWithInt:CXHandleTypeGeneric],[NSNumber numberWithInt:CXHandleTypePhoneNumber], nil];
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
    [self startBgTask];
    
    NSDictionary *apsDic = payload.dictionaryPayload[@"aps"];
    NSDictionary *alertDic = apsDic[@"alert"];
    NSString *title = alertDic[@"title"];
    NSDictionary *msimDic = payload.dictionaryPayload[@"msim"];
    NSString *fromUid = [NSString stringWithFormat:@"%@",msimDic[@"from"]];
//    NSString *toUid = [NSString stringWithFormat:@"%@",msimDic[@"to"]];
//    MSIMMessageType mType = [msimDic[@"mtype"]integerValue] - 8;
    NSString *bodyJson = msimDic[@"body"];
    NSDictionary *bodyDic = [bodyJson el_convertToDictionary];
    MSIMCustomSubType subType = [bodyDic[@"type"] integerValue];
    CallAction action = [bodyDic[@"event"] integerValue];
    NSString *room_id = bodyDic[@"room_id"];
    
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

    [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    if (action == CallAction_Call) {
        [self.voipProvider reportNewIncomingCallWithUUID:[[NSUUID alloc]initWithUUIDString:uuid] update:update completion:^(NSError * _Nullable error) {
            if (error != nil) {
                MSLog(@"error: %@",error);
            }
        }];
    }
    if (action == CallAction_Cancel || action == CallAction_End || action == CallAction_Timeout) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"kRecieveNeedToDismissVoipView" object:room_id];
    }
    if (completion) completion();
}

// 开启后台延时
- (void)startBgTask
{
    UIApplication *application = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask;
    bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:bgTask];
    }];
}


- (void)applicationContinueUserActivity:(NSUserActivity *)userActivity
{
    if ([MSIMTools sharedInstance].user_id == nil) return;
    if ([userActivity.interaction.intent isKindOfClass:[INStartAudioCallIntent class]]) {//语音通话
        INStartAudioCallIntent *audioIntent = (INStartAudioCallIntent *)userActivity.interaction.intent;
        NSString *room_id = audioIntent.contacts.firstObject.personHandle.value;
        NSString *partner_id = [MSCallManager getCreatorFrom:room_id];
        [[MSCallManager shareInstance] callToPartner:partner_id creator:[MSIMTools sharedInstance].user_id callType:MSCallType_Voice action:CallAction_Call room_id:nil];
        
    }else if ([userActivity.interaction.intent isKindOfClass:[INStartVideoCallIntent class]]) {//视频通话
        INStartVideoCallIntent *videoIntent = (INStartVideoCallIntent *)userActivity.interaction.intent;
        NSString *room_id = videoIntent.contacts.firstObject.personHandle.value;
        NSString *partner_id = [MSCallManager getCreatorFrom:room_id];
        [[MSCallManager shareInstance] callToPartner:partner_id creator:[MSIMTools sharedInstance].user_id callType:MSCallType_Video action:CallAction_Call room_id:nil];
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
        [[MSVoipCenter shareInstance] acceptCallWithUuid:action.callUUID.UUIDString];
    }
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performEndCallAction:(CXEndCallAction *)action
{
    if (action.callUUID.UUIDString.length > 0) {
        [[MSVoipCenter shareInstance] endCallWithUuid:action.callUUID.UUIDString];
    }
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performSetHeldCallAction:(CXSetHeldCallAction *)action
{
    [action fulfill];
}

- (void)provider:(CXProvider *)provider performSetMutedCallAction:(CXSetMutedCallAction *)action
{
    if (action.callUUID.UUIDString.length > 0) {
        [[MSVoipCenter shareInstance] muteCall:action.muted uuid: action.callUUID.UUIDString];
    }
    [action fulfill];
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
    MSLog(@"didActivateAudioSession");
    [[MSVoipCenter shareInstance]didActivateAudioSession];
}

- (void)provider:(CXProvider *)provider didDeactivateAudioSession:(AVAudioSession *)audioSession
{
    MSLog(@"didDeactivateAudioSession");
}

@end
