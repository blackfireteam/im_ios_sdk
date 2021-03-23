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
    UIButton *moreButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [moreButton setImage:[UIImage imageNamed:TUIKitResource(@"more")] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(rightBarButtonClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    self.navigationItem.rightBarButtonItem = moreItem;
}

- (void)rightBarButtonClick
{
    BFChatViewController *vc = [[BFChatViewController alloc]init];
    vc.partner_id = @"1";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupNavigation
{
    _titleView = [[BFNaviBarIndicatorView alloc]init];
    [_titleView setTitle:@"MS·IM"];
    self.navigationItem.titleView = _titleView;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onNetworkChanged:) name:MSUIKitNotification_ConnListener object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onNewConvUpdate:) name:MSUIKitNotification_ConversationUpdate object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onConvUnreadUpdate:) name:MSUIKitNotification_ConversationUnreadCount object:nil];
}

- (void)setupViews
{
    self.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 8, 0);
    [self.tableView registerClass:[BFConversationListCell class] forCellReuseIdentifier:@"TConversationCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (NSMutableArray<BFConversationCellData *> *)dataList
{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
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
        for (NSInteger j = 0; i < self.dataList.count; j++) {
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

- (void)removeData:(BFConversationCellData *)data
{
    [self.dataList removeObject:data];
    [[MSIMManager sharedInstance] deleteConversation:data.conv succ:^{
        
    } failed:^(NSInteger code, NSString * _Nonnull desc) {
        
    }];
}

- (void)onNetworkChanged:(NSNotification *)notification
{
    BFIMNetStatus status = [notification.object intValue];
    switch (status) {
        case IMNET_STATUS_SUCC:
            [_titleView setTitle:@"MS·IM"];
            [_titleView stopAnimating];
            break;
        case IMNET_STATUS_CONNECTING:
            [_titleView setTitle:@"连接中..."];
            [_titleView startAnimating];
            break;
        case IMNET_STATUS_DISCONNECT:
            [_titleView setTitle:@"MS·IM(未连接)"];
            [_titleView stopAnimating];
            break;
        case IMNET_STATUS_CONNFAILED:
            [_titleView setTitle:@"MS·IM(未连接)"];
            [_titleView stopAnimating];
            break;
        default:
            break;
    }
}

- (void)onNewConvUpdate:(NSNotification *)note
{
    NSArray<MSIMConversation *> *list = note.object;
    [self updateConversation:list];
}

- (void)onConvUnreadUpdate:(NSNotification *)note
{
    NSDictionary *dic = note.object;
    NSString *conv_id = dic[@"conv_id"];
    NSInteger count = [dic[@"count"] integerValue];
    for (BFConversationCellData *data in self.dataList) {
        if ([data.conv.conversation_id isEqualToString:conv_id]) {
            data.conv.unread_count = count;
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
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
    return [NSBundle bf_localizedStringForKey:@"Delete"];
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];
        BFConversationCellData *convData = self.dataList[indexPath.row];
        [self removeData:convData];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
        [tableView endUpdates];
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
