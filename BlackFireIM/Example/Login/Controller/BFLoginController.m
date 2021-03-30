//
//  BFLoginController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/30.
//

#import "BFLoginController.h"
#import "UIColor+BFDarkMode.h"
#import "BFHeader.h"
#import "MSIMKit.h"
#import <SVProgressHUD.h>
#import "BFTabBarController.h"
#import "AppDelegate.h"


@interface BFLoginController ()

@end

@implementation BFLoginController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"登录";
    
    NSArray *titles = @[@"user_2",@"user_3",@"uer_5",@"user_23"];
    for (NSInteger i = 0; i < titles.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        btn.layer.borderColor = [UIColor grayColor].CGColor;
        btn.layer.borderWidth = 1;
        [btn addTarget:self action:@selector(btnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(Screen_Width*0.5-40, 150+(80+15)*i, 80, 50);
        btn.tag = 100 + i;
        [self.view addSubview:btn];
    }
    [[MSIMKit sharedInstance] initWithConfig:[IMSDKConfig defaultConfig]];
}

- (void)btnDidClick:(UIButton *)sender
{
    NSInteger index = sender.tag - 100;
    NSArray *tokens = @[@"jCTYRM47p2PrZljH2tT4rw==",@"89g3Is+0vDBz7grDz95N4A==",@"lxmxSxIG9jIJWyruS08tsg==",@"T3AmDPOTp7smtGUElDRw/A=="];
    [[MSIMKit sharedInstance] login:tokens[index] succ:^{
        [self dismissViewControllerAnimated:YES completion:nil];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appDelegate.window.rootViewController = [[BFTabBarController alloc]init];
        
        } failed:^(NSInteger code, NSString * _Nonnull desc) {
            [SVProgressHUD showInfoWithStatus:desc];
    }];
}

@end
