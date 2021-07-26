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


@interface MSPushMediator()<UNUserNotificationCenterDelegate>


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

- (void)applicationDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {

        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            }else {
                MSLog(@"用户没有开通通知权限!");
                [[MSIMManager sharedInstance]refreshPushDeviceToken:nil];
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
                [[MSIMManager sharedInstance]refreshPushDeviceToken:nil];
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
}

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
    MSLog(@"注册APNS成功%@",deviceTokenString);
    [[NSUserDefaults standardUserDefaults]setObject:deviceTokenString forKey:@"ms_device_token"];
    [[MSIMManager sharedInstance]refreshPushDeviceToken:deviceTokenString];
}

///获取device-token失败
- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
  MSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

///当 payload 包含参数 content-available=1 时，该推送就是静默推送，静默推送不会显示任何推送消息，当 App 在后台挂起时，静默推送的回调方法会被执行，开发者有 30s 的时间内在该回调方法中处理一些业务逻辑，并在处理完成后调用 fetchCompletionHandler
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
  completionHandler(UIBackgroundFetchResultNewData);
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

@end
