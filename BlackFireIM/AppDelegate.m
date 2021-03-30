//
//  AppDelegate.m
//  BlackFireIM
//
//  Created by benny wang on 2021/2/25.
//

#import "AppDelegate.h"
#import "BFTabBarController.h"
#import "MSIMKit.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    self.window.rootViewController = [[BFTabBarController alloc] init];
    
    [[MSIMKit sharedInstance] initWithConfig:[IMSDKConfig defaultConfig]];
    //uid = 23 T3AmDPOTp7smtGUElDRw/A==
    //uid = 5  lxmxSxIG9jIJWyruS08tsg==
    [[MSIMKit sharedInstance] login:@"T3AmDPOTp7smtGUElDRw/A==" succ:^{
            
        } failed:^(NSInteger code, NSString * _Nonnull desc) {
            
    }];
    return YES;
}



@end
