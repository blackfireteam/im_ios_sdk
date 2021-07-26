//
//  MSCallManager.m
//  BlackFireIM
//
//  Created by benny wang on 2021/7/20.
//

#import "MSCallManager.h"
#import "MSCallViewController.h"
#import "MSIMSDK-UIKit.h"

@interface MSCallManager()

@property(nonatomic,assign) BOOL isOnCalling;

@property(nonatomic,strong) MSCallViewController *callVC;

@property(nonatomic,copy) NSString *partner_id;

@property(nonatomic,assign) CallAction action;

@property(nonatomic,assign) MSCallType callType;

@property(nonatomic,strong) NSTimer *timer;

@end
@implementation MSCallManager

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    static MSCallManager * g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[MSCallManager alloc] init];
    });
    return g_sharedInstance;
}

- (void)call:(NSString *)from toUser:(NSString *)toUid callType:(MSCallType)callType action:(CallAction)action
{
    if (from.length == 0 || toUid.length == 0) return;
    _action = action;
    _callType = callType;
    BOOL isMe = [from isEqualToString:[MSIMTools sharedInstance].user_id];
    switch (action) {
        case CallAction_Call://邀请方发起请求
        {
            if (self.isOnCalling) return;
            self.isOnCalling = YES;
            self.partner_id = isMe ? toUid : from;
            self.callVC = [[MSCallViewController alloc]initWithCallType:self.callType sponsor:from invitee:toUid];
            self.callVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:self.callVC animated:YES completion:nil];
            if (isMe) {
                [self sendInviteMessage];
                /// 60秒内对方无应答，自动结束
                [self.timer invalidate];
                self.timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(requestOnlineCallTimeOut) userInfo:nil repeats:NO];
                [[NSRunLoop mainRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];
            }
        }
            break;
        case CallAction_Cancel://邀请方取消请求
        {
            if (isMe) {
                [self sendCancelMessage];
                [self.timer invalidate];
                self.timer = nil;
                [self destroyCallVC];
            }else {
                [self.callVC recieveCancel:callType];
                [self destroyCallVC];
            }
        }
            break;
        case CallAction_Reject://被邀请方拒绝邀请
        {
            if (isMe) {
                [self sendRejectMessage];
                [self destroyCallVC];
            }else {
                [self.callVC recieveReject:callType];
                [self destroyCallVC];
            }
        }
            break;
        case CallAction_Timeout://被邀请方超时未响应
        {
            if (isMe) {
                [self sendCancelMessage];
                [self.timer invalidate];
                self.timer = nil;
                [self destroyCallVC];
            }
        }
            break;
        case CallAction_End://通话中断
        {
            if (isMe) {
                [self sendStopMessage];
                [self destroyCallVC];
            }else {
                [self.callVC recieveHangup:callType];
                [self destroyCallVC];
            }
        }
            break;
        case CallAction_Linebusy://被邀请方正忙
        {
            [MSHelper showToastString:@"the other is busy"];
        }
            break;
        case CallAction_Accept://被邀请方接受邀请
        {
            if (isMe) {
                [self sendAcceptMessage];
            }else {
                [self.timer invalidate];
                self.timer = nil;
                [self.callVC recieveAccept:callType];
            }
        }
            break;
        default:
            break;
    }
}

- (void)destroyCallVC
{
    if (self.callVC) {
        [UIDevice stopPlaySystemSound];
        [self.callVC dismissViewControllerAnimated:YES completion:nil];
        self.callVC = nil;
        self.isOnCalling = NO;
        self.action = CallAction_Unknown;
    }
}

- (void)requestOnlineCallTimeOut
{
    [self call:[MSIMTools sharedInstance].user_id toUser:self.partner_id callType:self.callType action:CallAction_Timeout];
}

