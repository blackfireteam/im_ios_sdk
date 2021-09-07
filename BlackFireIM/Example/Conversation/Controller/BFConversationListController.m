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

@interface BFConversationListController ()<MSUIConversationListControllerDelegate>

@property(nonatomic,strong) BFNaviBarIndicatorView *titleView;

@property(nonatomic,strong) MSUIConversationListController *conVC;

@property(nonatomic,strong) UIView *networkBarView;

@end

@implementation BFConversationListController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.conVC = [[MSUIConversationListController alloc]init];
    self.conVC.delegate = self;
    [self addChildViewController:self.conVC];
    [self.view addSubview:self.conVC.view];
    [self setupNavigation];
    
    [self addNotifications];
    /// 当前的连接状态
    MSIMNetStatus status = [MSIMManager sharedInstance].connStatus;
    [self updateTitleViewWith: status];
}

- (void)addNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onNetworkChanged:) name:MSUIKitNotification_ConnListener object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(conversationSyncStart) name:MSUIKitNotification_ConversationSyncStart object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(conversationSyncFinish) name:MSUIKitNotification_ConversationSyncFinish object:nil];
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
    self.networkBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 40)];
    self.networkBarView.backgroundColor = [UIColor redColor];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, Screen_Width - 20, 40)];
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor whiteColor];
    label.text = @"当前网络不可用，请检查网络设置";
    [self.networkBarView addSubview:label];
    self.conVC.tableView.tableHeaderView = self.networkBarView;
}

- (void)hideNetworkDisconnetBar
{
    self.conVC.tableView.tableHeaderView = nil;
    self.networkBarView = nil;
}

- (void)updateTabbarUnreadCount
{
    NSInteger count = [[MSConversationProvider provider]allUnreadCount];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tabBarItem.badgeValue = count ? [NSString stringWithFormat:@"%zd",count] : nil;
    });
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
