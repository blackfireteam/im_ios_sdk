//
//  MSVoipCenter.swift
//  MSIM-Swift
//
//  Created by benny wang on 2022/3/4.
//

import UIKit
import CallKit
import AgoraRtcKit
import MSIMSDK


struct CallItem {
    var room_id: String
    var from: String
    var call_type: MSCallType
}
class MSVoipCenter: NSObject,AgoraRtcEngineDelegate {
    
    static let shared: MSVoipCenter = MSVoipCenter()
    
    var callVC: CXCallController?
    
    var agoraKit: AgoraRtcEngineKit?
    
    var uuids: [String: CallItem] = [:]
    
    private(set) var currentCalling: String?
    
    private override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(recieveNeedToDismissVoipView), name: NSNotification.Name.init("kRecieveNeedToDismissVoipView"), object: nil)
    }
    
    func createUUIDWithRoomID(room_id: String,fromUid: String,callType: MSCallType) -> String {
        
        let uuid = UUID().uuidString
        self.uuids[uuid] = CallItem(room_id: room_id, from: fromUid, call_type: callType)
        self.callVC = CXCallController(queue: .main)
        return uuid
    }
    
    func acceptCallWithUuid(uuid: String) {
        if let item = self.uuids[uuid] {
            if item.call_type == .voice {
                self.currentCalling = uuid
                MSCallManager.shared.sendMessage(action: .accept, option: .IMCUSTOM_SIGNAL, room_id: item.room_id, toReciever: item.from)
                self.startToVoice(room_id: item.room_id)
            }
        }
    }
    
    func endCallWithUuid(uuid: String) {
        if let item = self.uuids[uuid] {
            MSCallManager.shared.sendMessage(action: .reject, option: .IMCUSTOM_SIGNAL, room_id: item.room_id, toReciever: item.from)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
            }
        }
    }
    
    func muteCall(isMute: Bool, uuid: String) {
        if let item = self.uuids[uuid] {
            if item.call_type == .voice {
                self.agoraKit?.adjustRecordingSignalVolume(isMute ? 0 : 100)
            }
        }
    }
    
    private func startToVoice(room_id: String) {
        MSIMManager.sharedInstance().getAgoraToken(room_id) { app_id, token in
            
            self.agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: app_id, delegate: self)
            self.agoraKit?.joinChannel(byToken: token, channelId: room_id, info: nil, uid: UInt(MSIMTools.sharedInstance().user_id ?? "")!, joinSuccess: nil)
            
        } failed: { _, _ in
            
        }
    }
    
    @objc func recieveNeedToDismissVoipView(note: Notification) {
        
        self.currentCalling = nil
        for uuid in self.uuids.keys {
            self.uuids.removeValue(forKey: uuid)
            let action = CXEndCallAction.init(call: UUID(uuidString: uuid)!)
            let transaction = CXTransaction(action: action)
            self.callVC?.request(transaction, completion: { _ in
                
            })
        }
        self.agoraKit?.leaveChannel(nil)
        AgoraRtcEngineKit.destroy()
    }
    
    func didActivateAudioSession() {
        self.agoraKit?.enableAudio()
        self.agoraKit?.setEnableSpeakerphone(false)
        self.agoraKit?.enable(inEarMonitoring: true)
    }
}
