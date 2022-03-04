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
#import "MSVoipCenter.h"


@interface MSCallViewController ()<AgoraRtcEngineDelegate,MSVoiceCallViewDelegate,MSVideoCallViewDelegate>

@property(nonatomic,strong) AgoraRtcEngineKit *agoraKit;

@property(nonatomic,copy) NSString *partner_id;

@property(nonatomic,assign) MSCallType callType;

@property(nonatomic,assign) CallState curState;

@property(nonatomic,assign) BOOL isCreator;

@property(nonatomic,copy) NSString *token;

@property(nonatomic,copy) NSString *room_id;

@property(nonatomic,strong) MSVoiceCallView *voiceCallView;

@property(nonatomic,strong) MSVideoCallView *videoCallView;

@property(nonatomic,strong) NSTimer *durationTimer;

@property(nonatomic,assign) NSInteger duration;

@property(nonatomic,assign) NSInteger callUidOfMe;

@property(nonatomic,assign) NSInteger callUidOfOther;

@property(nonatomic,assign) BOOL mainLocal;

@end

@implementation MSCallViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.mainLocal = YES;
    
    if (self.callType == MSCallType_Voice) {
        [self.view addSubview:self.voiceCallView];
        [self.voiceCallView initDataWithSponsor:(self.curState == CallState_Dailing) partner_id:self.partner_id];
    }else {
        [self.view addSubview:self.videoCallView];
        [self.videoCallView initDataWithSponsor:(self.curState == CallState_Dailing) partner_id:self.partner_id];
    }
    [self initializeAgoraEngine];
}

- (instancetype)initWithCallType:(MSCallType)type sponsor:(NSString *)sponsor invitee:(NSString *)invitee room_id:(NSString *)room_id
{
    if (self = [super init]) {
        _callType = type;
        _room_id = room_id;
        if (sponsor && [sponsor isEqualToString:[MSIMTools sharedInstance].user_id]) {
            _partner_id = invitee;
            _isCreator = YES;
            _curState = CallState_Dailing;
        }else {
            _partner_id = sponsor;
            _curState = CallState_OnInvitee;
        }
    }
    return self;
}

- (void)initializeAgoraEngine
{
    [[MSIMManager sharedInstance] getAgoraToken:self.room_id succ:^(NSString * _Nonnull app_id, NSString * _Nonnull token) {
        self.token = token;
        self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:app_id delegate:self];
        if (self.callType == MSCallType_Voice) {
            [self.agoraKit enableAudio];
        }else {
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
    } failed:^(NSInteger code, NSString *desc) {
        MSLog(@"请求声网token失败：%zd--%@",code,desc);
    }];
}

- (void)joinChannel
{
    if (self.callType == MSCallType_Voice) {
        [self.agoraKit setDefaultAudioRouteToSpeakerphone:NO];
        [self.agoraKit joinChannelByToken:self.token channelId:self.room_id info:nil uid:[MSIMTools sharedInstance].user_id.integerValue joinSuccess:nil];
        [self.agoraKit enableInEarMonitoring:YES];//开启耳返
    }else {
        [self.agoraKit joinChannelByToken:self.token channelId:self.room_id info:nil uid:[MSIMTools sharedInstance].user_id.integerValue joinSuccess:nil];
    }
}

- (void)needToJoinChannel
{
    if (self.token) {
        [self joinChannel];
        return;
    }
    [[MSIMManager sharedInstance] getAgoraToken:self.room_id succ:^(NSString * _Nonnull app_id, NSString * _Nonnull token) {
        self.token = token;
        [AgoraRtcEngineKit destroy];
        self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:app_id delegate:self];
        if (self.callType == MSCallType_Voice) {
            [self.agoraKit enableAudio];
        }else {
            [self.agoraKit enableVideo];
            AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc]init];
            videoCanvas.uid = 0;
            videoCanvas.renderMode = AgoraVideoRenderModeHidden;
            videoCanvas.view = self.videoCallView.localView;
            [self.agoraKit setupLocalVideo:videoCanvas];
        }
        [self joinChannel];
    } failed:^(NSInteger code, NSString *desc) {
        MSLog(@"请求声网token失败：%zd--%@",code,desc);
    }];
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
    [self stopAlerm];
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
- (void)recieveAccept:(MSCallType)callType room_id:(NSString *)room_id
{
    if (![room_id isEqualToString:self.room_id]) return;
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
    [self stopAlerm];
}

