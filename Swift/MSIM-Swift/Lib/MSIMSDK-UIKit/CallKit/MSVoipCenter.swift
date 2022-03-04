//
//  MSVoipCenter.swift
//  MSIM-Swift
//
//  Created by benny wang on 2022/3/4.
//

import UIKit
import CallKit


struct CallItem {
    var room_id: String
    var from: String
    var call_type: MSCallType
}
class MSVoipCenter: NSObject {
    
    static let shared: MSVoipCenter = MSVoipCenter()
    
    var callVC: CXCallController?
    
    var uuids: [String: CallItem] = [:]
    
    
    func createUUIDWithRoomID(room_id: String,fromUid: String,callType: MSCallType) -> String {
        
        let uuid = UUID().uuidString
        self.uuids[uuid] = CallItem(room_id: room_id, from: fromUid, call_type: callType)
        self.callVC = CXCallController(queue: .main)
        return uuid
    }
    
    func startCallWithUuid(uuid: String) {
        if let item = self.uuids[uuid] {
            let creator = MSCallManager.getCreatorFrom(room_id: item.room_id)
            MSCallManager.shared.recieveCall(from: item.from, creator: creator!, callType: item.call_type, action: .call, room_id: item.room_id)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            MSCallManager.shared.acceptBtnDidClick(type: item.call_type)
            }
        }
    }
    
    func endCallWithUuid(uuid: String) {
        if let item = self.uuids[uuid] {
            let creator = MSCallManager.getCreatorFrom(room_id: item.room_id)
            MSCallManager.shared.callToPartner(partner_id: item.from, creator: creator!, callType: item.call_type, action: .reject, room_id: item.room_id)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                MSCallManager.shared.rejectBtnDidClick(type: item.call_type)
            }
        }
    }
    
    func muteCall(isMute: Bool) {
        MSCallManager.shared.setMuTeCall(isMute: isMute)
    }
    
    func hangupBtnDidClick(type: MSCallType,room_id: String) {
        var session: UUID?
        for(key,value) in self.uuids {
            if value.room_id == room_id {
                session = UUID(uuidString: key)
                break
            }
        }
        if session != nil {
            self.uuids.removeValue(forKey: session!.uuidString)
            let action = CXEndCallAction(call: session!)
            let transation = CXTransaction(action: action)
            self.callVC?.request(transation, completion: { _ in
                
            })
        }
    }
    
    func cancelBtnDidClick(type: MSCallType,room_id: String) {
        var session: UUID?
        for(key,value) in self.uuids {
            if value.room_id == room_id {
                session = UUID(uuidString: key)
                break
            }
        }
        if session != nil {
            self.uuids.removeValue(forKey: session!.uuidString)
            let action = CXEndCallAction(call: session!)
            let transation = CXTransaction(action: action)
            self.callVC?.request(transation, completion: { _ in
                
            })
        }
    }
}
