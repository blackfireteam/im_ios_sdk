//
//  MSVoiceViewController.m
//  BlackFireIM
//
//  Created by benny wang on 2021/7/20.
//

#import "MSCallViewController.h"
#import <AgoraRtcKit/AgoraRtcEngineKit.h>
#import "MSIMSDK-UIKit.h"
#import <MSIMSDK/MSIMSDK.h>
#import "MSVoiceCallView.h"
#import "MSVideoCallView.h"
#import "MSCallModel.h"


@interface MSCallViewController ()<AgoraRtcEngineDelegate,MSVoiceCallViewDelegate,MSVideoCallViewDelegate>

@property(nonatomic,strong) AgoraRtcEngineKit *agoraKit;

@property(nonatomic,copy) NSString *partner_id;

@property(nonatomic,assign) MSCallType callType;

@property(nonatomic,assign) CallState curState;

@property(nonatomic,strong) MSVoiceCallView *voiceCallView;

@property(nonatomic,strong) MSVideoCallView *videoCallView;

@property(nonatomic,strong) NSTimer *durationTimer;

@property(nonatomic,assign) NSInteger duration;

@end

@implementation MSCallViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    if (self.callType == MSCallType_Voice) {
        [self.view addSubview:self.voiceCallView];
        [self.voiceCallView initDataWithSponsor:(self.curState == CallState_Dailing) partner_id:self.partner_id];
        [self initializeAgoraEngine];
        [self.agoraKit enableAudio];
    }else {
        [self.view addSubview:self.videoCallView];
        [self.videoCallView initDataWithSponsor:(self.curState == CallState_Dailing) partner_id:self.partner_id];
        [self initializeAgoraEngine];
        [self.agoraKit enableVideo];
        AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc]init];
        videoCanvas.uid = 0;
        videoCanvas.renderMode = AgoraVideoRenderModeHidden;
        videoCanvas.view = self.videoCallView.localView;
        [self.agoraKit setupLocalVideo:videoCanvas];
    }
    if (self.curState == CallState_Dailing) {
        [self joinChannel];
    }
}