/// 对方挂断了通话
- (void)recieveHangup:(MSCallType)callType room_id:(NSString *)room_id
{
    if (![room_id isEqualToString:self.room_id]) return;
    [self stopDurationTimer];
    [[MSVoipCenter shareInstance] hangupBtnDidClick:callType room_id:room_id];
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

- (void)acceptBtnDidClick:(MSCallType)type
{
    if (type == MSCallType_Voice) {
        [self voice_acceptBtnDidClick];
    }else {
        [self video_acceptBtnDidClick];
    }
}

- (void)rejectBtnDidClick:(MSCallType)type
{
    if (type == MSCallType_Voice) {
        [self voice_rejectBtnDidClick];
    }else {
        [self video_rejectBtnDidClick];
    }
}

- (void)hangupBtnDidClick:(MSCallType)type
{
    if (type == MSCallType_Voice) {
        [self voice_hangupBtnDidClick];
    }else {
        [self video_hangupBtnDidClick];
    }
}

#pragma mark - 响铃

- (void)playAlerm
{
    if (self.callType == MSCallType_Voice) {
        [UIDevice playShortSound:@"00" soundExtension:@"caf"];
    }else {
        [UIDevice playShortSound:@"call" soundExtension:@"caf"];
    }
}

- (void)stopAlerm
{
    [UIDevice stopPlaySystemSound];
}

#pragma mark - MSVoiceCallViewDelegate
- (void)voice_cancelBtnDidClick
{
    [[MSCallManager shareInstance] callToPartner:self.partner_id creator:[MSIMTools sharedInstance].user_id callType:MSCallType_Voice action:CallAction_Cancel room_id:self.room_id];
    [[MSVoipCenter shareInstance] cancelBtnDidClick:MSCallType_Voice room_id:self.room_id];
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
    int code = [self.agoraKit setEnableSpeakerphone:self.voiceCallView.handFreeBtn.isSelected];
    MSLog(@"code = %d",code);
}

- (void)voice_rejectBtnDidClick
{
    [[MSCallManager shareInstance] callToPartner:self.partner_id creator:self.partner_id callType:MSCallType_Voice action:CallAction_Reject room_id:self.room_id];
    [self stopDurationTimer];
    [[MSVoipCenter shareInstance] rejectBtnDidClick:MSCallType_Voice room_id:self.room_id];
}

- (void)voice_acceptBtnDidClick
{
    [[MSCallManager shareInstance] callToPartner:self.partner_id creator:self.partner_id callType:MSCallType_Voice action:CallAction_Accept room_id:self.room_id];
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
    [self needToJoinChannel];
    [self stopAlerm];
    [[MSVoipCenter shareInstance] acceptBtnDidClick:MSCallType_Voice room_id:self.room_id];
}

- (void)voice_hangupBtnDidClick
{
    [[MSCallManager shareInstance] callToPartner:self.partner_id creator:(self.isCreator ? [MSIMTools sharedInstance].user_id : self.partner_id) callType:MSCallType_Voice action:CallAction_End room_id:self.room_id];
    [self stopDurationTimer];
    [[MSVoipCenter shareInstance] hangupBtnDidClick:MSCallType_Voice room_id:self.room_id];
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
    [[MSCallManager shareInstance] callToPartner:self.partner_id creator:[MSIMTools sharedInstance].user_id callType:MSCallType_Video action:CallAction_Cancel room_id:self.room_id];
    [[MSVoipCenter shareInstance] cancelBtnDidClick:MSCallType_Voice room_id:self.room_id];
}

- (void)video_cameraBtnDidClick
{
    [self.agoraKit switchCamera];
}

- (void)video_rejectBtnDidClick
{
    [[MSCallManager shareInstance] callToPartner:self.partner_id creator:self.partner_id callType:MSCallType_Video action:CallAction_Reject room_id:self.room_id];
    [self stopDurationTimer];
    [[MSVoipCenter shareInstance] rejectBtnDidClick:MSCallType_Video room_id:self.room_id];
}

- (void)video_acceptBtnDidClick
{
    [[MSCallManager shareInstance] callToPartner:self.partner_id creator:self.partner_id callType:MSCallType_Video action:CallAction_Accept room_id:self.room_id];
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
    [self needToJoinChannel];
    [self stopAlerm];
    [[MSVoipCenter shareInstance] acceptBtnDidClick:MSCallType_Video room_id:self.room_id];
}

- (void)video_hangupBtnDidClick
{
    [[MSCallManager shareInstance] callToPartner:self.partner_id creator:(self.isCreator ? [MSIMTools sharedInstance].user_id : self.partner_id) callType:MSCallType_Video action:CallAction_End room_id:self.room_id];
    [self stopDurationTimer];
    [[MSVoipCenter shareInstance] hangupBtnDidClick:MSCallType_Video room_id:self.room_id];
}

- (void)video_remoteViewDidTap
{
    self.mainLocal = !self.mainLocal;
    AgoraRtcVideoCanvas *meCanvas = [[AgoraRtcVideoCanvas alloc]init];
    meCanvas.uid = self.callUidOfMe;
    meCanvas.renderMode = AgoraVideoRenderModeHidden;
    meCanvas.view = self.mainLocal ? self.videoCallView.localView : self.videoCallView.remoteView;
    [self.agoraKit setupLocalVideo:meCanvas];
    
    AgoraRtcVideoCanvas *otherCanvas = [[AgoraRtcVideoCanvas alloc] init];
    otherCanvas.uid = self.callUidOfOther;
    otherCanvas.renderMode = AgoraVideoRenderModeHidden;
    otherCanvas.view = self.mainLocal == NO ? self.videoCallView.localView : self.videoCallView.remoteView;
    [self.agoraKit setupRemoteVideo:otherCanvas];
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
    self.callUidOfMe = uid;
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
    self.callUidOfOther = uid;
    [self video_remoteViewDidTap];
    MSLog(@"didJoinedOfUid uid = %zd",uid);
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
