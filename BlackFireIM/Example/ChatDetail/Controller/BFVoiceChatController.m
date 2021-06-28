//
//  BFVoiceChatController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/6/27.
//

#import "BFVoiceChatController.h"
#import "MSIMSDK-UIKit.h"
#import <MSIMSDK/MSIMSDK.h>

@interface BFVoiceChatController ()

@property(nonatomic,copy) NSString *partner_id;

@property(nonatomic,strong) UIButton *beginBtn;

@property(nonatomic,strong) UIButton *stopBtn;

@property(nonatomic,strong) NSTimer *timer;

@end

@implementation BFVoiceChatController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor orangeColor];
    self.stopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.stopBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self.stopBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.stopBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.stopBtn addTarget:self action:@selector(stopBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    self.stopBtn.frame = CGRectMake(Screen_Width*0.5-30, Screen_Height-130-40, 60, 40);
    [self.view addSubview:self.stopBtn];

    self.timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(requestOnlineVoiceTimeOut) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];
    WS(weakSelf)
    [[NSNotificationCenter defaultCenter] addObserverForName:MSUIKitNotification_MessageListener object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
       [weakSelf onNewMessage:note];
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.timer invalidate];
    self.timer = nil;
}

- (void)showWithPartner_id:(NSString *)partner_id bySelf:(BOOL)isSelf
{
    _partner_id = partner_id;
    self.beginBtn.hidden = YES;
    self.stopBtn.hidden = NO;
    if (isSelf) {
        [self sendBeginMessage];
    }
}

- (void)dismissBySelf:(BOOL)isSelf
{
    [self.timer invalidate];
    self.timer = nil;
    self.beginBtn.hidden = NO;
    self.stopBtn.hidden = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
    if (isSelf) {
        [self sendStopMessage];
    }
    [UIDevice stopPlaySystemSound];
}

- (void)stopBtnDidClick
{
    [self dismissBySelf:YES];
}

- (void)sendBeginMessage
{
    NSDictionary *extDic = @{@"type": @(100),@"desc": @"请求开始语音聊天"};
    MSIMPushInfo *push = [[MSIMPushInfo alloc]init];
    push.body = @"正在邀请与您语音聊天";
    push.sound = @"00.caf";
    MSIMCustomElem *custom = [[MSIMManager sharedInstance]createCustomMessage:[extDic el_convertJsonString] option:IMCUSTOM_SIGNAL pushExt:push];
    [[MSIMManager sharedInstance]sendC2CMessage:custom toReciever:self.partner_id successed:^(NSInteger msg_id) {
        [MSHelper showToastSucc:@"邀请已发送"];
            } failed:^(NSInteger code, NSString *desc) {
                MSLog(@"%@",desc);
    }];
}

- (void)sendStopMessage
{
    NSDictionary *extDic = @{@"type": @(101),@"desc": @"语音聊天已结束"};
    MSIMPushInfo *push = [[MSIMPushInfo alloc]init];
    push.body = @"语音聊天已结束";
    push.sound = @"default";
    MSIMCustomElem *custom = [[MSIMManager sharedInstance]createCustomMessage:[extDic el_convertJsonString] option:IMCUSTOM_UNREADCOUNT_NO_RECALL pushExt:push];
    [[MSIMManager sharedInstance]sendC2CMessage:custom toReciever:self.partner_id successed:^(NSInteger msg_id) {
        
            } failed:^(NSInteger code, NSString *desc) {
                MSLog(@"%@",desc);
    }];
}

- (void)requestOnlineVoiceTimeOut
{
    [self dismissBySelf:YES];
}

///收到新消息
- (void)onNewMessage:(NSNotification *)note
{
    NSArray *elems = note.object;
    for (MSIMElem *elem in elems) {
        if ([elem isKindOfClass:[MSIMCustomElem class]]) {
            MSIMCustomElem *customElem = (MSIMCustomElem *)elem;
            NSDictionary *dic = [customElem.jsonStr el_convertToDictionary];
            if(customElem.type == IMCUSTOM_UNREADCOUNT_NO_RECALL) {
                if ([dic[@"type"]integerValue] == 101 && ![customElem.fromUid isEqualToString:[MSIMTools sharedInstance].user_id]) {//收到语音聊天结束时
                    [self dismissBySelf:NO];
                    return;
                }
            }
        }
    }
}

@end
