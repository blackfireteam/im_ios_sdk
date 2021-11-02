//
//  MSChatViewController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/3/17.
//

#import "MSChatViewController.h"
#import "MSIMSDK-UIKit.h"
#import <MSIMSDK/MSIMSDK.h>
#import <AVFoundation/AVFoundation.h>

@interface MSChatViewController ()<MSInputViewControllerDelegate,MSMessageControllerDelegate>

@property(nonatomic,strong) MSMessageController *messageController;

@property(nonatomic,strong) MSInputViewController *inputController;

@end

@implementation MSChatViewController
{
    BOOL _textingFlag;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupViews];
}

- (void)dealloc
{
    [self saveDraft];
    MSLog(@"%@ dealloc",self.class);
}

- (void)setupViews
{
    self.messageController = [[MSMessageController alloc]init];
    self.messageController.delegate = self;
    self.messageController.partner_id = self.partner_id;
    self.messageController.view.frame = CGRectMake(0, 0, Screen_Width, Screen_Height-TTextView_Height-Bottom_SafeHeight);
    [self addChildViewController:self.messageController];
    [self.view addSubview:self.messageController.view];
    
    self.inputController = [[MSInputViewController alloc]initWithChatType:MSIM_CHAT_TYPE_C2C delegate:self];
    self.inputController.view.frame = CGRectMake(0, Screen_Height-TTextView_Height-Bottom_SafeHeight, Screen_Width, TTextView_Height+Bottom_SafeHeight);
    self.inputController.view.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self addChildViewController:self.inputController];
    [self.view addSubview:self.inputController.view];
    
    MSIMConversation *conv = [[MSConversationProvider provider]providerConversation:self.partner_id];
    if (conv.draftText.length > 0) {
        self.inputController.inputBar.inputTextView.text = conv.draftText;
        [self.inputController.inputBar.inputTextView becomeFirstResponder];
    }
}

#pragma mark - <MSInputViewControllerDelegate>

- (void)inputController:(MSInputViewController *)inputController didChangeHeight:(CGFloat)height
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

- (void)inputController:(MSInputViewController *)inputController didSendTextMessage:(NSString *)msg
{
    MSIMTextElem *textElem = [[MSIMManager sharedInstance] createTextMessage:msg];
    [self sendMessage:textElem];
    _textingFlag = NO;
}

- (void)inputController:(MSInputViewController *)inputController didSendVoiceMessage:(NSString *)filePath
{
    NSURL *url = [NSURL fileURLWithPath:filePath];
    AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    NSInteger duration = (NSInteger)CMTimeGetSeconds(audioAsset.duration);
    NSInteger length = (NSInteger)[[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] fileSize];
    
    MSIMVoiceElem *voiceElem = [[MSIMVoiceElem alloc]init];
    voiceElem.path = filePath;
    voiceElem.duration = duration;
    voiceElem.dataSize = length;
    voiceElem = [[MSIMManager sharedInstance] createVoiceMessage:voiceElem];
    [self sendMessage:voiceElem];
}

- (void)inputControllerDidInputAt:(MSInputViewController *)inputController
{
    
}

/**
 *  输入框中内容发生变化时的回调
 */
- (void)inputController:(MSInputViewController *)inputController contentDidChanged:(NSString *)text
{
    //处理正在输入消息逻辑
    //当满足以下两条规则，会发送一条正在输入的信令消息
    //1.上一条消息是对方发的消息
    //2.当前时间距离上一条消息间隔在10秒内
    MSMessageCellData *lastData = self.messageController.uiMsgs.lastObject;
    if (lastData == nil || lastData.elem.fromUid.length == 0) return;
    NSInteger diff = [MSIMTools sharedInstance].adjustLocalTimeInterval - lastData.elem.msg_sign;
    if (_textingFlag == NO && lastData.elem.isSelf == NO && diff <= 10*1000*1000) {
        NSDictionary *extDic = @{@"type": @(MSIMCustomSubTypeTexting),@"desc": @"我正在输入..."};
        MSIMCustomElem *customElem = [[MSIMManager sharedInstance] createCustomMessage:[extDic el_convertJsonString] option:IMCUSTOM_SIGNAL pushExt:nil];
        [[MSIMManager sharedInstance]sendC2CMessage:customElem toReciever:self.partner_id successed:^(NSInteger msg_id) {

            } failed:^(NSInteger code, NSString * _Nonnull desc) {

        }];
        _textingFlag = YES;
    }
}

/**
 *  有 @xxx 字符删除
 */
- (void)inputController:(MSInputViewController *)inputController didDeleteAt:(NSString *)atText
{
    
}

