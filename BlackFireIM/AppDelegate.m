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
#import "MSUploadManager.h"
#import <QCloudCOSXML/QCloudCOSXMLTransfer.h>
#import <Bugly/Bugly.h>
#import "MSPushMediator.h"


@interface AppDelegate ()<QCloudSignatureProvider,MSPushMediatorDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    IMSDKConfig *imConfig = [IMSDKConfig defaultConfig];
    imConfig.uploadMediator = [MSUploadManager sharedInstance];
    imConfig.logEnable = YES;
    [[MSIMKit sharedInstance] initWithConfig:imConfig];
    
    if ([MSIMTools sharedInstance].user_id) {
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
    [QCloudCOSTransferMangerService registerDefaultCOSTransferMangerWithConfiguration:configuration];
    
    BuglyConfig *config = [[BuglyConfig alloc]init];
    [Bugly startWithAppId:@"f8db8c69b8" config:config];
    
    [[MSPushMediator sharedInstance] applicationDidFinishLaunchingWithOptions:launchOptions];
    [MSPushMediator sharedInstance].delegate = self;
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
    [[MSPushMediator sharedInstance] didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

///获取device-token失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [[MSPushMediator sharedInstance] didFailToRegisterForRemoteNotificationsWithError:error];
}

#pragma mark-- MSPushMediatorDelegate<NSObject>

/** 点击推送消息进入的app,可以做些跳转操作*/
- (void)didReceiveNotificationResponse:(NSDictionary *)userInfo
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (userInfo[@"im"]) {
            if ([MSIMTools sharedInstance].user_id) {
                BFTabBarController *tabBar = (BFTabBarController *)self.window.rootViewController;
                tabBar.selectedIndex = 2;
            }
        }
    });
}

@end
