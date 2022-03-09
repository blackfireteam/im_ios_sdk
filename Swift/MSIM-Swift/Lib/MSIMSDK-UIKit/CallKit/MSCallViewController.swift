//
//  MSCallViewController.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/9/28.
//

import UIKit
import MSIMSDK
import AgoraRtcKit


class MSCallViewController: UIViewController {

    init(callType: MSCallType,sponsor: String,invitee: String,room_id: String) {
        super.init(nibName: nil, bundle: nil)
        
        self.callType = callType
        self.room_id = room_id
        if sponsor == MSIMTools.sharedInstance().user_id {
            self.partner_id = invitee
            self.isCreator = true
            self.curState = .dailing
        }else {
            self.partner_id = sponsor
            self.curState = .onInvitee
        }
    }
    
    /// 对方同意通话
    func recieveAccept(callType: MSCallType,room_id: String) {
        
        if room_id != self.room_id {return}
        if callType == .voice {
            self.voiceCallView.cancelBtn.isHidden = true
            self.voiceCallView.hangupBtn.isHidden = false
            self.curState = .calling
            self.voiceCallView.noticeL.isHidden = true
            self.voiceCallView.durationL.isHidden = false
        }else {
            self.videoCallView.cancelBtn.isHidden = true
            self.videoCallView.hangupBtn.isHidden = false
            self.videoCallView.cameraBtn.isHidden = false
            self.curState = .calling
            self.videoCallView.noticeL.isHidden = true
            self.videoCallView.avatarIcon.isHidden = true
            self.videoCallView.nickNameL.isHidden = true
            self.videoCallView.durationL.isHidden = false
            self.videoCallView.remoteView.isHidden = false
        }
        self.startDurationTimer()
        self.stopAlerm()
    }
    
    /// 对方挂断了通话
    func recieveHangup(callType: MSCallType,room_id: String) {
        
        if room_id != self.room_id {return}
        self.stopDurationTimer()
    }
    
    private var agoraKit: AgoraRtcEngineKit?
    
    private var partner_id: String!
    
    private var callType: MSCallType!
    
    private var curState: CallState!
    
    private var isCreator: Bool = false
    
    private var token: String?
    
    private var room_id: String?
    
    private lazy var voiceCallView: MSVoiceCallView = {
        let voiceCallView = MSVoiceCallView(frame: UIScreen.main.bounds)
        voiceCallView.delegate = self
        return voiceCallView
    }()
    
    private lazy var videoCallView: MSVideoCallView = {
        let videoCallView = MSVideoCallView(frame: UIScreen.main.bounds)
        videoCallView.delegate = self
        return videoCallView
    }()
    
    private var durationTimer: Timer?
    
    private(set) var duration: Int = 0
    
    private var callUidOfMe: UInt = 0
    
    private var callUidOfOther: UInt = 0
    
