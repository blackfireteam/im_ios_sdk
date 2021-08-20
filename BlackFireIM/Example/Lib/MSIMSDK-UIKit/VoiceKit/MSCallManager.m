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

- (void)callToPartner:(NSString *)partner_id
              creator:(NSString *)creator
             callType:(MSCallType)callType
               action:(CallAction)action
              room_id:(nullable NSString *)room_id
{
    if (partner_id.length == 0 || creator.length == 0) return;
    NSString *channel_id = nil;
    if (room_id) {
        channel_id = room_id;
    }else {
        NSInteger currentT = [MSIMTools sharedInstance].adjustLocalTimeInterval / 1000 / 1000;
        channel_id = [NSString stringWithFormat:@"c2c_%@_%zd",[MSIMTools sharedInstance].user_id,currentT];
    }
    switch (action) {
        case CallAction_Call:
        {
            self.isOnCalling = YES;
            self.partner_id = partner_id;
            self.callType = callType;
            self.callVC = [[MSCallViewController alloc]initWithCallType:self.callType sponsor:creator invitee:partner_id room_id:channel_id];
            self.callVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:self.callVC animated:YES completion:nil];
            [self sendMessageType:CallAction_Call option:IMCUSTOM_SIGNAL room_id:channel_id];
            
            WS(weakSelf)
            [self.timer invalidate];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:60 repeats:NO block:^(NSTimer * _Nonnull timer) {
                
                /// 作为邀请方，对方60秒内无应答，结束通话。补发一条超时的普通消息
                [weakSelf.timer invalidate];
                weakSelf.timer = nil;
                [weakSelf destroyCallVC];
                [weakSelf sendMessageType:CallAction_Timeout option:IMCUSTOM_UNREADCOUNT_NO_RECALL room_id:channel_id];
            }];
            [[NSRunLoop mainRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];
        }
            break;
        case CallAction_Cancel:
        {
            if ([creator isEqualToString:[MSIMTools sharedInstance].user_id]) {
                /// 作为邀请方，取消通话，会补发一条取消通话的普通消息
                [self sendMessageType:CallAction_Cancel option:IMCUSTOM_UNREADCOUNT_NO_RECALL room_id:channel_id];
                [self.timer invalidate];
                self.timer = nil;
                [self destroyCallVC];
            }
        }
            break;
        case CallAction_Reject:
        {
            if ([creator isEqualToString:[MSIMTools sharedInstance].user_id] == NO) {
                /// 作为被邀请方，点击拒绝，结束通话。补一条拒绝的指令消息
                [self sendMessageType:CallAction_Reject option:IMCUSTOM_SIGNAL room_id:channel_id];
                [self destroyCallVC];
            }
        }
            break;
        case CallAction_End:
        {
            if ([creator isEqualToString:[MSIMTools sharedInstance].user_id]) {
                /// 自己是邀请方主动挂断，结束通话同时补发一条结束的普通消息
                [self sendMessageType:CallAction_End option:IMCUSTOM_UNREADCOUNT_NO_RECALL room_id:channel_id];
                [self destroyCallVC];
            }else {
                ///自己是被邀请方主动挂断，结束通话同时补发一条结束的指令消息
                [self sendMessageType:CallAction_End option:IMCUSTOM_SIGNAL room_id:channel_id];
                [self destroyCallVC];
            }
        }
            break;
        case CallAction_Accept:
        {
            if ([creator isEqualToString:[MSIMTools sharedInstance].user_id] == NO) {
                /// 作为被邀请方，点击接受，补一条接受的指令消息
                [self.callVC recieveAccept:callType room_id:channel_id];
                [self sendMessageType:CallAction_Accept option:IMCUSTOM_SIGNAL room_id:channel_id];
            }
        }
            break;
        default:
            break;
    }
}

