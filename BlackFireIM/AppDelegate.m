//
//  AppDelegate.m
//  BlackFireIM
//
//  Created by benny wang on 2021/2/25.
//

#import "AppDelegate.h"
#import "BFTabBarController.h"
#import "BFLoginController.h"
#import "MSIMTools.h"
#import "BFNavigationController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    if ([MSIMTools sharedInstance].user_id) {
        self.window.rootViewController = [[BFTabBarController alloc] init];
    }else {
        self.window.rootViewController = [[BFNavigationController alloc]initWithRootViewController:[BFLoginController new]];
    }
    
    return YES;
}



@end
