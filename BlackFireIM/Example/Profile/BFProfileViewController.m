//
//  BFProfileViewController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/18.
//

#import "BFProfileViewController.h"
#import "MSIMTools.h"
#import "BFHeader.h"
#import "MSIMManager.h"
#import <SVProgressHUD.h>
#import "AppDelegate.h"
#import "BFTabBarController.h"
#import "BFLoginController.h"
#import "BFNavigationController.h"

@interface BFProfileViewController ()

@end

@implementation BFProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = [NSString stringWithFormat:@"user_%@",[MSIMTools sharedInstance].user_id];
    
    UIButton *logoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoutBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    [logoutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    logoutBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    logoutBtn.backgroundColor = [UIColor blueColor];
    [logoutBtn addTarget:self action:@selector(logoutBtnClick) forControlEvents:UIControlEventTouchUpInside];
    logoutBtn.frame = CGRectMake(Screen_Width*0.5-50, Screen_Height-150, 100, 40);
    [self.view addSubview:logoutBtn];
}

- (void)logoutBtnClick
{
    [[MSIMManager sharedInstance]logout:^{
            
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appDelegate.window.rootViewController = [[BFNavigationController alloc]initWithRootViewController:[BFLoginController new]];
        
        } failed:^(NSInteger code, NSString * _Nonnull desc) {
            [SVProgressHUD showInfoWithStatus:desc];
    }];
}

@end
