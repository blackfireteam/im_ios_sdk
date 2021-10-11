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
    [[UIPasteboard generalPasteboard]setString:deviceTokenString];
    [[NSUserDefaults standardUserDefaults]setObject:deviceTokenString forKey:@"ms_device_token"];
    [[MSIMManager sharedInstance]refreshPushDeviceToken:deviceTokenString];
}

///获取device-token失败
- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
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

@end