- (instancetype)initWithCallType:(MSCallType)type sponsor:(NSString *)sponsor invitee:(NSString *)invitee
{
    if (self = [super init]) {
        _callType = type;
        if (sponsor && [sponsor isEqualToString:[MSIMTools sharedInstance].user_id]) {
            _partner_id = invitee;
            _curState = CallState_Dailing;
        }else {
            _partner_id = sponsor;
            _curState = CallState_OnInvitee;
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

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

/// 对方同意通话
- (void)recieveAccept:(MSCallType)callType
{
    if (callType == MSCallType_Voice) {
        self.voiceCallView.cancelBtn.hidden = YES;
        self.voiceCallView.hangupBtn.hidden = NO;
        self.curState = CallState_Calling;
        self.voiceCallView.noticeL.hidden = YES;
        self.voiceCallView.durationL.hidden = NO;
    }else {
        self.videoCallView.cancelBtn.hidden = YES;
        self.videoCallView.hangupBtn.hidden = NO;
        self.videoCallView.cameraBtn.hidden = NO;
        self.curState = CallState_Calling;
        self.videoCallView.noticeL.hidden = YES;
        self.videoCallView.avatarIcon.hidden = YES;
        self.videoCallView.nickNamekL.hidden = YES;
        self.videoCallView.durationL.hidden = NO;
        self.videoCallView.remoteView.hidden = NO;
    }
    [self startDurationTimer];
}

/// 对方拒绝通话
- (void)recieveReject:(MSCallType)callType
{
    if (callType == MSCallType_Voice) {
        self.voiceCallView.noticeL.hidden = YES;
    }else {
        self.videoCallView.noticeL.hidden = YES;
    }
}

/// 对方挂断了通话
- (void)recieveHangup:(MSCallType)callType
{
    [self stopDurationTimer];
}

/// 对方取消了通话
- (void)recieveCancel:(MSCallType)callType
{
    if (callType == MSCallType_Voice) {
        self.voiceCallView.noticeL.hidden = YES;
    }else {
        self.videoCallView.noticeL.hidden = YES;
    }
}

#pragma mark -timer

- (void)startDurationTimer
{
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
    if (self.callType == MSCallType_Voice) {
        self.voiceCallView.durationL.text = [NSString stringWithFormat:@"%02zd : %02zd",self.duration/60,self.duration%60];
    }else {
        self.videoCallView.durationL.text = [NSString stringWithFormat:@"%02zd : %02zd",self.duration/60,self.duration%60];
    }
}

- (MSVoiceCallView *)voiceCallView
{
    if (!_voiceCallView) {
        _voiceCallView = [[MSVoiceCallView alloc]initWithFrame:UIScreen.mainScreen.bounds];
        _voiceCallView.delegate = self;
    }
    return _voiceCallView;
}

- (MSVideoCallView *)videoCallView
{
    if (!_videoCallView) {
        _videoCallView = [[MSVideoCallView alloc]initWithFrame:UIScreen.mainScreen.bounds];
        _videoCallView.delegate = self;
    }
    return _videoCallView;
}

#pragma mark - 响铃

- (void)playAlerm
{
//    [UIDevice playShortSound:@"00" soundExtension:@"caf"];
}


#pragma mark - MSVoiceCallViewDelegate
- (void)voice_cancelBtnDidClick
{
    [[MSCallManager shareInstance] call:[MSIMTools sharedInstance].user_id toUser:self.partner_id callType:MSCallType_Voice action:CallAction_Cancel];
}

- (void)voice_mickBtnDidClick
{
    self.voiceCallView.micBtn.selected = !self.voiceCallView.micBtn.selected;
    if (self.voiceCallView.micBtn.isSelected) {
        [self.agoraKit adjustRecordingSignalVolume:100];
    }else {
        [self.agoraKit adjustRecordingSignalVolume: 0];
    }
}

- (void)voice_handFreeBtnDidClick
{
    self.voiceCallView.handFreeBtn.selected = !self.voiceCallView.handFreeBtn.selected;
    [self.agoraKit setEnableSpeakerphone:self.voiceCallView.handFreeBtn.isSelected];
}

- (void)voice_rejectBtnDidClick
{
    [[MSCallManager shareInstance] call:[MSIMTools sharedInstance].user_id toUser:self.partner_id callType:MSCallType_Voice action:CallAction_Reject];
    [self stopDurationTimer];
}

- (void)voice_acceptBtnDidClick
{
    [[MSCallManager shareInstance] call:[MSIMTools sharedInstance].user_id toUser:self.partner_id callType:MSCallType_Voice action:CallAction_Accept];
    self.voiceCallView.rejectBtn.hidden = YES;
    self.voiceCallView.acceptBtn.hidden = YES;
    self.voiceCallView.micBtn.hidden = NO;
    self.voiceCallView.handFreeBtn.hidden = NO;
    self.voiceCallView.hangupBtn.hidden = NO;
    self.voiceCallView.cancelBtn.hidden = YES;
    self.voiceCallView.noticeL.hidden = YES;
    self.voiceCallView.durationL.hidden = NO;
    [self startDurationTimer];
    self.curState = CallState_Calling;
    [self joinChannel];
}

- (void)voice_hangupBtnDidClick
{
    [[MSCallManager shareInstance] call:[MSIMTools sharedInstance].user_id toUser:self.partner_id callType:MSCallType_Voice action:CallAction_End];
    [self stopDurationTimer];
}


- (void)initializeAgoraEngine
{
    /// 初始化 AgoraRtcEngineKit 对象
    self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:@"1a3bdfc8f46b4060bed01d15b75a5ed9" delegate:self];
}

- (void)joinChannel
{
    if (self.callType == MSCallType_Voice) {
        [self.agoraKit setDefaultAudioRouteToSpeakerphone:NO];
        [self.agoraKit joinChannelByToken:@"0061a3bdfc8f46b4060bed01d15b75a5ed9IACEHM9wcpzpdCUMiyJ+KVf+hyG994FZZ+k46385Jgknyj1Ra00AAAAAEAA7+TVQJmf/YAEAAQAkZ/9g" channelId:@"111" info:nil uid:[MSIMTools sharedInstance].user_id.integerValue joinSuccess:nil];
        [self.agoraKit enableInEarMonitoring:YES];//开启耳返
    }else {
        [self.agoraKit joinChannelByToken:@"0061a3bdfc8f46b4060bed01d15b75a5ed9IACEHM9wcpzpdCUMiyJ+KVf+hyG994FZZ+k46385Jgknyj1Ra00AAAAAEAA7+TVQJmf/YAEAAQAkZ/9g" channelId:@"111" info:nil uid:[MSIMTools sharedInstance].user_id.integerValue joinSuccess:nil];
    }
}

///根据场景需要，如结束通话、关闭 app 或 app 切换至后台时，调用 leaveChannel 离开当前通话频道。
- (void)stopVoice
{
    [self.agoraKit leaveChannel:nil];
    [AgoraRtcEngineKit destroy];
}

#pragma mark - MSVideoCallViewDelegate

- (void)video_cancelBtnDidClick
{
    [[MSCallManager shareInstance] call:[MSIMTools sharedInstance].user_id toUser:self.partner_id callType:MSCallType_Video action:CallAction_Cancel];
}

- (void)video_cameraBtnDidClick
{
    [self.agoraKit switchCamera];
}

- (void)video_rejectBtnDidClick
{
    [[MSCallManager shareInstance] call:[MSIMTools sharedInstance].user_id toUser:self.partner_id callType:MSCallType_Video action:CallAction_Reject];
    [self stopDurationTimer];
}

- (void)video_acceptBtnDidClick
{
    [[MSCallManager shareInstance] call:[MSIMTools sharedInstance].user_id toUser:self.partner_id callType:MSCallType_Video action:CallAction_Accept];
    self.videoCallView.rejectBtn.hidden = YES;
    self.videoCallView.acceptBtn.hidden = YES;
    self.videoCallView.remoteView.hidden = NO;
    self.videoCallView.cameraBtn.hidden = NO;
    self.videoCallView.hangupBtn.hidden = NO;
    self.videoCallView.cancelBtn.hidden = YES;
    self.videoCallView.noticeL.hidden = YES;
    self.videoCallView.avatarIcon.hidden = YES;
    self.videoCallView.nickNamekL.hidden = YES;
    self.videoCallView.durationL.hidden = NO;
    [self startDurationTimer];
    self.curState = CallState_Calling;
    [self joinChannel];
}

- (void)video_hangupBtnDidClick
{
    [[MSCallManager shareInstance] call:[MSIMTools sharedInstance].user_id toUser:self.partner_id callType:MSCallType_Video action:CallAction_End];
    [self stopDurationTimer];
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
    if (self.callType == MSCallType_Video) {//设置远端视图
        AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
        videoCanvas.uid = uid;
        videoCanvas.renderMode = AgoraVideoRenderModeHidden;
        videoCanvas.view = self.videoCallView.remoteView;
        [self.agoraKit setupRemoteVideo:videoCanvas];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason
{
    MSLog(@"didOfflineOfUid uid = %zd",uid);
}

- (void)rtcEngineConnectionDidLost:(AgoraRtcEngineKit *)engine
{
    MSLog(@"rtcEngineConnectionDidLost");
}

@end
