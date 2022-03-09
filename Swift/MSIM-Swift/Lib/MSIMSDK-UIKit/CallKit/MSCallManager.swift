//
//  MSCallManager.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/9/28.
//

import UIKit
import MSIMSDK


enum CallAction: Int {
    case error = -1        //系统错误
    case unknown           //未知流程
    case call              //邀请方发起请求
    case cancel            //邀请方取消请求（只有在被邀请方还没处理的时候才能取消）
    case reject            //被邀请方拒绝邀请
    case timeout           //被邀请方超时未响应
    case end               //通话中断
    case linebusy          //被邀请方正忙
    case accept            //被邀请方接受邀请
}

enum MSCallType {
    case voice             //语音通话
    case video             //视频通话
}

enum CallState {
    case dailing           //呼叫
    case onInvitee         //被呼叫
    case calling           //通话中
}

class MSCallManager: NSObject {

    static let shared: MSCallManager = MSCallManager()
    
    func callToPartner(partner_id: String,
                       creator: String,
                       callType: MSCallType,
                       action: CallAction,
                       room_id: String?) {
        if partner_id.count == 0 || creator.count == 0 {return}
        if room_id != nil {
            self.room_id = room_id!
        }else {
            let currentT = MSIMTools.sharedInstance().adjustLocalTimeInterval / 1000 / 1000
            self.room_id = String(format: "c2c_%@_%zd", MSIMTools.sharedInstance().user_id!,currentT)
        }
        switch action {
        case .call:
            self.isOnCallingWithUid = partner_id
            self.callType = callType
            self.callVC = MSCallViewController(callType: self.callType, sponsor: creator, invitee: partner_id, room_id: self.room_id)
            self.callVC?.modalPresentationStyle = .fullScreen
            let appdelegate = UIApplication.shared.delegate as? AppDelegate
            appdelegate?.window?.rootViewController?.present(self.callVC!, animated: true, completion: nil)
            
            self.timerCount = 0
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {[weak self] timer in
                guard let strongSelf = self else{return}
                self?.inviteTimerAction(room_id: strongSelf.room_id,toReciever: partner_id)
            })
            RunLoop.main.add(self.timer!, forMode: .common)
        case .cancel:
            
            if creator == MSIMTools.sharedInstance().user_id {
                /// 作为邀请方，取消通话，会补发一条取消通话的普通消息
                self.sendMessage(action: .cancel,option: .IMCUSTOM_UNREADCOUNT_NO_RECALL,room_id: self.room_id,toReciever: partner_id)
                self.timer?.invalidate()
                self.timer = nil
                self.timerCount = 0
                self.destroyCallVC()
            }
        case .reject:
            
            if creator != MSIMTools.sharedInstance().user_id {
                /// 作为被邀请方，点击拒绝，结束通话。补一条拒绝的指令消息
                self.sendMessage(action: .reject,option: .IMCUSTOM_SIGNAL,room_id: self.room_id,toReciever: partner_id)
                self.destroyCallVC()
            }
        case .end:
            
            if creator == MSIMTools.sharedInstance().user_id {
                /// 自己是邀请方主动挂断，结束通话同时补发一条结束的普通消息
                self.sendMessage(action: .end,option: .IMCUSTOM_UNREADCOUNT_NO_RECALL,room_id: self.room_id,toReciever: partner_id)
                self.destroyCallVC()
            }else {
                ///自己是被邀请方主动挂断，结束通话同时补发一条结束的指令消息
                self.sendMessage(action: .end,option: .IMCUSTOM_SIGNAL,room_id: self.room_id,toReciever: partner_id)
                self.destroyCallVC()
            }
        case .accept:
            
            if creator != MSIMTools.sharedInstance().user_id {
                /// 作为被邀请方，点击接受，补一条接受的指令消息
                self.callVC?.recieveAccept(callType: callType, room_id: self.room_id)
                self.sendMessage(action: .accept,option: .IMCUSTOM_SIGNAL,room_id: self.room_id,toReciever: partner_id)
            }
        default:
            break
        }
    }
    
    func recieveCall(from: String,
                     creator: String,
                     callType: MSCallType,
                     action: CallAction,
                     room_id: String?) {
        
        if from.count == 0 || from == MSIMTools.sharedInstance().user_id || creator.count == 0 {return}

        switch action {
        case .call:
            
            if self.isOnCallingWithUid != nil {
                if self.isOnCallingWithUid != from {
                    /// 如果正与某人聊天，收到另一邀请指令，会给对方回一条正忙的指令消息
                    self.sendMessage(action: .linebusy, option: .IMCUSTOM_SIGNAL, room_id: room_id!, toReciever: from)
                }
                return
            }
            if self.room_id != room_id {
                self.isOnCallingWithUid = from
                self.callType = callType
                self.callVC = MSCallViewController(callType: self.callType, sponsor: from, invitee: MSIMTools.sharedInstance().user_id!, room_id: room_id!)
                self.callVC?.modalPresentationStyle = .fullScreen
                let appdelegate = UIApplication.shared.delegate as? AppDelegate
                appdelegate?.window?.rootViewController?.present(self.callVC!, animated: true, completion: nil)
            }
            
        case .cancel:
            
            if creator != MSIMTools.sharedInstance().user_id {
                /// 作为被邀请方收到对方取消通话消息，结束通话
                self.destroyCallVC()
            }
        case .reject:
            
            if creator == MSIMTools.sharedInstance().user_id {
                /// 作为邀请方，收到对方的拒绝指令，结束通话，同时补一条拒绝的普通消息
                self.timer?.invalidate()
                self.timer = nil
                self.timerCount = 0
                self.sendMessage(action: .reject, option: .IMCUSTOM_UNREADCOUNT_NO_RECALL, room_id: room_id!, toReciever: from)
            }
            self.destroyCallVC()
        case .timeout:
            
            if creator != MSIMTools.sharedInstance().user_id {
                /// 作为被邀请方，收到对方超时消息，结束通话
                self.destroyCallVC()
            }
        case .end:
            
            if creator == MSIMTools.sharedInstance().user_id {
                /// 作为邀请方，收到对方挂断指令，会结束通话。同时发一条结束的普通消息
                self.sendMessage(action: .end, option: .IMCUSTOM_UNREADCOUNT_NO_RECALL, room_id: room_id!, toReciever: from)
                self.destroyCallVC()
            }else {
                /// 作为被邀请方，收到对方挂断的消息，会结束通话
                self.callVC?.recieveHangup(callType: callType, room_id: room_id!)
                self.destroyCallVC()
            }
        case .linebusy:
            
            if creator == MSIMTools.sharedInstance().user_id {
                /// 作为邀请方，收到一条对方正忙的指令，我会结束通话，同时补发一条对方正忙的普通消息
                self.timer?.invalidate()
                self.timer = nil
                self.timerCount = 0
                self.destroyCallVC()
                self.sendMessage(action: .linebusy, option: .IMCUSTOM_UNREADCOUNT_NO_RECALL, room_id: room_id!, toReciever: from)
            }
        case .accept:
            
            if creator == MSIMTools.sharedInstance().user_id {
                /// 作为邀请方收到对方接受的指令消息
                self.timer?.invalidate()
                self.timer = nil
                self.timerCount = 0
                self.callVC?.recieveAccept(callType: callType, room_id: room_id!)
            }
        default:
            break
        }
    }
    
    /// 根据自定义参数解析出消息中展示的内容
    class func parseToMessageShow(customParams: [String: Any],callType: MSCallType,isSelf: Bool) -> String? {
        
        guard let actionInt = customParams["event"] as? Int,let action = CallAction(rawValue: actionInt)  else {return nil}
        switch action {
        case .cancel:
            
            return isSelf ? Bundle.bf_localizedString(key: "TUIkitSignalingCancelCall") : Bundle.bf_localizedString(key: "TUIkitSignalingCancelCallOther")
        case .reject:
            
            return isSelf ? Bundle.bf_localizedString(key: "TUIkitSignalingDeclineOther") : Bundle.bf_localizedString(key: "TUIkitSignalingDecline")
        case .timeout:
            
            return isSelf ? Bundle.bf_localizedString(key: "TUIKitSignalingNoResponseOther") : Bundle.bf_localizedString(key: "TUIKitSignalingNoResponse")
        case .end:
            if let duration = customParams["duration"] as? Int {
                if callType == .voice {
                    return String(format: Bundle.bf_localizedString(key: "TUIKitSignalingVoiceCallEnd"), duration / 60, duration % 60)
                }else {
                    return String(format: Bundle.bf_localizedString(key: "TUIKitSignalingVideoCallEnd"), duration / 60, duration % 60)
                }
            }
        case .linebusy:
            
            return isSelf ? Bundle.bf_localizedString(key: "TUIKitSignalingCallBusy") : Bundle.bf_localizedString(key: "TUIKitSignalingCallBusyOther")
        default:
            return Bundle.bf_localizedString(key: "TUIkitMessageTipsUnknowMessage")
        }
        return nil
    }
    
    /// 根据自定义参数解析出在会话中展示的内容
    class func parseToConversationShow(customParams: [String: Any],callType: MSCallType,isSelf: Bool) -> String? {
        
        if let desc = self.parseToMessageShow(customParams: customParams, callType: callType, isSelf: isSelf) {
            if callType == .voice {
                return String(format: "%@ %@", Bundle.bf_localizedString(key: "TUIkitMessageTypeVoiceCall"), desc)
            }else {
                return String(format: "%@ %@", Bundle.bf_localizedString(key: "TUIkitMessageTypeVideoCall"), desc)
            }
        }
        return nil
    }
    
    class func getCreatorFrom(room_id: String) -> String? {
        
        let arr = room_id.components(separatedBy: "_")
        if arr.count == 3 {
            return arr[1]
        }
        return nil
    }
    
    private var isOnCallingWithUid: String?
    
    private var callVC: MSCallViewController?
    
    private var action: CallAction = .error
    
    private var callType: MSCallType = .voice
    
    private var timer: Timer?
    
    private var timerCount: Int = 0
    
    private var room_id: String = ""
    
    private func inviteTimerAction(room_id: String, toReciever: String) {
        
        self.sendMessage(action: .call, option: .IMCUSTOM_SIGNAL, room_id: room_id, toReciever: toReciever)
        /// 作为邀请方，对方60秒内无应答，结束通话。补发一条超时的普通消息
        if self.timerCount >= 60 {
            self.timer?.invalidate()
            self.timer = nil
            self.timerCount = 0
            self.destroyCallVC()
            self.sendMessage(action: .timeout, option: .IMCUSTOM_UNREADCOUNT_NO_RECALL, room_id: room_id, toReciever: toReciever)
        }
        self.timerCount += 1
    }
    
    private func destroyCallVC() {
        if self.callVC != nil {
            UIDevice.stopPlaySystemSound()
            self.callVC?.dismiss(animated: true, completion: nil)
            self.callVC = nil
            self.isOnCallingWithUid = nil
            self.action = .unknown
        }
        NotificationCenter.default.post(name: NSNotification.Name.init("kRecieveNeedToDismissVoipView"), object: self.room_id);
    }
    
    func sendMessage(action: CallAction, option: MSIMCustomOption, room_id: String, toReciever: String) {
        
        let extDic = ["room_id": room_id, "type": (self.callType == .voice ? MSIMCustomSubType.VoiceCall.rawValue : MSIMCustomSubType.VideoCall.rawValue), "event": action.rawValue, "duration": self.callVC!.duration] as [String : Any]
        var push: MSIMPushInfo?
        if action == .timeout || action == .cancel {
            let attachExt = (self.callType == .voice ? "[Voice call]" : "[Video call]")
            push = MSIMPushInfo()
            push?.body = String(format: "%@ Call cancelled by caller", attachExt)
            push?.sound = "default"
        }else if action == .call {
            if self.timerCount == 0 {
                let attachExt = (self.callType == .voice ? "[Voice call]" : "[Video call]")
                push = MSIMPushInfo()
                push?.body = String(format: "%@ Start Call", attachExt)
                push?.sound = (self.callType == .voice ? "00.caf" : "call.caf")
            }
        }else if action == .linebusy || action == .end {
            if option != .IMCUSTOM_SIGNAL {
                let attachExt = (self.callType == .voice ? "[Voice call]" : "[Video call]")
                push = MSIMPushInfo()
                push?.body = String(format: "%@ Duration: %02zd:%02zd", attachExt,self.callVC!.duration / 60,self.callVC!.duration % 60)
                push?.sound = "default"
            }
        }else if action == .reject && option != .IMCUSTOM_SIGNAL {
            let attachExt = (self.callType == .voice ? "[Voice call]" : "[Video call]")
            push = MSIMPushInfo()
            push?.body = String(format: "%@ Call declined by user", attachExt)
            push?.sound = "default"
        }
        let custom = MSIMManager.sharedInstance().createVoipMessage(extDic.bf_convertJsonString(), option: option, pushExt: push)
        MSIMManager.sharedInstance().sendC2CMessage(custom, toReciever: toReciever) { _ in
            
        } failed: { _, desc in
            debugPrint("\(desc ?? "")")
        }
    }
}
