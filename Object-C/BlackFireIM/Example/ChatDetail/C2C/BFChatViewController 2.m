//
//  BFChatViewController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/5/31.
//

#import "BFChatViewController.h"
#import "MSIMSDK-UIKit.h"
#import "YBImageBrowser.h"
#import "YBIBVideoData.h"
#import "BFCallMessageCell.h"
#import "BFCallMessageCellData.h"

@interface BFChatViewController ()<MSChatViewControllerDelegate>

@property(nonatomic,strong) MSChatViewController *chatController;

@end

@implementation BFChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor d_colorWithColorLight:RGB(240, 240, 240) dark:TController_Background_Color_Dark];
    
    self.chatController = [[MSChatViewController alloc]init];
    self.chatController.delegate = self;
    self.chatController.partner_id = self.partner_id;
    [self addChildViewController:self.chatController];
    [self.view addSubview:self.chatController.view];
    
    [[MSProfileProvider provider] providerProfile:self.partner_id complete:^(MSProfileInfo * _Nonnull profile) {
            self.navView.navTitleL.text = profile.nick_name;
    }];
    
    WS(weakSelf)
    [[NSNotificationCenter defaultCenter] addObserverForName:MSUIKitNotification_ProfileUpdate object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf profileUpdate:note];
    }];
}


#pragma mark - MSChatViewControllerDelegate

- (void)chatController:(MSChatViewController *)controller didSendMessage:(MSIMMessage *)message
{
    //主动发送的每一条消息都会进入这个回调，你可以在此做一些统计埋点等工作。。。
}

//将要展示在列表中的每和条消息都会先进入这个回调，你可以在此针对自定义消息构建数据模型
- (MSMessageCellData *)chatController:(MSChatViewController *)controller prepareForMessage:(MSIMMessage *)message
{
    if (message.customElem != nil) {
        MSIMCustomElem *customElem = message.customElem;
        NSDictionary *dic = [customElem.jsonStr el_convertToDictionary];
        if (message.type == MSIM_MSG_TYPE_CUSTOM_UNREADCOUNT_RECAL) {
            
        }else if(message.type == MSIM_MSG_TYPE_CUSTOM_UNREADCOUNT_NO_RECALL) {
            MSIMCustomSubType subType = [dic[@"type"]integerValue];
            if (subType == MSIMCustomSubTypeVoiceCall || subType == MSIMCustomSubTypeVideoCall) {
                BFCallMessageCellData *callData = [[BFCallMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
                callData.callType = (subType == MSIMCustomSubTypeVideoCall ? MSCallType_Video : MSCallType_Voice);
                callData.notice = [MSCallManager parseToMessageShow:dic callType:(subType == MSIMCustomSubTypeVoiceCall ? MSCallType_Voice : MSCallType_Video) isSelf:message.isSelf];
                callData.showName = YES;
                callData.message = message;
                return callData;
            }
        }
    }
    return nil;
}

- (Class)chatController:(MSChatViewController *)controller onShowMessageData:(MSMessageCellData *)cellData
{
    //你可以自定义消息气泡的UI,对基本消息类型你可以直接返回nil，采用默认样式
    if ([cellData isKindOfClass:[BFCallMessageCellData class]]) {
        return [BFCallMessageCell class];
    }
    return nil;
}

///点击某一“更多”单元的回调委托
- (void)chatController:(MSChatViewController *)controller onSelectMoreCell:(MSInputMoreCell *)cell
{
    if (cell.data.tye == MSIM_MORE_VOICE_CALL) {//语音通话
        
        [[MSCallManager shareInstance] callToPartner:self.partner_id creator:[MSIMTools sharedInstance].user_id callType:MSCallType_Voice action:CallAction_Call room_id:nil];
        
    }else if (cell.data.tye == MSIM_MORE_VIDEO_CALL) {//视频通话
        
        [[MSCallManager shareInstance] callToPartner:self.partner_id creator:[MSIMTools sharedInstance].user_id callType:MSCallType_Video action:CallAction_Call room_id:nil];
    }
}

///点击消息头像回调
- (void)chatController:(MSChatViewController *)controller onSelectMessageAvatar:(MSMessageCell *)cell
{
    NSLog(@"点击头像...");
}

///收到对方正在输入消息通知
- (void)chatController:(MSChatViewController *)controller onRecieveTextingMessage:(MSIMElem *)elem
{
    self.navView.navTitleL.text = TUILocalizableString(TUIkitMessageTipsTextingMessage);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[MSProfileProvider provider] providerProfile:self.partner_id complete:^(MSProfileInfo * _Nonnull profile) {
                self.navView.navTitleL.text = profile.nick_name;
        }];
    });
}

///点击消息内容回调
- (void)chatController:(MSChatViewController *)controller onSelectMessageContent:(MSMessageCell *)cell
{
    if (cell.messageData.message.type == MSIM_MSG_TYPE_IMAGE || cell.messageData.message.type == MSIM_MSG_TYPE_VIDEO) {
        NSMutableArray *tempArr = [NSMutableArray array];
        NSInteger defaultIndex = 0;
        for (NSInteger i = 0; i < self.chatController.messageController.uiMsgs.count; i++) {
            MSMessageCellData *data =  self.chatController.messageController.uiMsgs[i];
            MSMessageCell *dataCell = (MSMessageCell *)[self.chatController.messageController.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if (data.message.type == MSIM_MSG_TYPE_IMAGE) {
                MSIMImageElem *imageElem = data.message.imageElem;
                YBIBImageData *imageData = [YBIBImageData new];
                if ([[NSFileManager defaultManager]fileExistsAtPath:imageElem.path]) {
                    imageData.imagePath = imageElem.path;
                }else {
                    imageData.imageURL = [NSURL URLWithString:imageElem.url];
                }
                imageData.projectiveView = dataCell.container.subviews.firstObject;
                [tempArr addObject:imageData];
            }else if (data.message.type == MSIM_MSG_TYPE_VIDEO) {
                MSIMVideoElem *videoElem = data.message.videoElem;
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
    }else if ([cell isKindOfClass:[BFCallMessageCell class]]) {
        MSIMCustomElem *customElem = cell.messageData.message.customElem;
        NSDictionary *dic = [customElem.jsonStr el_convertToDictionary];
        MSIMCustomSubType subType = [dic[@"type"]integerValue];
        [[MSCallManager shareInstance] callToPartner:self.partner_id creator:[MSIMTools sharedInstance].user_id callType:(subType == MSIMCustomSubTypeVideoCall ? MSCallType_Video : MSCallType_Voice) action:CallAction_Call room_id:nil];
    }
}

///用户个人信息更新通知
- (void)profileUpdate:(NSNotification *)note
{
    NSArray<MSProfileInfo *> *profiles = note.object;
    for (MSProfileInfo *info in profiles) {
        if ([info.user_id isEqualToString:self.partner_id] || [info.user_id isEqualToString:[MSIMTools sharedInstance].user_id]) {
            [self.chatController.messageController.tableView reloadData];
        }
        if ([info.user_id isEqualToString:self.partner_id]) {
            self.navView.navTitleL.text = info.nick_name;
        }
    }
}

@end