    private var mainLocal: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        if self.callType == .voice {
            view.addSubview(self.voiceCallView)
            self.voiceCallView.initDataWithSponsor(isMe: self.curState == .dailing, partner_id: self.partner_id)
        }else {
            view.addSubview(videoCallView)
            videoCallView.initDataWithSponsor(isMe: self.curState == .dailing, partner_id: self.partner_id)
        }
        initializeAgoraEngine()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
        playAlerm()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
        stopAlerm()
        stopVoice()
    }
    
    deinit {
        print("\(self) dealloc")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func initializeAgoraEngine() {
        MSIMManager.sharedInstance().getAgoraToken(self.room_id!) { app_id, token in
            
            self.token = token
            self.agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: app_id, delegate: self)
            if self.callType == .voice {
                self.agoraKit?.enableAudio()
            }else {
                self.agoraKit?.enableVideo()
                let videoCanvas = AgoraRtcVideoCanvas()
                videoCanvas.uid = 0
                videoCanvas.renderMode = .hidden
                videoCanvas.view = self.videoCallView.localView
                self.agoraKit?.setupLocalVideo(videoCanvas)
            }
            if self.curState == .dailing {
                self.joinChannel()
            }
        } failed: { code, desc in
            print("请求声网token失败：\(code)--\(desc ?? "")")
        }
    }
    
    private func joinChannel() {
        
        if self.callType == .voice {
            self.agoraKit?.setDefaultAudioRouteToSpeakerphone(false)
            self.agoraKit?.joinChannel(byToken: self.token, channelId: self.room_id!, info: nil, uid: UInt(MSIMTools.sharedInstance().user_id ?? "") ?? 0, joinSuccess: nil)
            self.agoraKit?.enable(inEarMonitoring: true)
        }else {
            self.agoraKit?.joinChannel(byToken: self.token, channelId: self.room_id!, info: nil, uid: UInt(MSIMTools.sharedInstance().user_id ?? "") ?? 0, joinSuccess: nil)
        }
    }
    
    private func needToJoinChannel() {
        if self.token != nil {
            self.joinChannel()
            return
        }
        MSIMManager.sharedInstance().getAgoraToken(self.room_id!) { app_id, token in
            
            self.token = token
            AgoraRtcEngineKit.destroy()
            self.agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: app_id, delegate: self)
            if self.callType == .voice {
                self.agoraKit?.enableAudio()
            }else {
                self.agoraKit?.enableVideo()
                let videoCanvas = AgoraRtcVideoCanvas()
                videoCanvas.uid = 0
                videoCanvas.renderMode = .hidden
                videoCanvas.view = self.videoCallView.localView
                self.agoraKit?.setupLocalVideo(videoCanvas)
            }
            self.joinChannel()
        } failed: { code, desc in
            print("请求声网token失败：\(code)--\(desc ?? "")")
        }

    }
    
    ///根据场景需要，如结束通话、关闭 app 或 app 切换至后台时，调用 leaveChannel 离开当前通话频道。
    private func stopVoice() {
        self.agoraKit?.leaveChannel(nil)
        AgoraRtcEngineKit.destroy()
    }
    
    /// - 响铃
    private func playAlerm() {
        if self.callType == .voice {
            UIDevice.playShortSound(soundName: "00", soundExtension: "caf")
        }else {
            UIDevice.playShortSound(soundName: "call", soundExtension: "caf")
        }
    }
    
    private func stopAlerm() {
        UIDevice.stopPlaySystemSound()
    }
    
    
    /// timer
    private func startDurationTimer() {
        self.durationTimer?.invalidate()
        self.durationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(callDuration), userInfo: nil, repeats: true)
        RunLoop.main.add(self.durationTimer!, forMode: .common)
    }
    
    private func stopDurationTimer() {
        self.durationTimer?.invalidate()
        self.durationTimer = nil
    }
    
    @objc func callDuration() {
        self.duration += 1
        if self.callType == .voice {
            self.voiceCallView.durationL.text = String(format: "%02zd : %02zd", self.duration / 60, self.duration % 60)
        }else {
            self.videoCallView.durationL.text = String(format: "%02zd : %02zd", self.duration / 60, self.duration % 60)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MSCallViewController: MSVoiceCallViewDelegate {
    func voice_cancelBtnDidClick() {
        
        MSCallManager.shared.callToPartner(partner_id: self.partner_id, creator: MSIMTools.sharedInstance().user_id!, callType: .voice, action: .cancel, room_id: self.room_id)
    }
    
    func voice_mickBtnDidClick() {
        
        self.voiceCallView.micBtn.isSelected = !self.voiceCallView.micBtn.isSelected
        if self.voiceCallView.micBtn.isSelected {
            self.agoraKit?.adjustRecordingSignalVolume(100)
        }else {
            self.agoraKit?.adjustRecordingSignalVolume(0)
        }
    }
    
    func voice_handFreeBtnDidClick() {
        self.voiceCallView.handFreeBtn.isSelected = !self.voiceCallView.handFreeBtn.isSelected
        self.agoraKit?.setEnableSpeakerphone(self.voiceCallView.handFreeBtn.isSelected)
    }
    
    func voice_rejectBtnDidClick() {
        MSCallManager.shared.callToPartner(partner_id: self.partner_id, creator: self.partner_id, callType: .voice, action: .reject, room_id: self.room_id)
        stopDurationTimer()
    }
    
    func voice_acceptBtnDidClick() {
        MSCallManager.shared.callToPartner(partner_id: self.partner_id, creator: self.partner_id, callType: .voice, action: .accept, room_id: self.room_id)
        self.voiceCallView.rejectBtn.isHidden = true
        self.voiceCallView.acceptBtn.isHidden = true
        self.voiceCallView.micBtn.isHidden = false
        self.voiceCallView.handFreeBtn.isHidden = false
        self.voiceCallView.hangupBtn.isHidden = false
        self.voiceCallView.cancelBtn.isHidden = true
        self.voiceCallView.noticeL.isHidden = true
        self.voiceCallView.durationL.isHidden = false
        startDurationTimer()
        self.curState = .calling
        needToJoinChannel()
        stopAlerm()
    }
    
    func voice_hangupBtnDidClick() {
        MSCallManager.shared.callToPartner(partner_id: self.partner_id, creator: self.isCreator ? MSIMTools.sharedInstance().user_id! : self.partner_id, callType: .voice, action: .end, room_id: self.room_id)
        stopDurationTimer()
    }
}

extension MSCallViewController: MSVideoCallViewDelegate {
    func video_remoteViewDidTap() {
        self.mainLocal = !self.mainLocal
        let meCanvas = AgoraRtcVideoCanvas()
        meCanvas.uid = self.callUidOfMe
        meCanvas.renderMode = .hidden
        meCanvas.view = self.mainLocal ? self.videoCallView.localView : self.videoCallView.remoteView
        self.agoraKit?.setupLocalVideo(meCanvas)
        
        let otherCanvas = AgoraRtcVideoCanvas()
        otherCanvas.uid = self.callUidOfOther
        otherCanvas.renderMode = .hidden
        otherCanvas.view = self.mainLocal ? self.videoCallView.localView : self.videoCallView.remoteView
        self.agoraKit?.setupLocalVideo(otherCanvas)
    }
    
    func video_cancelBtnDidClick() {
        MSCallManager.shared.callToPartner(partner_id: self.partner_id, creator: MSIMTools.sharedInstance().user_id!, callType: .video, action: .cancel, room_id: self.room_id)
    }
    
    func video_cameraBtnDidClick() {
        self.agoraKit?.switchCamera()
    }
    
    func video_rejectBtnDidClick() {
        MSCallManager.shared.callToPartner(partner_id: self.partner_id, creator: self.partner_id, callType: .video, action: .reject, room_id: self.room_id)
        stopDurationTimer()
    }
    
    func video_acceptBtnDidClick() {
        MSCallManager.shared.callToPartner(partner_id: self.partner_id, creator: self.partner_id, callType: .video, action: .accept, room_id: self.room_id)
        self.videoCallView.rejectBtn.isHidden = true
        self.videoCallView.acceptBtn.isHidden = true
        self.videoCallView.remoteView.isHidden = false
        self.videoCallView.cameraBtn.isHidden = false
        self.videoCallView.hangupBtn.isHidden = false
        self.videoCallView.cancelBtn.isHidden = true
        self.videoCallView.noticeL.isHidden = true
        self.videoCallView.avatarIcon.isHidden = true
        self.videoCallView.durationL.isHidden = false
        startDurationTimer()
        self.curState = .calling
        needToJoinChannel()
        stopAlerm()
    }
    
    func video_hangupBtnDidClick() {
        MSCallManager.shared.callToPartner(partner_id: self.partner_id, creator: self.isCreator ? MSIMTools.sharedInstance().user_id! : self.partner_id, callType: .video, action: .end, room_id: self.room_id)
        stopDurationTimer()
    }
}

extension MSCallViewController: AgoraRtcEngineDelegate {
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurWarning warningCode: AgoraWarningCode) {
        debugPrint("didOccurWarning == \(warningCode)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        debugPrint("didOccurError == \(errorCode)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        self.callUidOfMe = uid
        debugPrint("didJoinChannel uid == \(uid)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didRejoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        debugPrint("didRejoinChannel uid == \(uid)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didLeaveChannelWith stats: AgoraChannelStats) {
        debugPrint("didLeaveChannelWithStats stats == \(stats)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        self.callUidOfOther = uid
        self.video_remoteViewDidTap()
        debugPrint("didJoinedOfUid uid = \(uid)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        debugPrint("didOfflineOfUid uid = \(uid)")
    }
    
    func rtcEngineConnectionDidLost(_ engine: AgoraRtcEngineKit) {
        debugPrint("rtcEngineConnectionDidLost")
    }
}
