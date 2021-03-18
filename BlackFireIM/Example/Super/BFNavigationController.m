//
//  BFNavigationController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/18.
//

#import "BFNavigationController.h"

@interface BFNavigationController ()

@end

@implementation BFNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count != 0) {
        viewController.hidesBottomBarWhenPushed = YES;
        self.tabBarController.tabBar.hidden = YES;
    }
    [super pushViewController:viewController animated:animated];
}

@end