- (void)sendInviteMessage
{
    NSString *attachExt = self.callType == MSCallType_Voice ? @"[Voice call]" : @"[Video call]";
    NSDictionary *extDic = @{@"type": @(self.callType == MSCallType_Voice ? MSIMCustomSubTypeVoiceCall : MSIMCustomSubTypeVideoCall),@"event":@(CallAction_Call)};
    MSIMPushInfo *push = [[MSIMPushInfo alloc]init];
    push.body = [NSString stringWithFormat:@"%@ Start Call",attachExt];
    push.sound = @"00.caf";
    MSIMCustomElem *custom = [[MSIMManager sharedInstance]createCustomMessage:[extDic el_convertJsonString] option:IMCUSTOM_SIGNAL pushExt:push];
    [[MSIMManager sharedInstance]sendC2CMessage:custom toReciever:self.partner_id successed:^(NSInteger msg_id) {
        
            } failed:^(NSInteger code, NSString *desc) {
                MSLog(@"%@",desc);
    }];
}

- (void)sendStopMessage
{
    NSString *attachExt = self.callType == MSCallType_Voice ? @"[Voice call]" : @"[Video call]";
    NSDictionary *extDic = @{@"type": @(self.callType == MSCallType_Voice ? MSIMCustomSubTypeVoiceCall : MSIMCustomSubTypeVideoCall),@"event":@(CallAction_End),@"duration": @(self.callVC.duration)};
    MSIMPushInfo *push = [[MSIMPushInfo alloc]init];
    push.body = [NSString stringWithFormat:@"%@ Duration: %02zd:%02zd",attachExt,self.callVC.duration/60,self.callVC.duration%60];
    push.sound = @"default";
    MSIMCustomElem *custom = [[MSIMManager sharedInstance]createCustomMessage:[extDic el_convertJsonString] option:IMCUSTOM_UNREADCOUNT_NO_RECALL pushExt:push];
    [[MSIMManager sharedInstance]sendC2CMessage:custom toReciever:self.partner_id successed:^(NSInteger msg_id) {
        
            } failed:^(NSInteger code, NSString *desc) {
                MSLog(@"%@",desc);
    }];
}

- (void)sendCancelMessage
{
    NSString *attachExt = self.callType == MSCallType_Voice ? @"[Voice call]" : @"[Video call]";
    NSDictionary *extDic = @{@"type": @(self.callType == MSCallType_Voice ? MSIMCustomSubTypeVoiceCall : MSIMCustomSubTypeVideoCall),@"event":@(CallAction_Cancel)};
    MSIMPushInfo *push = [[MSIMPushInfo alloc]init];
    push.body = [NSString stringWithFormat:@"%@ Call cancelled by caller",attachExt];
    push.sound = @"default";
    MSIMCustomElem *custom = [[MSIMManager sharedInstance]createCustomMessage:[extDic el_convertJsonString] option:IMCUSTOM_UNREADCOUNT_NO_RECALL pushExt:push];
    [[MSIMManager sharedInstance]sendC2CMessage:custom toReciever:self.partner_id successed:^(NSInteger msg_id) {
        
            } failed:^(NSInteger code, NSString *desc) {
                MSLog(@"%@",desc);
    }];
}

- (void)sendRejectMessage
{
    NSString *attachExt = self.callType == MSCallType_Voice ? @"[Voice call]" : @"[Video call]";
    NSDictionary *extDic = @{@"type": @(self.callType == MSCallType_Voice ? MSIMCustomSubTypeVoiceCall : MSIMCustomSubTypeVideoCall),@"event":@(CallAction_Reject)};
    MSIMPushInfo *push = [[MSIMPushInfo alloc]init];
    push.body = [NSString stringWithFormat:@"%@ Call declined by user",attachExt];
    push.sound = @"default";
    MSIMCustomElem *custom = [[MSIMManager sharedInstance]createCustomMessage:[extDic el_convertJsonString] option:IMCUSTOM_UNREADCOUNT_NO_RECALL pushExt:push];
    [[MSIMManager sharedInstance]sendC2CMessage:custom toReciever:self.partner_id successed:^(NSInteger msg_id) {
        
            } failed:^(NSInteger code, NSString *desc) {
                MSLog(@"%@",desc);
    }];
}

