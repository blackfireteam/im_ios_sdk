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
#import <MSIMSDK/MSIMSDK.h>
#import "MSIMSDK-UIKit.h"
#import <Bugly/Bugly.h>
#import "MSPushMediator.h"


@interface AppDelegate ()<MSPushMediatorDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    IMSDKConfig *imConfig = [IMSDKConfig defaultConfig];
    imConfig.logEnable = YES; // 打印日志
    imConfig.voipEnable = YES;
    imConfig.uploadMediator = [MSUploadManager sharedInstance];  // 附件上传插件，用户可以自定义
    [[MSIMKit sharedInstance] initWithConfig:imConfig];
    
    if ([MSIMTools sharedInstance].user_id) {
        self.window.rootViewController = [[BFTabBarController alloc] init];
    }else {
        self.window.rootViewController = [[BFNavigationController alloc]initWithRootViewController:[BFLoginController new]];
    }
    BuglyConfig *config = [[BuglyConfig alloc]init];
    [Bugly startWithAppId:@"f8db8c69b8" config:config];
    
    //推送相关配置
    [[MSPushMediator sharedInstance] applicationDidFinishLaunchingWithOptions:launchOptions imConfig: imConfig];
    [MSPushMediator sharedInstance].delegate = self;
    return YES;
}

///** 请求APNs建立连接并获得deviceToken*/
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[MSPushMediator sharedInstance] didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

///获取device-token失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [[MSPushMediator sharedInstance] didFailToRegisterForRemoteNotificationsWithError:error];
}

///当 payload 包含参数 content-available=1 时，该推送就是静默推送，静默推送不会显示任何推送消息，当 App 在后台挂起时，静默推送的回调方法会被执行，开发者有 30s 的时间内在该回调方法中处理一些业务逻辑，并在处理完成后调用 fetchCompletionHandler
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
  completionHandler(UIBackgroundFetchResultNewData);
}

#pragma mark-- MSPushMediatorDelegate<NSObject>

/** 点击推送消息进入的app,可以做些跳转操作*/
- (void)didReceiveNotificationResponse:(NSDictionary *)userInfo
{
    NSDictionary *data = userInfo[@"msim"];
    if (data == nil) return;
    if ([MSIMTools sharedInstance].user_id) {
        
        BFTabBarController *tabBar = (BFTabBarController *)self.window.rootViewController;
        tabBar.selectedIndex = 2;
    }
}

@end
