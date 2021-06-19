//
//  AppDelegate.m
//  BlackFireIM
//
//  Created by benny wang on 2021/2/25.
//

#import "AppDelegate.h"
#import "BFTabBarController.h"
#import "BFLoginController.h"
#import "BFNavigationController.h"
#import "MSIMKit.h"
#import "MSIMSDK-UIKit.h"
#import "BFUploadManager.h"
#import <QCloudCOSXML/QCloudCOSXMLTransfer.h>
#import <Bugly/Bugly.h>
#import <UserNotifications/UserNotifications.h>


@interface AppDelegate ()<QCloudSignatureProvider,UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    IMSDKConfig *imConfig = [IMSDKConfig defaultConfig];
    imConfig.uploadMediator = [BFUploadManager sharedInstance];
    [[MSIMKit sharedInstance] initWithConfig:imConfig];
    
    if ([MSIMTools sharedInstance].user_sign) {
        self.window.rootViewController = [[BFTabBarController alloc] init];
    }else {
        self.window.rootViewController = [[BFNavigationController alloc]initWithRootViewController:[BFLoginController new]];
    }
    
    //配置cos
    QCloudServiceConfiguration* configuration = [QCloudServiceConfiguration new];
    QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];
    endpoint.regionName = @"ap-chengdu";
    endpoint.useHTTPS = true;
    configuration.endpoint = endpoint;
    configuration.signatureProvider = self;
    [QCloudCOSXMLService registerDefaultCOSXMLWithConfiguration:configuration];
      [QCloudCOSTransferMangerService registerDefaultCOSTransferMangerWithConfiguration:
          configuration];
    
    BuglyConfig *config = [[BuglyConfig alloc]init];
    [Bugly startWithAppId:@"f8db8c69b8" config:config];
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {

        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            }else {
                MSLog(@"用户没有开通通知权限!");
            }
        });
    }];
    
    NSDictionary *remoteNotification = [launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if(remoteNotification){
        MSLog(@"【点击推送起动的app】,params: %@",remoteNotification);
    }
    return YES;
}

- (void) signatureWithFields:(QCloudSignatureFields*)fileds
                   request:(QCloudBizHTTPRequest*)request
                urlRequest:(NSMutableURLRequest*)urlRequst
                 compelete:(QCloudHTTPAuthentationContinueBlock)continueBlock
{

      QCloudCredential* credential = [QCloudCredential new];
      credential.secretID = @"AKIDiARZwekKIK7f18alpjsqdOzmQAplexA5"; // 永久密钥 SecretId
      credential.secretKey = @"f7MLJ3YnoX2KLKBmBeAVeWNVLaYEmGYa"; // 永久密钥 SecretKey
       // 使用永久密钥计算签名
      QCloudAuthentationV5Creator* creator = [[QCloudAuthentationV5Creator alloc]
          initWithCredential:credential];
      QCloudSignature* signature = [creator signatureForData:urlRequst];
      continueBlock(signature, nil);
}


///** 请求APNs建立连接并获得deviceToken*/
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    if (![deviceToken isKindOfClass:[NSData class]]) return;
    NSMutableString *deviceTokenString = [NSMutableString string];
    const char *bytes = deviceToken.bytes;
    NSInteger count = deviceToken.length;
    for (int i = 0; i < count; i++) {
        [deviceTokenString appendFormat:@"%02x", bytes[i]&0x000000FF];
    }
    MSLog(@"注册APNS成功%@",deviceTokenString);
    //redo
    // 将devicetoken上传到服务器
}

///获取device-token失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
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
    MSLog(@"【用户点击推送】，params： %@",userInfo);
    completionHandler();
}


@end