- (void)sendAcceptMessage
{
    NSString *attachExt = self.callType == MSCallType_Voice ? @"[Voice call]" : @"[Video call]";
    NSDictionary *extDic = @{@"type": @(self.callType == MSCallType_Voice ? MSIMCustomSubTypeVoiceCall : MSIMCustomSubTypeVideoCall),@"event":@(CallAction_Accept)};
    MSIMPushInfo *push = [[MSIMPushInfo alloc]init];
    push.body = [NSString stringWithFormat:@"%@ accept call",attachExt];
    push.sound = @"default";
    MSIMCustomElem *custom = [[MSIMManager sharedInstance]createCustomMessage:[extDic el_convertJsonString] option:IMCUSTOM_SIGNAL pushExt:push];
    [[MSIMManager sharedInstance]sendC2CMessage:custom toReciever:self.partner_id successed:^(NSInteger msg_id) {
        
            } failed:^(NSInteger code, NSString *desc) {
                MSLog(@"%@",desc);
    }];
}

/// 根据自定义参数解析出消息中展示的内容
+ (NSString *)parseToMessageShow:(NSDictionary *)customParams callType:(MSCallType)callType
{
    CallAction action = [customParams[@"event"] integerValue];
    switch (action) {
        case CallAction_End:
        {
            NSInteger duration = [customParams[@"duration"] integerValue];
            if (callType == MSCallType_Voice) {
                return [NSString stringWithFormat:TUILocalizableString(TUIKitSignalingVoiceCallEnd),duration/60,duration%60];
            }else {
                return [NSString stringWithFormat:TUILocalizableString(TUIKitSignalingVideoCallEnd),duration/60,duration%60];
            }
        }
        case CallAction_Cancel:
            return TUILocalizableString(TUIkitSignalingCancelCall);
        case CallAction_Reject:
            return TUILocalizableString(TUIkitSignalingDecline);
        default:
            return TUILocalizableString(TUIkitMessageTipsUnknowMessage);
    }
}

/// 根据自定义参数解析出在会话中展示的内容
+ (NSString *)parseToConversationShow:(NSDictionary *)customParams callType:(MSCallType)callType
{
    CallAction action = [customParams[@"event"] integerValue];
    switch (action) {
        case CallAction_End:
        {
            NSInteger duration = [customParams[@"duration"] integerValue];
            if (callType == MSCallType_Voice) {
                NSString *desc = [NSString stringWithFormat:TUILocalizableString(TUIKitSignalingVoiceCallEnd),duration/60,duration%60];
                return [NSString stringWithFormat:@"%@ %@",TUILocalizableString(TUIkitMessageTypeVoiceCall),desc];
            }else {
                NSString *desc = [NSString stringWithFormat:TUILocalizableString(TUIKitSignalingVideoCallEnd),duration/60,duration%60];
                return [NSString stringWithFormat:@"%@ %@",TUILocalizableString(TUIkitMessageTypeVideoCall),desc];
            }
        }
        case CallAction_Cancel:
            if (callType == MSCallType_Voice) {
                return [NSString stringWithFormat:@"%@ %@",TUILocalizableString(TUIkitMessageTypeVoiceCall),TUILocalizableString(TUIkitSignalingCancelCall)];
            }else {
                return [NSString stringWithFormat:@"%@ %@",TUILocalizableString(TUIkitMessageTypeVideoCall),TUILocalizableString(TUIkitSignalingCancelCall)];
            }
        case CallAction_Reject:
            if (callType == MSCallType_Voice) {
                return [NSString stringWithFormat:@"%@ %@",TUILocalizableString(TUIkitMessageTypeVoiceCall),TUILocalizableString(TUIkitSignalingDecline)];
            }else {
                return [NSString stringWithFormat:@"%@ %@",TUILocalizableString(TUIkitMessageTypeVideoCall),TUILocalizableString(TUIkitSignalingDecline)];
            }
        default:
            return TUILocalizableString(TUIkitMessageTipsUnknowMessage);
    }
}

@end
