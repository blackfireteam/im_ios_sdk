//
//  BFConversationListController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/18.
//

#import "BFConversationListController.h"
#import "MSIMSDK.h"
#import "BFNaviBarIndicatorView.h"
#import "BFHeader.h"
#import "BFConversationListCell.h"
#import "NSBundle+BFKit.h"
#import "BFChatViewController.h"
#import "UIColor+BFDarkMode.h"
#import "MSIMHeader.h"
#import "UIImage+BFKit.h"
#import "AppDelegate.h"
#import "BFNavigationController.h"
#import "BFLoginController.h"

@interface BFConversationListController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) BFNaviBarIndicatorView *titleView;

@property(nonatomic,strong) UITableView *tableView;

@property(nonatomic,strong) NSMutableArray<BFConversationCellData *> *dataList;

@end

@implementation BFConversationListController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupNavigation];
    [self setupViews];
    [self loadConversation];
}

- (instancetype)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onNetworkChanged:) name:MSUIKitNotification_ConnListener object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onUserLogStatusChanged:) name:MSUIKitNotification_UserStatusListener object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onNewConvUpdate:) name:MSUIKitNotification_ConversationUpdate object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(profileUpdate:) name:MSUIKitNotification_ProfileUpdate object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onConversationDelete:) name:MSUIKitNotification_ConversationDelete object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupNavigation
{
    _titleView = [[BFNaviBarIndicatorView alloc]init];
    [_titleView setTitle:@"MESSAGE"];
    self.navigationItem.titleView = _titleView;
}

- (void)setupViews
{
    self.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = self.view.backgroundColor;
    [self.tableView registerClass:[BFConversationListCell class] forCellReuseIdentifier:@"TConversationCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 103;
    self.tableView.separatorColor = TCell_separatorColor;
    [self.view addSubview:self.tableView];
}

- (NSMutableArray<BFConversationCellData *> *)dataList
{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (void)profileUpdate:(NSNotification *)note
{
    MSProfileInfo *profile = note.object;
    for (BFConversationCellData *data in self.dataList) {
        if ([data.conv.partner_id isEqualToString: profile.user_id]) {
            [self.tableView reloadData];
        }
    }
}

- (void)loadConversation
{
    WS(weakSelf)
    [[MSIMManager sharedInstance] getConversationList:0 count:INT_MAX succ:^(NSArray<MSIMConversation *> * _Nonnull convs, NSInteger nexSeq, BOOL isFinished) {
        [weakSelf updateConversation: convs];
        } fail:^(NSInteger code, NSString * _Nonnull desc) {
            
    }];
}

- (void)updateConversation:(NSArray *)convList
{
    // 更新 UI 会话列表，如果 UI 会话列表有新增的会话，就替换，如果没有，就新增
    for (NSInteger i = 0; i < convList.count; i++) {
        MSIMConversation *conv = convList[i];
        BOOL isExist = NO;
        for (NSInteger j = 0; j < self.dataList.count; j++) {
            MSIMConversation *localConv = self.dataList[j].conv;
            if ([localConv.conversation_id isEqualToString:conv.conversation_id]) {
                self.dataList[j].conv = conv;
                isExist = YES;
                break;
            }
        }
        if (!isExist) {
            BFConversationCellData *data = [[BFConversationCellData alloc]init];
            data.conv = conv;
            [self.dataList addObject:data];
        }
    }
    // UI 会话列表根据 lastMessage 时间戳重新排序
    [self sortDataList:self.dataList];
    [self.tableView reloadData];
}

- (void)sortDataList:(NSMutableArray<BFConversationCellData *> *)dataList
{
    // 按时间排序，最近会话在上
    [dataList sortUsingComparator:^NSComparisonResult(BFConversationCellData *obj1, BFConversationCellData *obj2) {
        return [obj2.time compare:obj1.time];
    }];
}

- (void)onNetworkChanged:(NSNotification *)notification
{
    BFIMNetStatus status = [notification.object intValue];
    switch (status) {
        case IMNET_STATUS_SUCC:
            [_titleView stopAnimating];
            [_titleView setTitle:@"MESSAGE"];
            break;
        case IMNET_STATUS_CONNECTING:
            [_titleView startAnimating];
            [_titleView setTitle:@"连接中..."];
            break;
        case IMNET_STATUS_DISCONNECT:
            [_titleView stopAnimating];
            [_titleView setTitle:@"MESSAGE(无网络)"];
            break;
        case IMNET_STATUS_CONNFAILED:
            [_titleView stopAnimating];
            [_titleView setTitle:@"MESSAGE(未连接)"];
            break;
        default:
            break;
    }
}

- (void)onUserLogStatusChanged:(NSNotification *)notification
{
    BFIMUserStatus status = [notification.object intValue];
    switch (status) {
        case IMUSER_STATUS_FORCEOFFLINE://用户被强制下线
        {
            WS(weakSelf)
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:@"您的帐号已经在其它的设备上登录" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf logout];
            }];
            [alert addAction:action1];
            [self presentViewController:alert animated:YES completion:nil];
        }
            break;
        case IMUSER_STATUS_SIGEXPIRED:
        {
            WS(weakSelf)
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:@"您的登录授权已过期，请重新登录" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf logout];
            }];
            [alert addAction:action1];
            [self presentViewController:alert animated:YES completion:nil];
        }
            break;
        case IMUSER_STATUS_RECONNFAILD://用户重连失败
        default:
            break;
    }
}

- (void)onConversationDelete:(NSNotification *)note
{
    NSString *partner_id = note.object;
    for (NSInteger i = 0; i < self.dataList.count; i++) {
        BFConversationCellData *data = self.dataList[i];
        if ([data.conv.partner_id isEqualToString:partner_id]) {
            [self removeConversation:data];
            break;
        }
    }
}

- (void)removeConversation:(BFConversationCellData *)data
{
    [self.tableView beginUpdates];
    NSInteger index = [self.dataList indexOfObject:data];
    [self.dataList removeObject:data];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (void)logout
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.window.rootViewController = [[BFNavigationController alloc]initWithRootViewController:[BFLoginController new]];
}

- (void)onNewConvUpdate:(NSNotification *)note
{
    NSArray<MSIMConversation *> *list = note.object;
    [self updateConversation:list];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TUILocalizableString(Delete);
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        BFConversationCellData *data = self.dataList[indexPath.row];
        [self removeConversation:data];
        [[MSIMManager sharedInstance] deleteConversation:data.conv succ:^{
            
        } failed:^(NSInteger code, NSString * _Nonnull desc) {
            
        }];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BFConversationListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TConversationCell" forIndexPath:indexPath];
    BFConversationCellData *data = self.dataList[indexPath.row];
    [cell configWithData:data];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BFChatViewController *vc = [[BFChatViewController alloc]init];
    BFConversationCellData *data = self.dataList[indexPath.row];
    vc.partner_id = data.conv.partner_id;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
           [cell setSeparatorInset:UIEdgeInsetsMake(0, 75, 0, 0)];
        if (indexPath.row == (self.dataList.count - 1)) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
    }

    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }

    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

@end
