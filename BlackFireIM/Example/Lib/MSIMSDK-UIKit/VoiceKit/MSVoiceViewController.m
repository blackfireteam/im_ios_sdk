//
//  MSVoiceViewController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/7/20.
//

#import "MSVoiceViewController.h"
#import <AgoraRtcKit/AgoraRtcEngineKit.h>
#import "MSIMSDK-UIKit.h"
#import <MSIMSDK/MSIMSDK.h>
#import <SDWebImage.h>
#import "MSCallModel.h"
#import "MSCallManager.h"

@interface MSVoiceViewController ()<AgoraRtcEngineDelegate>

@property(nonatomic,strong) AgoraRtcEngineKit *agoraKit;

@property(nonatomic,copy) NSString *partner_id;

@property(nonatomic,assign) AudioCallState curState;

@property(nonatomic,strong) UIImageView *bgIcon;

@property(nonatomic,strong) UIImageView *avatarIcon;

@property(nonatomic,strong) UILabel *nickNamekL;

@property(nonatomic,strong) UILabel *noticeL;

@property(nonatomic,strong) UIButton *micBtn;

@property(nonatomic,strong) UIButton *cancelBtn;

@property(nonatomic,strong) UIButton *hangupBtn;

@property(nonatomic,strong) UIButton *handFreeBtn;

@property(nonatomic,strong) UIButton *rejectBtn;

@property(nonatomic,strong) UIButton *acceptBtn;

@property(nonatomic,strong) UILabel *durationL;

@property(nonatomic,strong) NSTimer *durationTimer;

@property(nonatomic,assign) NSInteger duration;

@end

@implementation MSVoiceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
    [self initData];
    if (self.curState == AudioCallState_Dailing) {
        [self initializeAgoraEngine];
//        [self.agoraKit startEchoTestWithInterval:10 successBlock:^(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed) {
//
//            MSLog(@"%@",channel);
//        }];
        [self joinChannel];
    }
}

- (instancetype)initWithSponsor:(NSString *)sponsor invitee:(NSString *)invitee
{
    if (self = [super init]) {
        if (sponsor && [sponsor isEqualToString:[MSIMTools sharedInstance].user_id]) {
            _partner_id = invitee;
            _curState = AudioCallState_Dailing;
        }else {
            _partner_id = sponsor;
            _curState = AudioCallState_OnInvitee;
        }
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self playAlerm];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self stopVoice];
}

- (void)dealloc
{
    MSLog(@"%@ dealloc",self.class);
}

- (void)initData
{
    BOOL isSponsor = (self.curState == AudioCallState_Dailing);
    [[MSProfileProvider provider]providerProfile:self.partner_id complete:^(MSProfileInfo * _Nullable profile) {
        if (profile) {
            [self.bgIcon sd_setImageWithURL:[NSURL URLWithString:profile.avatar]];
            [self.avatarIcon sd_setImageWithURL:[NSURL URLWithString:profile.avatar]];
            self.nickNamekL.text = profile.nick_name;
        }
    }];
    self.noticeL.text = isSponsor ? TUILocalizableString(TUIKitCallWaitingForAccept) : TUILocalizableString(TUIKitCallInviteYouVoiceCall);
    self.cancelBtn.hidden = !isSponsor;
    self.micBtn.hidden = !isSponsor;
    self.micBtn.selected = YES;
    self.handFreeBtn.hidden = !isSponsor;
    self.handFreeBtn.selected = NO;
    self.rejectBtn.hidden = isSponsor;
    self.acceptBtn.hidden = isSponsor;
    self.durationL.hidden = YES;
    self.hangupBtn.hidden = YES;
}

