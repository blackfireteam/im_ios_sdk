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
#import "BFUploadManager.h"
#import <QCloudCOSXML/QCloudCOSXMLTransfer.h>
#import <Bugly/Bugly.h>

@interface AppDelegate ()<QCloudSignatureProvider>

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

@end