/// 点击拍照，照片等更多功能
- (void)inputController:(MSInputViewController *)inputController didSelectMoreCell:(MSInputMoreCell *)cell
{
    if ([self.delegate respondsToSelector:@selector(chatController:onSelectMoreCell:)]) {
        [self.delegate chatController:self onSelectMoreCell:cell];
    }
    if (cell.data.tye == MSIM_MORE_PHOTO) {//照片
        [self selectPhotoForSend];
    }else if (cell.data.tye == MSIM_MORE_VIDEO) {//视频
        [self selectVideoForSend];
    }
}

#pragma mark - <MSMessageControllerDelegate>

/**
 收到信令消息
 */
- (void)messageController:(MSMessageController *)controller onRecieveSignalMessage:(NSArray <MSIMElem *>*)elems
{
    for (MSIMElem *elem in elems) {
        if (![elem isKindOfClass:[MSIMCustomElem class]]) return;
        MSIMCustomElem *customElem = (MSIMCustomElem *)elem;
        NSDictionary *dic = [customElem.jsonStr el_convertToDictionary];
        if ([dic[@"type"]integerValue] == MSIMCustomSubTypeTexting) {//收到对方正在输入
            if ([self.delegate respondsToSelector:@selector(chatController:onRecieveTextingMessage:)]) {
                return [self.delegate chatController:self onRecieveTextingMessage:elem];
            }
            return;
        }
    }
}

/**
 *  收到新消息的函数委托
 */
- (MSMessageCellData *)messageController:(MSMessageController *)controller prepareForMessage:(MSIMElem *)data
{
    if ([self.delegate respondsToSelector:@selector(chatController:prepareForMessage:)]) {
        return [self.delegate chatController:self prepareForMessage:data];
    }
    return nil;
}

/**
 *  显示消息数据委托
 *  您可以通过该回调实现：根据传入的 data 初始化消息气泡并进行显示
 */
- (Class)messageController:(MSMessageController *)controller onShowMessageData:(MSMessageCellData *)data
{
    if ([self.delegate respondsToSelector:@selector(chatController:onShowMessageData:)]) {
        return [self.delegate chatController:self onShowMessageData:data];
    }
    return nil;
}

/**
 *  控制器点击回调
 *  您可以通过该回调实现：重置 InputControoler，收起键盘。
 */
- (void)didTapInMessageController:(MSMessageController *)controller
{
    [self.inputController reset];
}

/**
 *  点击消息头像委托
 *  您可以通过该回调实现：跳转到对应用户的详细信息界面。
 */
- (void)messageController:(MSMessageController *)controller onSelectMessageAvatar:(MSMessageCell *)cell
{
    if ([self.delegate respondsToSelector:@selector(chatController:onSelectMessageAvatar:)]) {
        [self.delegate chatController:self onSelectMessageAvatar:cell];
    }
    [self.inputController reset];
}

/**
 *  点击消息内容委托
 */
- (void)messageController:(MSMessageController *)controller onSelectMessageContent:(MSMessageCell *)cell
{
    [self.inputController reset];
    if ([self.delegate respondsToSelector:@selector(chatController:onSelectMessageContent:)]) {
        [self.delegate chatController:self onSelectMessageContent:cell];
    }
}

/**
 *  显示长按菜单前的回调函数
 */
- (BOOL)messageController:(MSMessageController *)controller willShowMenuInCell:(UIView *)view
{
    if ([self.inputController.inputBar.inputTextView isFirstResponder]) {
        self.inputController.inputBar.inputTextView.overrideNextResponder = view;
        return YES;
    }
    return NO;
}

- (void)didHideMenuInMessageController:(MSMessageController *)controller
{
    self.inputController.inputBar.inputTextView.overrideNextResponder = nil;
}

- (void)saveDraft
{
    NSString *draft = self.inputController.inputBar.inputTextView.text;
    draft = [draft stringByTrimmingCharactersInSet: NSCharacterSet.whitespaceAndNewlineCharacterSet];
    [[MSIMManager sharedInstance] setConversationDraft:self.partner_id draftText:draft succ:nil failed:nil];
}

- (void)sendMessage:(MSIMElem *)message
{
    [[MSIMManager sharedInstance] sendC2CMessage:message toReciever:self.partner_id successed:^(NSInteger msg_id) {
            
        } failed:^(NSInteger code, NSString * _Nonnull desc) {
            [MSHelper showToastFail:desc];
    }];
    if ([self.delegate respondsToSelector:@selector(chatController:didSendMessage:)]) {
        [self.delegate chatController:self didSendMessage:message];
    }
}

@end