- (void)setupUI
{
    self.view.backgroundColor = [UIColor blackColor];
    self.bgIcon = [[UIImageView alloc]initWithFrame:UIScreen.mainScreen.bounds];
    self.bgIcon.contentMode = UIViewContentModeScaleAspectFill;
    self.bgIcon.clipsToBounds = YES;
    self.bgIcon.userInteractionEnabled = YES;
    [self.view addSubview:self.bgIcon];
    
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:effect];
    effectView.frame = self.bgIcon.bounds;
    [self.bgIcon addSubview:effectView];
    
    self.avatarIcon = [[UIImageView alloc]initWithFrame:CGRectMake(Screen_Width*0.5-60, Screen_Height*0.5-100-60, 120, 120)];
    self.avatarIcon.layer.cornerRadius = 4;
    self.avatarIcon.layer.masksToBounds = YES;
    self.avatarIcon.contentMode = UIViewContentModeScaleAspectFill;
    [self.bgIcon addSubview:self.avatarIcon];
    
    self.durationL = [[UILabel alloc]initWithFrame:CGRectMake(Screen_Width*0.5-50, self.avatarIcon.y-50, 100, 20)];
    self.durationL.textColor = [UIColor whiteColor];
    self.durationL.font = [UIFont systemFontOfSize:16];
    self.durationL.textAlignment = NSTextAlignmentCenter;
    [self.bgIcon addSubview:self.durationL];
    
    self.nickNamekL = [[UILabel alloc]initWithFrame:CGRectMake(Screen_Width*0.5-50, self.avatarIcon.maxY+15, 100, 35)];
    self.nickNamekL.font = [UIFont boldSystemFontOfSize:20];
    self.nickNamekL.textColor = [UIColor whiteColor];
    self.nickNamekL.textAlignment = NSTextAlignmentCenter;
    [self.bgIcon addSubview:self.nickNamekL];
    
    self.noticeL = [[UILabel alloc]initWithFrame:CGRectMake(Screen_Width*0.5-100, self.nickNamekL.maxY+20, 200, 20)];
    self.noticeL.font = [UIFont systemFontOfSize:14];
    self.noticeL.textColor = [UIColor lightGrayColor];
    self.noticeL.textAlignment = NSTextAlignmentCenter;
    [self.bgIcon addSubview:self.noticeL];
    
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cancelBtn setTitle:TUILocalizableString(Cancel) forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.cancelBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.cancelBtn setImage:[UIImage imageNamed:TUIKitResource(@"ic_hangup")] forState:UIControlStateNormal];
    [self.cancelBtn addTarget:self action:@selector(cancelBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    self.cancelBtn.frame = CGRectMake(Screen_Width*0.5-42, Screen_Height-Bottom_SafeHeight-30-114, 84, 114);
    [self.bgIcon addSubview:self.cancelBtn];
    [self.cancelBtn verticalImageAndTitle:15];
    
    self.hangupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.hangupBtn setTitle:TUILocalizableString(TUIKitCallCancel) forState:UIControlStateNormal];
    [self.hangupBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.hangupBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.hangupBtn setImage:[UIImage imageNamed:TUIKitResource(@"ic_hangup")] forState:UIControlStateNormal];
    [self.hangupBtn addTarget:self action:@selector(hangupBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    self.hangupBtn.frame = CGRectMake(Screen_Width*0.5-42, Screen_Height-Bottom_SafeHeight-30-114, 84, 114);
    [self.bgIcon addSubview:self.hangupBtn];
    [self.hangupBtn verticalImageAndTitle:15];
    
    self.micBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.micBtn setTitle:TUILocalizableString(TUIKitCallTurningOffMute) forState:UIControlStateNormal];
    [self.micBtn setTitle:TUILocalizableString(TUIKitCallTurningOnMute) forState:UIControlStateSelected];
    [self.micBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.micBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.micBtn setImage:[UIImage imageNamed:TUIKitResource(@"ic_mute")] forState:UIControlStateNormal];
    [self.micBtn setImage:[UIImage imageNamed:TUIKitResource(@"ic_mute_on")] forState:UIControlStateSelected];
    [self.micBtn addTarget:self action:@selector(mickBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    self.micBtn.frame = CGRectMake(self.cancelBtn.x-25-self.cancelBtn.width, self.cancelBtn.y, self.cancelBtn.width, self.cancelBtn.height);
    [self.bgIcon addSubview:self.micBtn];
    [self.micBtn verticalImageAndTitle:15];
    
    self.handFreeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.handFreeBtn setTitle:TUILocalizableString(TUIKitCallUsingHeadphone) forState:UIControlStateNormal];
    [self.handFreeBtn setTitle:TUILocalizableString(TUIKitCallUsingSpeaker) forState:UIControlStateSelected];
    [self.handFreeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.handFreeBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.handFreeBtn setImage:[UIImage imageNamed:TUIKitResource(@"ic_handsfree")] forState:UIControlStateNormal];
    [self.handFreeBtn setImage:[UIImage imageNamed:TUIKitResource(@"ic_handsfree_on")] forState:UIControlStateSelected];
    [self.handFreeBtn addTarget:self action:@selector(handFreeBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    self.handFreeBtn.frame = CGRectMake(self.cancelBtn.maxX+25, self.cancelBtn.y, self.cancelBtn.width, self.cancelBtn.height);
    [self.bgIcon addSubview:self.handFreeBtn];
    [self.handFreeBtn verticalImageAndTitle:15];
    
    self.rejectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.rejectBtn setTitle:TUILocalizableString(TUIKitCallReject) forState:UIControlStateNormal];
    [self.rejectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.rejectBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.rejectBtn setImage:[UIImage imageNamed:TUIKitResource(@"ic_hangup")] forState:UIControlStateNormal];
    [self.rejectBtn addTarget:self action:@selector(rejectBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    self.rejectBtn.frame = CGRectMake(Screen_Width*0.5-self.cancelBtn.width-30, self.cancelBtn.y, self.cancelBtn.width, self.cancelBtn.height);
    [self.bgIcon addSubview:self.rejectBtn];
    [self.rejectBtn verticalImageAndTitle:15];

    self.acceptBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.acceptBtn setTitle:TUILocalizableString(TUIKitCallAccept) forState:UIControlStateNormal];
    [self.acceptBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.acceptBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.acceptBtn setImage:[UIImage imageNamed:TUIKitResource(@"ic_dialing")] forState:UIControlStateNormal];
    [self.acceptBtn addTarget:self action:@selector(acceptBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    self.acceptBtn.frame = CGRectMake(Screen_Width*0.5+30, self.rejectBtn.y, self.cancelBtn.width, self.cancelBtn.height);
    [self.bgIcon addSubview:self.acceptBtn];
    [self.acceptBtn verticalImageAndTitle:15];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

/// 对方同意通话
- (void)recieveAccept
{
    self.cancelBtn.hidden = YES;
    self.hangupBtn.hidden = NO;
    self.curState = AudioCallState_Calling;
    self.noticeL.hidden = YES;
    [self startDurationTimer];
}

/// 对方拒绝通话
- (void)recieveReject
{
    self.noticeL.hidden = YES;
}

/// 对方挂断了通话
- (void)recieveHangup
{
    [self stopDurationTimer];
}

/// 对方取消了通话
- (void)recieveCancel
{
    self.noticeL.hidden = YES;
}

#pragma mark -timer

- (void)startDurationTimer
{
    self.durationL.hidden = NO;
    [self.durationTimer invalidate];
    self.durationTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(callDuration) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop]addTimer:self.durationTimer forMode:NSRunLoopCommonModes];
}

- (void)stopDurationTimer
{
    [self.durationTimer invalidate];
    self.durationTimer = nil;
}

- (void)callDuration
{
    self.duration++;
    self.durationL.text = [NSString stringWithFormat:@"%02zd : %02zd",self.duration/60,self.duration%60];
}

#pragma mark - 响铃

- (void)playAlerm
{
//    [UIDevice playShortSound:@"00" soundExtension:@"caf"];
}


#pragma mark - btn event

- (void)cancelBtnDidClick:(UIButton *)sender
{
    [[MSCallManager shareInstance] call:[MSIMTools sharedInstance].user_id toUser:self.partner_id action:CallAction_Cancel];
}

- (void)mickBtnDidClick:(UIButton *)sender
{
    self.micBtn.selected = !self.micBtn.selected;
    if (self.micBtn.isSelected) {
        [self.agoraKit adjustRecordingSignalVolume:100];
    }else {
        [self.agoraKit adjustRecordingSignalVolume: 0];
    }
}

- (void)handFreeBtnDidClick:(UIButton *)sender
{
    self.handFreeBtn.selected = !self.handFreeBtn.selected;
    [self.agoraKit setEnableSpeakerphone:self.handFreeBtn.isSelected];
}

- (void)rejectBtnDidClick:(UIButton *)sender
{
    [[MSCallManager shareInstance] call:[MSIMTools sharedInstance].user_id toUser:self.partner_id action:CallAction_Reject];
    [self stopDurationTimer];
}

- (void)acceptBtnDidClick:(UIButton *)sender
{
    [[MSCallManager shareInstance] call:[MSIMTools sharedInstance].user_id toUser:self.partner_id action:CallAction_Accept];
    self.rejectBtn.hidden = YES;
    self.acceptBtn.hidden = YES;
    self.micBtn.hidden = NO;
    self.handFreeBtn.hidden = NO;
    self.hangupBtn.hidden = NO;
    self.cancelBtn.hidden = YES;
    self.noticeL.hidden = YES;
    [self startDurationTimer];
    self.curState = AudioCallState_Calling;
    [self initializeAgoraEngine];
    [self joinChannel];
}

- (void)hangupBtnDidClick:(UIButton *)sender
{
    [[MSCallManager shareInstance] call:[MSIMTools sharedInstance].user_id toUser:self.partner_id action:CallAction_End];
    [self stopDurationTimer];
}



- (void)initializeAgoraEngine
{
    /// 初始化 AgoraRtcEngineKit 对象
    self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:@"1a3bdfc8f46b4060bed01d15b75a5ed9" delegate:self];
}

- (void)joinChannel
{
    [self.agoraKit joinChannelByToken:@"0061a3bdfc8f46b4060bed01d15b75a5ed9IABXjFY7CBBOgGh/Xqfqt3V6v3wrVmB0SLtCMsSYjweaYj1Ra00AAAAAEAAM2hL3gG36YAEAAQB/bfpg" channelId:@"111" info:nil uid:0 joinSuccess:nil];
    [self.agoraKit enableInEarMonitoring:YES];//开启耳返
}

///根据场景需要，如结束通话、关闭 app 或 app 切换至后台时，调用 leaveChannel 离开当前通话频道。
- (void)stopVoice
{
    [self.agoraKit leaveChannel:nil];
    [AgoraRtcEngineKit destroy];
}

#pragma mark - AgoraRtcEngineDelegate
- (void)rtcEngine:(AgoraRtcEngineKit* _Nonnull)engine didOccurWarning:(AgoraWarningCode)warningCode
{
    MSLog(@"didOccurWarning == %zd",warningCode);
}

- (void)rtcEngine:(AgoraRtcEngineKit* _Nonnull)engine didOccurError:(AgoraErrorCode)errorCode
{
    MSLog(@"didOccurError == %zd",errorCode);
}

- (void)rtcEngine:(AgoraRtcEngineKit* _Nonnull)engine didJoinChannel:(NSString* _Nonnull)channel withUid:(NSUInteger)uid elapsed:(NSInteger)elapsed
{
    MSLog(@"didJoinChannel uid == %zd",uid);
}

- (void)rtcEngine:(AgoraRtcEngineKit* _Nonnull)engine didRejoinChannel:(NSString* _Nonnull)channel withUid:(NSUInteger)uid elapsed:(NSInteger)elapsed
{
    MSLog(@"didRejoinChannel uid == %zd",uid);
}

- (void)rtcEngine:(AgoraRtcEngineKit* _Nonnull)engine didLeaveChannelWithStats:(AgoraChannelStats* _Nonnull)stats
{
    MSLog(@"didLeaveChannelWithStats stats == %@",stats);
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed
{
    MSLog(@"didJoinedOfUid uid = %zd",uid);
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason
{
    MSLog(@"didOfflineOfUid uid = %zd",uid);
}

@end
