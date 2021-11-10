//
//  BFChatRoomEditController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/11/7.
//

#import "BFChatRoomEditController.h"
#import "MSIMSDK-UIKit.h"
#import "BFChatRoomMemberListController.h"
#import "BFEditTodInfoController.h"


@interface BFChatRoomEditController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UITableView *myTableView;

@end

@implementation BFChatRoomEditController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Chat Room Setting";
    [self.view addSubview:self.myTableView];
    
    UIButton *quitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [quitBtn setTitle:@"退出群聊天" forState:UIControlStateNormal];
    [quitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    quitBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    quitBtn.backgroundColor = [UIColor redColor];
    quitBtn.frame = CGRectMake(0, 0, Screen_Width, 60);
    [quitBtn addTarget:self action:@selector(quitBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.myTableView.tableFooterView = quitBtn;
}

- (UITableView *)myTableView
{
    if (!_myTableView) {
        _myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height) style:UITableViewStylePlain];
        _myTableView.dataSource = self;
        _myTableView.delegate = self;
        _myTableView.rowHeight = 60;
        _myTableView.contentInset = UIEdgeInsetsMake(NavBar_Height + StatusBar_Height, 0, Bottom_SafeHeight, 0);
        _myTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        [_myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    }
    return _myTableView;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Member List";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%zd 人",self.roomInfo.onlineCount];
    }else if (indexPath.row == 1) {
        cell.textLabel.text = @"Chat room name";
        cell.detailTextLabel.text = self.roomInfo.room_name;
    }else if (indexPath.row == 2) {
        cell.textLabel.text = @"Tips of day";
    }else if (indexPath.row == 3) {
        cell.textLabel.text = self.roomInfo.is_mute ? @"Cancel Mute" : @"Mute";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        BFChatRoomMemberListController *vc = [[BFChatRoomMemberListController alloc]init];
        vc.roomInfo = self.roomInfo;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 1) {//修改聊天室名称
        [MSHelper showToastString:@"聊天室名称只支持后台修改"];
    }else if (indexPath.row == 2) {//修改公告
        if (self.roomInfo.action_tod == NO) {
            [MSHelper showToastString:@"只有管理员才能发布公告"];
            return;
        }
        BFEditTodInfoController *vc = [[BFEditTodInfoController alloc]init];
        vc.roomInfo = self.roomInfo;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 3) {
        
        [self editChatRoomMuteStatus];
        
    }
}

- (void)editChatRoomMuteStatus
{
    WS(weakSelf)
    [[MSIMManager sharedInstance] muteChatRoom:!self.roomInfo.is_mute toRoom_id:self.roomInfo.room_id duration:1 successed:^{
        
        [MSHelper showToastSucc:@"Success"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.myTableView reloadData];
        });
    } failed:^(NSInteger code, NSString *desc) {
        [MSHelper showToastFail:desc];
    }];
}

- (void)quitBtnClick
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
