//
//  BFChatRoomViewController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/10/29.
//

#import "BFChatRoomViewController.h"
#import "MSIMSDK-UIKit.h"
#import "YBImageBrowser.h"
#import "YBIBVideoData.h"
#import "BFChatRoomEditController.h"
#import "BFEditTodInfoController.h"


@interface BFChatRoomViewController ()<MSChatRoomControllerDelegate>

@property(nonatomic,strong) MSChatRoomController *chatController;

@property(nonatomic,strong) MSGroupInfo *roomInfo;

@end

@implementation BFChatRoomViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor d_colorWithColorLight:RGB(240, 240, 240) dark:TController_Background_Color_Dark];
    [self.navView.rightButton setImage:[UIImage d_imageWithImageLight:@"more_icon" dark:@"more_icon_white"] forState:UIControlStateNormal];
    
    self.chatController = [[MSChatRoomController alloc]init];
    self.chatController.delegate = self;
    self.chatController.roomInfo = self.roomInfo;
    [self addChildViewController:self.chatController];
    [self.view addSubview:self.chatController.view];
    
    self.navView.navTitleL.text = self.roomInfo.room_name;
    [self addNotifications];
}

- (void)addNotifications
{
    WS(weakSelf)
    [[NSNotificationCenter defaultCenter] addObserverForName:MSUIKitNotification_EnterChatroom_success object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf enterChatRoom: note];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:MSUIKitNotification_ChatRoomConv_update object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf chatRoomEvent: note];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:MSUIKitNotification_ChatRoom_Event object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf chatRoomEvent: note];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"kChatRoomTipsDidTap" object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf chatRoomTipsDidTap];
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (MSGroupInfo *)roomInfo
{
    return MSChatRoomManager.sharedInstance.chatroomInfo;
}

