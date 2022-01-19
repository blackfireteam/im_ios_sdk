//
//  BFSettingController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/12/23.
//

#import "BFSettingController.h"
#import "MSIMSDK-UIKit.h"
#import "AppDelegate.h"
#import "BFTabBarController.h"
#import "BFLoginController.h"
#import "BFNavigationController.h"
#import <MSIMSDK/MSIMSDK.h>
#import "BFPrivateSettingController.h"
#import "BFBlackListController.h"
#import "BFMessageSettingController.h"


@interface BFSettingController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UITableView *myTableView;

@end

@implementation BFSettingController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navView.navTitleL.text = @"设置";
    [self.view addSubview:self.myTableView];
    [self setupFooter];
}

- (void)setupFooter
{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Screen_Height, 150)];
    UIButton *logoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoutBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    [logoutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    logoutBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    logoutBtn.backgroundColor = [UIColor redColor];
    logoutBtn.layer.cornerRadius = 22.5;
    logoutBtn.layer.masksToBounds = YES;
    [logoutBtn addTarget:self action:@selector(logoutBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    logoutBtn.frame = CGRectMake(25, 60, Screen_Width - 50, 45);
    [footerView addSubview:logoutBtn];
    self.myTableView.tableFooterView = footerView;
}

- (UITableView *)myTableView
{
    if (!_myTableView) {
        _myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height) style:UITableViewStylePlain];
        _myTableView.dataSource = self;
        _myTableView.delegate = self;
        _myTableView.rowHeight = 55;
        _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _myTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _myTableView.backgroundColor = [UIColor d_colorWithColorLight:[UIColor whiteColor] dark:TPage_Color_Dark];
        _myTableView.contentInset = UIEdgeInsetsMake(StatusBar_Height + NavBar_Height, 0, Bottom_SafeHeight, 0);
        [_myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    }
    return _myTableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"隐私设置";
    }else if (indexPath.row == 1) {
        cell.textLabel.text = @"消息通知";
    }else if (indexPath.row == 2) {
        cell.textLabel.text = @"黑名单";
    }else if (indexPath.row == 3) {
        cell.textLabel.text = @"隐私政策";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        BFPrivateSettingController *vc = [[BFPrivateSettingController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 1) {
        BFMessageSettingController *vc = [[BFMessageSettingController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 2) {
        BFBlackListController *vc = [[BFBlackListController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)logoutBtnDidClick
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"退出登录" message:@"确定要退出吗？" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction: [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[MSIMManager sharedInstance]logout:^{
            
            } failed:^(NSInteger code, NSString * _Nonnull desc) {
        }];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appDelegate.window.rootViewController = [[BFNavigationController alloc]initWithRootViewController:[BFLoginController new]];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
