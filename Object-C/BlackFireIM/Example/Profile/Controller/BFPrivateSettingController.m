//
//  BFPrivateSettingController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/12/23.
//

#import "BFPrivateSettingController.h"
#import "MSIMSDK-UIKit.h"
#import "AppDelegate.h"
#import "BFTabBarController.h"
#import "BFLoginController.h"
#import "BFNavigationController.h"
#import <MSIMSDK/MSIMSDK.h>

@interface BFPrivateSettingController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UITableView *myTableView;

@end

@implementation BFPrivateSettingController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navView.navTitleL.text = @"隐私设置";
    [self.view addSubview:self.myTableView];
    [self setupFooter];
}

- (void)setupFooter
{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Screen_Height, 150)];
    UIButton *logoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoutBtn setTitle:@"注销账户" forState:UIControlStateNormal];
    [logoutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    logoutBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    logoutBtn.backgroundColor = [UIColor redColor];
    logoutBtn.layer.cornerRadius = 22.5;
    logoutBtn.layer.masksToBounds = YES;
    [logoutBtn addTarget:self action:@selector(snapBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
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
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
    cell.accessoryView = [[UISwitch alloc]init];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"隐身";
    }else if (indexPath.row == 1) {
        cell.textLabel.text = @"只接受异性喜欢";
    }else if (indexPath.row == 2) {
        cell.textLabel.text = @"未认证的用户可以给我发消息";
    }
    return cell;
}

- (void)snapBtnDidClick
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"注销帐户" message:@"确定要注销帐户吗？" preferredStyle:UIAlertControllerStyleAlert];
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
