//
//  BFMessageSettingController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/12/23.
//

#import "BFMessageSettingController.h"
#import "MSIMSDK-UIKit.h"


@interface BFMessageSettingController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UITableView *myTableView;

@end

@implementation BFMessageSettingController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navView.navTitleL.text = @"消息通知";
    [self.view addSubview:self.myTableView];
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.textColor = [UIColor d_colorWithColorLight:TText_Color dark:TText_Color_Dark];
    UISwitch *sw = [[UISwitch alloc]init];
    sw.on = YES;
    cell.accessoryView = sw;
    if (indexPath.row == 0) {
        cell.textLabel.text = @"互相喜欢";
    }else if (indexPath.row == 1) {
        cell.textLabel.text = @"聊天消息";
    }else if (indexPath.row == 2) {
        cell.textLabel.text = @"打招呼";
    }else if (indexPath.row == 3) {
        cell.textLabel.text = @"个性推荐";
    }
    return cell;
}

@end