/// 聊天室设置界面
- (void)nav_rightButtonClick
{
    if (self.roomInfo) {
        [self.view endEditing:YES];
        BFChatRoomEditController *vc = [[BFChatRoomEditController alloc]init];
        vc.roomInfo = self.roomInfo;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)chatRoomTipsDidTap
{
    if (self.roomInfo) {
        BFEditTodInfoController *vc = [[BFEditTodInfoController alloc]init];
        vc.roomInfo = self.roomInfo;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

/// 加入聊天室成功
- (void)enterChatRoom:(NSNotification *)note
{
    self.chatController.roomInfo = self.roomInfo;
    self.navView.navTitleL.text = self.roomInfo.room_name;
}

/// 接收到聊天室事件通知处理
- (void)chatRoomEvent:(NSNotification *)note
{
    MSGroupEvent *event = note.object;
    //事件类型：
      //1：聊天室已被解散
      //2：聊天室属性已修改
      //3：管理员 %s 将本聊天室设为听众模式
      //4: 管理员 %s 恢复聊天室发言功能
      //5：管理员 %s 上线
      //6：管理员 %s 下线
      //7: 管理员 %s 将用户 %s 禁言
      //8: 管理员 %s 将用户 %s、%s 等人禁言
      //9: %s 成为本聊天室管理员
      //10: 管理员 %s 指派 %s 为临时管理员
      //11：管理员 %s 指派 %s、%s 等人为临时管理员
    switch (event.tips.event) {
        case 1:
        {
            [MSHelper showToastString:@"This chatroom is dismissed."];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
            break;
        case 2:
        {
            [self.chatController.messageController addSystemTips:@"Chatroom info has been changed."];
        }
            break;
        case 3:
        {
            NSString *uid = [NSString stringWithFormat:@"%@",event.tips.uids.firstObject];
            MSProfileInfo *info = [[MSProfileProvider provider]providerProfileFromLocal:uid];
            [self.chatController.messageController addSystemTips:[NSString stringWithFormat:@"%@ disabled sending message for this chatroom.", XMNoNilString(info.nick_name)]];
        }
            break;
        case 4:
        {
            NSString *uid = [NSString stringWithFormat:@"%@",event.tips.uids.firstObject];
            MSProfileInfo *info = [[MSProfileProvider provider]providerProfileFromLocal:uid];
            [self.chatController.messageController addSystemTips:[NSString stringWithFormat:@"%@ enabled sending message for this chatroom.",XMNoNilString(info.nick_name)]];
        }
            break;
        case 5:
        {
            NSString *uid = [NSString stringWithFormat:@"%@",event.tips.uids.firstObject];
            if (![uid isEqualToString:[MSIMTools sharedInstance].user_id]) {
                MSProfileInfo *info = [[MSProfileProvider provider]providerProfileFromLocal:uid];
                [self.chatController.messageController addSystemTips:[NSString stringWithFormat:@"Admin: %@ entered this room.", XMNoNilString(info.nick_name)]];
            }
        }
            break;
        case 6:
        {
            NSString *uid = [NSString stringWithFormat:@"%@",event.tips.uids.firstObject];
            if (![uid isEqualToString:[MSIMTools sharedInstance].user_id]) {
                MSProfileInfo *info = [[MSProfileProvider provider]providerProfileFromLocal:uid];
                [self.chatController.messageController addSystemTips:[NSString stringWithFormat:@" Admin: %@ leaved this room.",XMNoNilString(info.nick_name)]];
            }
        }
            break;
        case 7:
        {
            NSString *uid1 = [NSString stringWithFormat:@"%@",event.tips.uids.firstObject];
            NSString *uid2 = [NSString stringWithFormat:@"%@",event.tips.uids.lastObject];
            MSProfileInfo *info1 = [[MSProfileProvider provider]providerProfileFromLocal:uid1];
            MSProfileInfo *info2 = [[MSProfileProvider provider]providerProfileFromLocal:uid2];
            [self.chatController.messageController addSystemTips:[NSString stringWithFormat:@"%@ muted %@. Reason: %@.",XMNoNilString(info1.nick_name),XMNoNilString(info2.nick_name),XMNoNilString(event.reason)]];
        }
            break;
        case 8:
        {
            if (event.tips.uids.count <= 2) return;
            NSString *managerName;
            NSString *membersStr;
            for (NSInteger i = 0; i < event.tips.uids.count; i++) {
                NSString *uid = [NSString stringWithFormat:@"%@",event.tips.uids[i]];
                if (i == 0) {
                    managerName = [[MSProfileProvider provider]providerProfileFromLocal:uid].nick_name;
                }else {
                    NSString *name = [[MSProfileProvider provider]providerProfileFromLocal:uid].nick_name;
                    if (membersStr == nil) {
                        membersStr = XMNoNilString(name);
                    }else {
                        membersStr = [NSString stringWithFormat:@"%@、%@",membersStr,XMNoNilString(name)];
                    }
                }
            }
            [self.chatController.messageController addSystemTips:[NSString stringWithFormat:@"%@ muted %@. Reason: %@.",XMNoNilString(managerName),XMNoNilString(membersStr),XMNoNilString(event.reason)]];
        }
            break;
        case 9:
        {
            if (event.tips.uids.count < 1) return;
            NSString *name = [[MSProfileProvider provider]providerProfileFromLocal:[NSString stringWithFormat:@"%@",event.tips.uids.firstObject]].nick_name;
            [self.chatController.messageController addSystemTips:[NSString stringWithFormat:@"%@ becomes the admin of this room.",XMNoNilString(name)]];
        }
            break;
        case 10:
        {
            if (event.tips.uids.count < 2) return;
            NSString *adminName = [[MSProfileProvider provider]providerProfileFromLocal:[NSString stringWithFormat:@"%@",event.tips.uids.firstObject]].nick_name;
            NSString *userName = [[MSProfileProvider provider]providerProfileFromLocal:[NSString stringWithFormat:@"%@",event.tips.uids.lastObject]].nick_name;
            [self.chatController.messageController addSystemTips:[NSString stringWithFormat:@"%@ assigned %@ as a temporary admin of the room.",XMNoNilString(adminName),XMNoNilString(userName)]];
        }
            break;
        case 11:
        {
            if (event.tips.uids.count <= 2) return;
            NSString *managerName;
            NSString *membersStr;
            for (NSInteger i = 0; i < event.tips.uids.count; i++) {
                NSString *uid = [NSString stringWithFormat:@"%@",event.tips.uids[i]];
                if (i == 0) {
                    managerName = [[MSProfileProvider provider]providerProfileFromLocal:uid].nick_name;
                }else {
                    NSString *name = [[MSProfileProvider provider]providerProfileFromLocal:uid].nick_name;
                    if (membersStr == nil) {
                        membersStr = XMNoNilString(name);
                    }else {
                        membersStr = [NSString stringWithFormat:@"%@、%@",membersStr,XMNoNilString(name)];
                    }
                }
            }
            [self.chatController.messageController addSystemTips:[NSString stringWithFormat:@"%@ assigned %@ as temporary admins of the room.",XMNoNilString(managerName),XMNoNilString(membersStr)]];
        }
            break;
        default:
            break;
    }
}

#pragma mark - MSChatRoomControllerDelegate

- (void)chatController:(MSChatRoomController *)controller didSendMessage:(MSIMElem *)elem
{
    //主动发送的每一条消息都会进入这个回调，你可以在此做一些统计埋点等工作。。。
}

//将要展示在列表中的每和条消息都会先进入这个回调，你可以在此针对自定义消息构建数据模型
- (MSMessageCellData *)chatController:(MSChatRoomController *)controller prepareForMessage:(MSIMElem *)elem
{
    return nil;
}

- (Class)chatController:(MSChatRoomController *)controller onShowMessageData:(MSMessageCellData *)cellData
{
    //你可以自定义消息气泡的UI,对基本消息类型你可以直接返回nil，采用默认样式
    return nil;
}

///点击某一“更多”单元的回调委托
- (void)chatController:(MSChatRoomController *)controller onSelectMoreCell:(MSInputMoreCell *)cell
{

}

///点击消息头像回调
- (void)chatController:(MSChatRoomController *)controller onSelectMessageAvatar:(MSMessageCell *)cell
{
    NSLog(@"tap avatar...");
}

///点击消息内容回调
- (void)chatController:(MSChatRoomController *)controller onSelectMessageContent:(MSMessageCell *)cell
{
    if (cell.messageData.elem.type == MSIM_MSG_TYPE_IMAGE || cell.messageData.elem.type == MSIM_MSG_TYPE_VIDEO) {
        NSMutableArray *tempArr = [NSMutableArray array];
        NSInteger defaultIndex = 0;
        for (NSInteger i = 0; i < self.chatController.messageController.uiMsgs.count; i++) {
            MSMessageCellData *data =  self.chatController.messageController.uiMsgs[i];
            MSMessageCell *dataCell = (MSMessageCell *)[self.chatController.messageController.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if (data.elem.type == MSIM_MSG_TYPE_IMAGE) {
                MSIMImageElem *imageElem = (MSIMImageElem *)data.elem;
                YBIBImageData *imageData = [YBIBImageData new];
                if ([[NSFileManager defaultManager]fileExistsAtPath:imageElem.path]) {
                    imageData.imagePath = imageElem.path;
                }else {
                    imageData.imageURL = [NSURL URLWithString:imageElem.url];
                }
                imageData.projectiveView = dataCell.container.subviews.firstObject;
                [tempArr addObject:imageData];
            }else if (data.elem.type == MSIM_MSG_TYPE_VIDEO) {
                MSIMVideoElem *videoElem = (MSIMVideoElem *)data.elem;
                YBIBVideoData *videoData = [YBIBVideoData new];
                if ([[NSFileManager defaultManager]fileExistsAtPath:videoElem.videoPath]) {
                    videoData.videoURL = [NSURL fileURLWithPath:videoElem.videoPath];
                }else {
                    videoData.videoURL = [NSURL URLWithString:videoElem.videoUrl];
                }
                videoData.projectiveView = dataCell.container.subviews.firstObject;
                [tempArr addObject:videoData];
            }
            if (cell.messageData == data) {
                defaultIndex = tempArr.count-1;
            }
        }
        YBImageBrowser *browser = [YBImageBrowser new];
        browser.dataSourceArray = tempArr;
        browser.currentPage = defaultIndex;
        [browser show];
    }else if (cell.messageData.elem.type == MSIM_MSG_TYPE_LOCATION) {
        
    }
}

@end
