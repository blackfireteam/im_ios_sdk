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
    
    NSArray *titles = @[@"user_66",@"user_67",@"uer_68",@"user_69"];
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
}

- (void)btnDidClick:(UIButton *)sender
{
    NSInteger index = sender.tag - 100;
    NSArray *tokens = @[@"tWvDfNV1at5expwjSrQ/6g==",@"+/HwKuJYYZynSc7mtC6p8w==",@"DT6F9XNqCh3DOJcHs+ps9g==",@"YNuic5tq3Ta49aVSkRVGmg=="];
    [[MSIMKit sharedInstance] login:tokens[index] succ:^{
        [self dismissViewControllerAnimated:YES completion:nil];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appDelegate.window.rootViewController = [[BFTabBarController alloc]init];
        
        } failed:^(NSInteger code, NSString * _Nonnull desc) {
            [SVProgressHUD showInfoWithStatus:desc];
    }];
}

@end
