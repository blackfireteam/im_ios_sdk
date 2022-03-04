//
//  BFConversationListController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/18.
//

#import "BFConversationListController.h"
#import <MSIMSDK/MSIMSDK.h>
#import "BFNaviBarIndicatorView.h"
#import "MSIMSDK-UIKit.h"
#import "BFChatViewController.h"
#import "BFChatRoomViewController.h"
#import "BFConversationHeaderView.h"


@interface BFConversationListController ()<MSUIConversationListControllerDelegate>

@property(nonatomic,strong) BFNaviBarIndicatorView *titleView;

@property(nonatomic,strong) BFConversationHeaderView *convHeader;

@property(nonatomic,strong) MSUIConversationListController *conVC;

@property(nonatomic,strong) UIView *networkBarView;

@end

@implementation BFConversationListController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addChildViewController:self.conVC];
    [self.view addSubview:self.conVC.view];
    [self setupNavigation];
    
    self.convHeader = [[BFConversationHeaderView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, 103)];
    self.conVC.tableView.tableHeaderView = self.convHeader;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(chatRoomTap)];
    [self.convHeader addGestureRecognizer:tap];
    [self.convHeader reloadData];
    /// 当前的连接状态
    MSIMNetStatus status = [MSIMManager sharedInstance].connStatus;
    [self updateTitleViewWith: status];
}

- (instancetype)init
{
    if (self = [super init]) {
        self.conVC = [[MSUIConversationListController alloc]init];
        self.conVC.delegate = self;
        [self addNotifications];
    }
    return self;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.view bringSubviewToFront:self.titleView];
}

- (void)addNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onNetworkChanged:) name:MSUIKitNotification_ConnListener object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(conversationSyncStart) name:MSUIKitNotification_ConversationSyncStart object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(conversationSyncFinish) name:MSUIKitNotification_ConversationSyncFinish object:nil];
    
    WS(weakSelf)
    [[NSNotificationCenter defaultCenter]addObserverForName:MSUIKitNotification_ChatRoomConv_update object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf onChatRoomConvUpdate: note];
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupNavigation
{
    self.navView.hidden = YES;
    _titleView = [[BFNaviBarIndicatorView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, NavBar_Height + StatusBar_Height)];
    [_titleView setTitle:@"MESSAGE"];
    [self.view addSubview:_titleView];

    [self updateTitleViewWith:MSIMManager.sharedInstance.connStatus];
}

- (void)onNetworkChanged:(NSNotification *)notification
{
    NSNumber *codeNum = notification.object;
    [self updateTitleViewWith:codeNum.integerValue];
}

- (void)updateTitleViewWith:(MSIMNetStatus)status
{
    switch (status) {
        case IMNET_STATUS_SUCC:
            [_titleView stopAnimating];
            [_titleView setTitle:@"MESSAGE"];
            break;
        case IMNET_STATUS_CONNECTING:
            [self hideNetworkDisconnetBar];
            [_titleView startAnimating];
            [_titleView setTitle:@"连接中..."];
            break;
        case IMNET_STATUS_DISCONNECT:
            [_titleView stopAnimating];
            [_titleView setTitle:@"MESSAGE(断开连接)"];
            [self showNetworkDisconnetBar];
            break;
        case IMNET_STATUS_CONNFAILED:
            [_titleView stopAnimating];
            [_titleView setTitle:@"MESSAGE(连接失败)"];
            break;
        default:
            break;
    }
}

- (void)conversationSyncStart
{
    [self.titleView startAnimating];
    [self.titleView setTitle:@"拉取中..."];
}

- (void)conversationSyncFinish
{
    [self.titleView stopAnimating];
    [self.titleView setTitle:@"MESSAGE"];
    [self updateTabbarUnreadCount];
}

- (void)showNetworkDisconnetBar
{
    self.networkBarView = [[UIView alloc] initWithFrame:CGRectMake(0, StatusBar_Height + NavBar_Height, Screen_Width, 40)];
    self.networkBarView.backgroundColor = [UIColor redColor];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, Screen_Width - 20, 40)];
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor whiteColor];
    label.text = @"当前网络不可用，请检查网络设置";
    [self.networkBarView addSubview:label];
    [self.view addSubview:self.networkBarView];
}

- (void)hideNetworkDisconnetBar
{
    [self.networkBarView removeFromSuperview];
    self.networkBarView = nil;
}

- (void)updateTabbarUnreadCount
{
    NSInteger count = [[MSConversationProvider provider]allUnreadCount];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tabBarItem.badgeValue = count ? [NSString stringWithFormat:@"%zd",count] : nil;
        [[UIApplication sharedApplication]setApplicationIconBadgeNumber:count];
    });
}

- (void)onChatRoomConvUpdate:(NSNotification *)note
{
    [self.convHeader reloadData];
}

/// 进入聊天室
- (void)chatRoomTap
{
    BFChatRoomViewController *vc = [[BFChatRoomViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - MSUIConversationListControllerDelegate
- (void)conversationListController:(MSUIConversationListController *)conversationController didSelectConversation:(MSUIConversationCell *)conversationCell
{
    BFChatViewController *vc = [[BFChatViewController alloc]init];
    MSUIConversationCellData *data = conversationCell.convData;
    vc.partner_id = data.conv.partner_id;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)conversationListUnreadCountChanged
{
    [self updateTabbarUnreadCount];
}

@end