- (void)recieveCall:(NSString *)from
            creator:(NSString *)creator
           callType:(MSCallType)callType
             action:(CallAction)action
            room_id:(nullable NSString *)room_id
{
    if (from.length == 0 || [from isEqualToString:[MSIMTools sharedInstance].user_id] || creator.length == 0) return;
    NSString *channel_id = nil;
    if (room_id) {
        channel_id = room_id;
    }else {
        NSInteger currentT = [MSIMTools sharedInstance].adjustLocalTimeInterval / 1000 / 1000;
        channel_id = [NSString stringWithFormat:@"c2c_%@_%zd",from,currentT];
    }
    switch (action) {
        case CallAction_Call:
        {
            if (self.isOnCalling) {
                /// 如果正与某人聊天，收到另一邀请指令，会给对方回一条正忙的指令消息
                [self sendMessageType:CallAction_Linebusy option:IMCUSTOM_SIGNAL room_id:channel_id];
                return;
            }
            self.isOnCalling = YES;
            self.partner_id = from;
            self.callType = callType;
            self.callVC = [[MSCallViewController alloc]initWithCallType:self.callType sponsor:from invitee:[MSIMTools sharedInstance].user_id room_id:channel_id];
            self.callVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:self.callVC animated:YES completion:nil];
        }
            break;
        case CallAction_Cancel:
        {
            if ([creator isEqualToString:[MSIMTools sharedInstance].user_id] == NO) {
                /// 作为被邀请方收到对方取消通话消息，结束通话
                [self destroyCallVC];
            }
        }
            break;
        case CallAction_Timeout:
        {
            if ([creator isEqualToString:[MSIMTools sharedInstance].user_id] == NO) {
                /// 作为被邀请方，收到对方超时消息，结束通话
                [self destroyCallVC];
            }
        }
            break;
        case CallAction_Reject:
        {
            if ([creator isEqualToString:[MSIMTools sharedInstance].user_id]) {
                /// 作为邀请方，收到对方的拒绝指令，结束通话，同时补一条拒绝的普通消息
                [self.timer invalidate];
                self.timer = nil;
                [self destroyCallVC];
                [self sendMessageType:CallAction_Reject option:IMCUSTOM_UNREADCOUNT_NO_RECALL room_id:channel_id];
            }
        }
            break;
        case CallAction_End:
        {
            if ([creator isEqualToString:[MSIMTools sharedInstance].user_id]) {
                /// 作为邀请方，收到对方挂断指令，会结束通话。同时发一条结束的普通消息
                [self sendMessageType:CallAction_End option:IMCUSTOM_UNREADCOUNT_NO_RECALL room_id:channel_id];
                [self destroyCallVC];
            }else {
                /// 作为被邀请方，收到对方挂断的消息，会结束通话
                [self.callVC recieveHangup:callType room_id:channel_id];
                [self destroyCallVC];
            }
        }
            break;
        case CallAction_Linebusy:
        {
            if ([creator isEqualToString:[MSIMTools sharedInstance].user_id]) {
                /// 作为邀请方，收到一条对方正忙的指令，我会结束通话，同时补发一条对方正忙的普通消息
                [self.timer invalidate];
                self.timer = nil;
                [self destroyCallVC];
                [self sendMessageType:CallAction_Linebusy option:IMCUSTOM_UNREADCOUNT_NO_RECALL room_id:channel_id];
            }
        }
            break;
        case CallAction_Accept:
        {
            if ([creator isEqualToString:[MSIMTools sharedInstance].user_id]) {
                /// 作为邀请方收到对方接受的指令消息
                [self.timer invalidate];
                self.timer = nil;
                [self.callVC recieveAccept:callType room_id:channel_id];
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

- (void)sendMessageType:(CallAction)action option:(MSIMCustomOption)option room_id:(NSString *)room_id
{
    NSDictionary *extDic = @{@"room_id": room_id,@"type": @(self.callType == MSCallType_Voice ? MSIMCustomSubTypeVoiceCall : MSIMCustomSubTypeVideoCall),@"event":@(action),@"duration": @(self.callVC.duration)};
    MSIMPushInfo *push;
    if (action == CallAction_Timeout || action == CallAction_Cancel) {
        NSString *attachExt = self.callType == MSCallType_Voice ? @"[Voice call]" : @"[Video call]";
        push = [[MSIMPushInfo alloc]init];
        push.body = [NSString stringWithFormat:@"%@ Call cancelled by caller",attachExt];
        push.sound = @"default";
    }else if (action == CallAction_Call) {
        NSString *attachExt = self.callType == MSCallType_Voice ? @"[Voice call]" : @"[Video call]";
        push = [[MSIMPushInfo alloc]init];
        push.body = [NSString stringWithFormat:@"%@ Start Call",attachExt];
        push.sound = (self.callType == MSCallType_Voice ? @"00.caf" : @"call.caf");
    }else if (action == CallAction_Linebusy || action == CallAction_End) {
        if (option != IMCUSTOM_SIGNAL) {
            NSString *attachExt = self.callType == MSCallType_Voice ? @"[Voice call]" : @"[Video call]";
            push = [[MSIMPushInfo alloc]init];
            push.body = [NSString stringWithFormat:@"%@ Duration: %02zd:%02zd",attachExt,self.callVC.duration/60,self.callVC.duration%60];
            push.sound = @"default";
        }
    }else if (action == CallAction_Reject && option != IMCUSTOM_SIGNAL) {
        NSString *attachExt = self.callType == MSCallType_Voice ? @"[Voice call]" : @"[Video call]";
        push = [[MSIMPushInfo alloc]init];
        push.body = [NSString stringWithFormat:@"%@ Call declined by user",attachExt];
        push.sound = @"default";
    }
    MSIMCustomElem *custom = [[MSIMManager sharedInstance]createCustomMessage:[extDic el_convertJsonString] option:option pushExt:push];
    [[MSIMManager sharedInstance]sendC2CMessage:custom toReciever:self.partner_id successed:^(NSInteger msg_id) {
        
            } failed:^(NSInteger code, NSString *desc) {
                MSLog(@"%@",desc);
    }];
}


/// 根据自定义参数解析出消息中展示的内容
+ (NSString *)parseToMessageShow:(NSDictionary *)customParams callType:(MSCallType)callType isSelf:(BOOL)isSelf
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
        case CallAction_Linebusy:
            return isSelf ? TUILocalizableString(TUIKitSignalingCallBusy) : TUILocalizableString(TUIKitSignalingCallBusyOther);
        case CallAction_Timeout:
            return isSelf ? TUILocalizableString(TUIKitSignalingNoResponseOther) : TUILocalizableString(TUIKitSignalingNoResponse);
        case CallAction_Cancel:
            return isSelf ? TUILocalizableString(TUIkitSignalingCancelCall) : TUILocalizableString(TUIkitSignalingCancelCallOther);
        case CallAction_Reject:
            return isSelf ? TUILocalizableString(TUIkitSignalingDeclineOther) : TUILocalizableString(TUIkitSignalingDecline);
        default:
            return TUILocalizableString(TUIkitMessageTipsUnknowMessage);
    }
}

/// 根据自定义参数解析出在会话中展示的内容
+ (NSString *)parseToConversationShow:(NSDictionary *)customParams callType:(MSCallType)callType isSelf:(BOOL)isSelf
{
    NSString *desc = [self parseToMessageShow:customParams callType:callType isSelf:isSelf];
    if (callType == MSCallType_Voice) {
        return [NSString stringWithFormat:@"%@ %@",TUILocalizableString(TUIkitMessageTypeVoiceCall),desc];
    }else {
        return [NSString stringWithFormat:@"%@ %@",TUILocalizableString(TUIkitMessageTypeVideoCall),desc];
    }
}

+ (NSString *)getCreatorFrom:(NSString *)room_id
{
    NSArray *arr = [room_id componentsSeparatedByString:@"_"];
    if (arr.count == 3) {
        return arr[1];
    }
    return @"";
}

@end
