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
#import "BFNavigationController.h"
#import "BFLoginController.h"
#import <MJRefresh.h>
#import <SVProgressHUD.h>

@interface BFConversationListController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) BFNaviBarIndicatorView *titleView;

@property(nonatomic,strong) UITableView *tableView;

@property(nonatomic,assign) NSInteger lastConvSign;//分页摘取会话列表游标

@property(nonatomic,strong) NSMutableArray<BFConversationCellData *> *dataList;

@end

@implementation BFConversationListController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupNavigation];
    [self setupViews];
    [self loadConversation];
    [self addNotifications];
}

- (void)addNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onNetworkChanged:) name:MSUIKitNotification_ConnListener object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(conversationSyncStart) name:MSUIKitNotification_ConversationSyncStart object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(conversationSyncFinish) name:MSUIKitNotification_ConversationSyncFinish object:nil];
    WS(weakSelf)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNewConvUpdate:) name:MSUIKitNotification_ConversationUpdate object:nil];
    [[NSNotificationCenter defaultCenter]addObserverForName:MSUIKitNotification_ProfileUpdate object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf profileUpdate:note];
    }];
    [[NSNotificationCenter defaultCenter]addObserverForName:MSUIKitNotification_ConversationDelete object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf onConversationDelete:note];
    }];
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
    WS(weakSelf)
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadConversation];
    }];
    self.tableView.mj_footer.hidden = YES;
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
    [self.tableView reloadData];
}

- (void)loadConversation
{
    WS(weakSelf)
    NSInteger start = [MSIMTools sharedInstance].adjustLocalTimeInterval;
    [[MSIMManager sharedInstance] getConversationList:self.lastConvSign succ:^(NSArray<MSIMConversation *> * _Nonnull convs, NSInteger nexSeq, BOOL isFinished) {
        weakSelf.lastConvSign = nexSeq;
        [weakSelf updateConversation: convs];
        if (isFinished) {
            [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
        }else {
            [weakSelf.tableView.mj_footer endRefreshing];
        }
        NSLog(@"加载会话列表耗时 = %f s",([MSIMTools sharedInstance].adjustLocalTimeInterval-start)/1000.0/1000.0);
        } fail:^(NSInteger code, NSString * _Nonnull desc) {
            [weakSelf.tableView.mj_footer endRefreshing];
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
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tableView.mj_footer.hidden = self.dataList.count <= 10;
        [self.tableView reloadData];
    });
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
        case IMNET_STATUS_RECONNFAILD:
            [_titleView stopAnimating];
            [_titleView setTitle:@"MESSAGE(重连失败)"];
        default:
            break;
    }
}

- (void)conversationSyncStart
{
    [self.titleView setTitle:@"拉取中..."];
}

- (void)conversationSyncFinish
{
    [self.titleView setTitle:@"MESSAGE"];
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
    [self updateTabbarUnreadCount];
}

- (void)onNewConvUpdate:(NSNotification *)note
{
    NSArray<MSIMConversation *> *list = note.object;
    [self updateConversation:list];
    [self updateTabbarUnreadCount];
}

- (void)updateTabbarUnreadCount
{
    NSInteger count = [[MSConversationProvider provider]allUnreadCount];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tabBarItem.badgeValue = count ? (count > 99 ? @"99+" : [NSString stringWithFormat:@"%zd",count]) : nil;
    });
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
        [[MSIMManager sharedInstance] deleteConversation:data.conv succ:^{
           
            [self removeConversation:data];
        } failed:^(NSInteger code, NSString * _Nonnull desc) {
            [SVProgressHUD showErrorWithStatus:desc];
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
