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

@end

@implementation BFConversationListController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addChildViewController:self.conVC];
    [self.view addSubview:self.conVC.view];
    [self setupNavigation];
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
    MSIMNetStatus status = [notification.object intValue];
    [self updateTitleViewWith:status];
}

- (void)updateTitleViewWith:(MSIMNetStatus)status
{
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

- (void)conversationSyncStart
{
    [self.titleView setTitle:@"拉取中..."];
}

- (void)conversationSyncFinish
{
    [self.titleView setTitle:@"MESSAGE"];
    [self updateTabbarUnreadCount];
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
