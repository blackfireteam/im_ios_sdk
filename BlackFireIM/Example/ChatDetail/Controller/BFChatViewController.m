//
//  BFChatViewController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/17.
//

#import "BFChatViewController.h"
#import "UIColor+BFDarkMode.h"
#import "BFHeader.h"
#import "BFMessageController.h"
#import "BFInputViewController.h"
#import "MSIMSDK.h"
#import "YBImageBrowser.h"
#import "YBIBVideoData.h"
#import <SVProgressHUD.h>
#import "BFChatViewController+More.h"
#import "BFMessageCell.h"


@interface BFChatViewController ()<BFInputViewControllerDelegate,BFMessageControllerDelegate>

@property(nonatomic,strong) BFMessageController *messageController;

@property(nonatomic,strong) BFInputViewController *inputController;

@end

@implementation BFChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupViews];
}

- (void)setupViews
{
    self.view.backgroundColor = [UIColor d_colorWithColorLight:TController_Background_Color dark:TController_Background_Color_Dark];
    self.messageController = [[BFMessageController alloc]init];
    self.messageController.delegate = self;
    self.messageController.partner_id = self.partner_id;
    self.messageController.view.frame = CGRectMake(0, 0, Screen_Width, Screen_Height-TTextView_Height-Bottom_SafeHeight);
    [self addChildViewController:self.messageController];
    [self.view addSubview:self.messageController.view];
    
    self.inputController = [[BFInputViewController alloc]init];
    self.inputController.view.frame = CGRectMake(0, Screen_Height-TTextView_Height-Bottom_SafeHeight, Screen_Width, TTextView_Height+Bottom_SafeHeight);
    self.inputController.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.inputController.delegate = self;
    [self addChildViewController:self.inputController];
    [self.view addSubview:self.inputController.view];
    
    [[MSProfileProvider provider] providerProfile:self.partner_id.integerValue complete:^(MSProfileInfo * _Nonnull profile) {
            self.navigationItem.title = profile.nick_name;
    }];
}

#pragma mark - <BFInputViewControllerDelegate>

- (void)inputController:(BFInputViewController *)inputController didChangeHeight:(CGFloat)height
{
    WS(weakSelf)
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect msgFrame = weakSelf.messageController.view.frame;
        msgFrame.size.height = weakSelf.view.frame.size.height-height;
        weakSelf.messageController.view.frame = msgFrame;
        
        CGRect inputFrame = weakSelf.inputController.view.frame;
        inputFrame.origin.y = msgFrame.origin.y + msgFrame.size.height;
        inputFrame.size.height = height;
        weakSelf.inputController.view.frame = inputFrame;
        [weakSelf.messageController scrollToBottom:NO];
        } completion:^(BOOL finished) {
            
        }];
}

- (void)inputController:(BFInputViewController *)inputController didSendMessage:(NSString *)msg
{
    MSIMTextElem *textElem = [[MSIMManager sharedInstance] createTextMessage:msg];
    [[MSIMManager sharedInstance] sendC2CMessage:textElem toReciever:self.partner_id successed:^(NSInteger msg_id) {
        
        } failed:^(NSInteger code, NSString * _Nonnull desc) {
            NSLog(@"code = %zd,desc = %@",code,desc);
    }];
}

- (void)inputControllerDidInputAt:(BFInputViewController *)inputController
{
    
}

/**
 *  有 @xxx 字符删除
 */
- (void)inputController:(BFInputViewController *)inputController didDeleteAt:(NSString *)atText
{
    
}

/// 点击拍照，照片等更多功能
- (void)inputController:(BFInputViewController *)inputController didSelectMoreCell:(BFInputMoreCell *)cell
{
    if (cell.data.tye == BFIM_MORE_PHOTO) {//照片
        [self selectPhotoForSend];
    }else if (cell.data.tye == BFIM_MORE_VIDEO) {//视频
        [self selectVideoForSend];
    }
}

#pragma mark - <BFMessageControllerDelegate>

/**
 *  控制器点击回调
 *  您可以通过该回调实现：重置 InputControoler，收起键盘。
 */
- (void)didTapInMessageController:(BFMessageController *)controller
{
    [self.inputController reset];
}

/**
 *  点击消息头像委托
 *  您可以通过该回调实现：跳转到对应用户的详细信息界面。
 */
- (void)messageController:(BFMessageController *)controller onSelectMessageAvatar:(BFMessageCell *)cell
{
    [self.inputController reset];
}

/**
 *  点击消息内容委托
 */
- (void)messageController:(BFMessageController *)controller onSelectMessageContent:(BFMessageCell *)cell
{
    [self.inputController reset];
    if (cell.messageData.elem.type == BFIM_MSG_TYPE_IMAGE) {//点击图片消息，查看图片
        NSMutableArray *tempArr = [NSMutableArray array];
        NSInteger defaultIndex = 0;
        for (NSInteger i = 0; i < self.messageController.uiMsgs.count; i++) {
            BFMessageCellData *data = self.messageController.uiMsgs[i];
            if (data.elem.type == BFIM_MSG_TYPE_IMAGE) {
                BFMessageCell *dataCell = (BFMessageCell *)[self.messageController.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                MSIMImageElem *imageElem = (MSIMImageElem *)data.elem;
                YBIBImageData *imageData = [YBIBImageData new];
                imageData.imageURL = [NSURL URLWithString:imageElem.url];
                imageData.projectiveView = dataCell.container.subviews.firstObject;
                [tempArr addObject:imageData];
                if (cell.messageData == data) {
                    defaultIndex = tempArr.count-1;
                }
            }
        }
        YBImageBrowser *browser = [YBImageBrowser new];
        browser.dataSourceArray = tempArr;
        browser.currentPage = defaultIndex;
        [browser show];
    }else if (cell.messageData.elem.type == BFIM_MSG_TYPE_VIDEO) {//点击视频
        
        MSIMVideoElem *videoElem = (MSIMVideoElem *)cell.messageData.elem;
        YBIBVideoData *videoData = [YBIBVideoData new];
        videoData.videoURL = [NSURL URLWithString:videoElem.videoUrl];
        videoData.projectiveView = cell.container.subviews.firstObject;
        YBImageBrowser *browser = [YBImageBrowser new];
        browser.dataSourceArray = @[videoData];
        browser.currentPage = 0;
        [browser show];
    }
}

/**
 *  显示长按菜单前的回调函数
 */
- (BOOL)messageController:(BFMessageController *)controller willShowMenuInCell:(UIView *)view
{
    if ([self.inputController.inputBar.inputTextView isFirstResponder]) {
        self.inputController.inputBar.inputTextView.overrideNextResponder = view;
        return YES;
    }
    return NO;
}

- (void)didHideMenuInMessageController:(BFMessageController *)controller
{
    self.inputController.inputBar.inputTextView.overrideNextResponder = nil;
}

@end
