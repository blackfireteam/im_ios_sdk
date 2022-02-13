//
//  BFTabBarController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/17.
//

#import "BFTabBarController.h"
#import "BFConversationListController.h"
#import "BFDiscoveryController.h"
#import "BFProfileViewController.h"
#import "BFNavigationController.h"
#import "BFHomeController.h"
#import "MSIMSDK-UIKit.h"
#import <MSIMSDK/MSIMSDK.h>
#import "AppDelegate.h"
#import "BFLoginController.h"


@interface BFTabBarController ()

@end

@implementation BFTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (@available(iOS 15.0, *)) {
        UITabBarAppearance *appearance = [UITabBarAppearance new];
        self.tabBar.standardAppearance = appearance;
        self.tabBar.scrollEdgeAppearance = appearance;
    }
    self.tabBar.unselectedItemTintColor = [UIColor grayColor];
    self.tabBar.tintColor = [UIColor darkGrayColor];
    UITabBarItem *item = [UITabBarItem appearance];
    [item setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]} forState:UIControlStateNormal];
    [item setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]} forState:UIControlStateSelected];

    BFHomeController *homeVC = [[BFHomeController alloc]init];
    homeVC.tabBarItem.title = TUILocalizableString(Home_tab);
    homeVC.tabBarItem.image = [[UIImage imageNamed:@"home_tab_nor"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    homeVC.tabBarItem.selectedImage = [[UIImage imageNamed:@"home_tab_sel"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    BFNavigationController *homeNav = [[BFNavigationController alloc]initWithRootViewController:homeVC];
    [self addChildViewController:homeNav];
    
    BFDiscoveryController *tactVC = [[BFDiscoveryController alloc]init];
    tactVC.tabBarItem.title = TUILocalizableString(Discovery_tab);
    tactVC.tabBarItem.image = [[UIImage imageNamed:@"contact_normal"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tactVC.tabBarItem.selectedImage = [[UIImage imageNamed:@"contact_selected"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    BFNavigationController *tactNav = [[BFNavigationController alloc]initWithRootViewController:tactVC];
    [self addChildViewController:tactNav];
    
    BFConversationListController *convVC = [[BFConversationListController alloc]init];
    convVC.tabBarItem.title = TUILocalizableString(Message_tab);
    convVC.tabBarItem.image = [[UIImage imageNamed:@"session_normal"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    convVC.tabBarItem.selectedImage = [[UIImage imageNamed:@"session_selected"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    BFNavigationController *convNav = [[BFNavigationController alloc]initWithRootViewController:convVC];
    [self addChildViewController:convNav];
    
    BFProfileViewController *profileVC = [[BFProfileViewController alloc]init];
    profileVC.tabBarItem.title = TUILocalizableString(Profile_tab);
    profileVC.tabBarItem.image = [[UIImage imageNamed:@"myself_normal"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    profileVC.tabBarItem.selectedImage = [[UIImage imageNamed:@"myself_selected"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    BFNavigationController *profileNav = [[BFNavigationController alloc]initWithRootViewController:profileVC];
    [self addChildViewController:profileNav];
    
    WS(weakSelf)
    [[NSNotificationCenter defaultCenter] addObserverForName:MSUIKitNotification_SignalMessageListener object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
       [weakSelf onSignalMessage:note];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:MSUIKitNotification_MessageListener object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
       [weakSelf onNewMessage:note];
    }];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onUserLogStatusChanged:) name:MSUIKitNotification_UserStatusListener object:nil];
}

- (void)onUserLogStatusChanged:(NSNotification *)notification
{
    MSIMUserStatus status = [notification.object intValue];
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
        default:
            break;
    }
}

- (void)logout
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.window.rootViewController = [[BFNavigationController alloc]initWithRootViewController:[BFLoginController new]];
}

///收到新消息
- (void)onSignalMessage:(NSNotification *)note
{
    NSArray *messages = note.object;
    MSIMMessage *message = messages.lastObject;
    if (message.customElem == nil) return;
    MSIMCustomElem *customElem = message.customElem;
    NSDictionary *dic = [customElem.jsonStr el_convertToDictionary];
    MSIMCustomSubType type = [dic[@"type"] integerValue];
    if (type == MSIMCustomSubTypeVoiceCall || type == MSIMCustomSubTypeVideoCall) {
        NSInteger event = [dic[@"event"] integerValue];
        NSString *room_id = dic[@"room_id"];
        [[MSCallManager shareInstance] recieveCall:message.partnerID creator:[MSCallManager getCreatorFrom:room_id] callType:(type == MSIMCustomSubTypeVoiceCall ? MSCallType_Voice : MSCallType_Video) action:event room_id:room_id];
    }
}

- (void)onNewMessage:(NSNotification *)note
{
    NSArray *messages = note.object;
    for (MSIMMessage *message in messages) {
        if (message.customElem != nil) {
            MSIMCustomElem *customElem = message.customElem;
            NSDictionary *dic = [customElem.jsonStr el_convertToDictionary];
            MSIMCustomSubType type = [dic[@"type"] integerValue];
            if (type == MSIMCustomSubTypeVoiceCall || type == MSIMCustomSubTypeVideoCall) {
                NSInteger event = [dic[@"event"] integerValue];
                NSString *room_id = dic[@"room_id"];
                if (![message.fromUid isEqualToString:[MSIMTools sharedInstance].user_id]) {
                    [[MSCallManager shareInstance] recieveCall:message.partnerID creator:[MSCallManager getCreatorFrom:room_id] callType:(type == MSIMCustomSubTypeVoiceCall ? MSCallType_Voice : MSCallType_Video) action:event room_id:room_id];
                }
            }
        }
    }
}

@end
