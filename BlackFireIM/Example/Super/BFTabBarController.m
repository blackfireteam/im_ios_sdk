//
//  BFTabBarController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/17.
//

#import "BFTabBarController.h"
#import "BFConversationListController.h"
#import "BFDiscoveryController.h"
#import "BFProfileViewController.h"
#import "BFNavigationController.h"

@interface BFTabBarController ()

@end

@implementation BFTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITabBarItem *item = [UITabBarItem appearance];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor grayColor],NSFontAttributeName: [UIFont systemFontOfSize:12]} forState:UIControlStateNormal];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor],NSFontAttributeName: [UIFont systemFontOfSize:12]} forState:UIControlStateSelected];
    
    BFConversationListController *convVC = [[BFConversationListController alloc]init];
    convVC.tabBarItem.title = @"消息";
    convVC.tabBarItem.image = [[UIImage imageNamed:@"session_normal"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    convVC.tabBarItem.selectedImage = [[UIImage imageNamed:@"session_selected"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    BFNavigationController *convNav = [[BFNavigationController alloc]initWithRootViewController:convVC];
    [self addChildViewController:convNav];
    
    BFDiscoveryController *tactVC = [[BFDiscoveryController alloc]init];
    tactVC.tabBarItem.title = @"联系人";
    tactVC.tabBarItem.image = [[UIImage imageNamed:@"contact_normal"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tactVC.tabBarItem.selectedImage = [[UIImage imageNamed:@"contact_selected"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    BFNavigationController *tactNav = [[BFNavigationController alloc]initWithRootViewController:tactVC];
    [self addChildViewController:tactNav];
    
    BFProfileViewController *profileVC = [[BFProfileViewController alloc]init];
    profileVC.tabBarItem.title = @"我的";
    profileVC.tabBarItem.image = [[UIImage imageNamed:@"myself_normal"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    profileVC.tabBarItem.selectedImage = [[UIImage imageNamed:@"myself_selected"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    BFNavigationController *profileNav = [[BFNavigationController alloc]initWithRootViewController:profileVC];
    [self addChildViewController:profileNav];
}



@end
