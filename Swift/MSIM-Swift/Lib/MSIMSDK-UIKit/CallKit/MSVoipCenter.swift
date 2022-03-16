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
            self.currentCalling = uuid
            MSCallManager.shared.recieveCall(from: item.from, creator: item.from, callType: item.call_type, action: .call, room_id: item.room_id)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                MSCallManager.shared.autoAcceptVoipCall(type: item.call_type,room_id: item.room_id)
            }
        }
    }
    
    func endCallWithUuid(uuid: String) {
        if let item = self.uuids[uuid] {
            if self.currentCalling == nil {
                MSCallManager.shared.callToPartner(partner_id: item.from, creator: item.from, callType: item.call_type, action: .reject, room_id: item.room_id)
            }else {
                MSCallManager.shared.callVC.recieveVoipEnd(type: item.call_type,room_id: item.room_id)
            }
            self.currentCalling = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
            }
        }
    }
    
    func muteCall(isMute: Bool, uuid: String) {
        
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
    }
    
    func didActivateAudioSession() {
        MSCallManager.shared.callVC.didActivateAudioSession()
    }
}
