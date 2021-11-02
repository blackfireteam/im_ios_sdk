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
#import "BFChatRoomMemberListController.h"


@interface BFChatRoomViewController ()<MSChatRoomControllerDelegate>

@property(nonatomic,strong) MSChatRoomController *chatController;

@property(nonatomic,strong) MSChatRoomInfo *roomInfo;

@end

@implementation BFChatRoomViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(showChatRoomMembers)];
    
    self.chatController = [[MSChatRoomController alloc]init];
    self.chatController.delegate = self;
    [self addChildViewController:self.chatController];
    [self.view addSubview:self.chatController.view];
    
    [self addNotifications];
    [self enterChatRoom];
}

- (void)addNotifications
{
    WS(weakSelf)
    [[NSNotificationCenter defaultCenter] addObserverForName:MSUIKitNotification_ChatRoom_Event object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf chatRoomEvent: note];
    }];
}

- (void)dealloc
{
    [[MSIMManager sharedInstance] quitChatRoom:self.roomInfo.room_id.integerValue succ:^{
        
        [MSHelper showToastSucc:@"quit chat room"];
    } failed:^(NSInteger code, NSString *desc) {
        [MSHelper showToastFail:desc];
    }];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

/// 申请加入聊天室
- (void)enterChatRoom
{
    [[MSIMManager sharedInstance] joinInChatRoom:2 succ:^(MSChatRoomInfo * _Nonnull info) {
        
        self.roomInfo = info;
        self.chatController.room_id = self.roomInfo.room_id;
        self.navigationItem.title = self.roomInfo.room_name;
        
    } failed:^(NSInteger code, NSString *desc) {
        [MSHelper showToastFail:desc];
    }];
}

/// 展示聊天室成员列表
- (void)showChatRoomMembers
{
    if (self.roomInfo) {
        [self.view endEditing:YES];
        BFChatRoomMemberListController *vc = [[BFChatRoomMemberListController alloc]init];
        vc.roomInfo = self.roomInfo;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

/// 接收到聊天室事件通知处理
- (void)chatRoomEvent:(NSNotification *)note
{
    MSChatRoomEvent *event = note.object;
    //事件 0：聊天室被销毁（所有用户被迫离开聊天室）1：聊天室信息修改，
    //2：用户上线， 3：用户下线(自己被踢掉也会收到)
    //4：全体禁言 5：解除全体禁言
    if (event.eventType == 0) {
        [MSHelper showToastString:@"Chat room is dissolved."];
        [self.navigationController popViewControllerAnimated:YES];
    }else if (event.eventType == 1) {
        
        
    }else if (event.eventType == 2) {
        
    }else if (event.eventType == 3) {
        
        if ([event.uid isEqualToString:[MSIMTools sharedInstance].user_id]) {//自己被踢出了聊天室
            [MSHelper showToastString:@"You has been kicked out."];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else if (event.eventType == 4) {
        
    }else if (event.eventType == 5) {
        
    }
}

#pragma mark - MSChatViewControllerDelegate

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

///收到对方正在输入消息通知
- (void)chatController:(MSChatRoomController *)controller onRecieveTextingMessage:(MSIMElem *)elem
{
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
    }
}

@end
