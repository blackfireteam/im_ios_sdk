//
//  BFNavigationController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/18.
//

#import "BFNavigationController.h"
#import "UIColor+BFDarkMode.h"
#import "BFBaseViewController.h"

@interface BFNavigationController ()

@end

@implementation BFNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        self.navigationBar.standardAppearance = appearance;
        self.navigationBar.scrollEdgeAppearance = appearance;
    }
    self.navigationBar.tintColor = [UIColor d_colorWithColorLight:[UIColor darkTextColor] dark:[UIColor lightTextColor]];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}

@end
