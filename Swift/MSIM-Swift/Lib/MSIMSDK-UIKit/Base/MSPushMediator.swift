//
//  MSPushMediator.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/3.
//

import UIKit
import MSIMSDK
import PushKit
import CallKit
import AVFoundation
import Intents

protocol MSPushMediatorDelegate: NSObjectProtocol {
    
    ///点击推送消息进入的app,可以做些跳转操作
    func didReceiveNotificationResponse(userInfo: [String: Any])
}

class MSPushMediator: NSObject, UNUserNotificationCenterDelegate {
    
    static let shared = MSPushMediator()
    
    var voipRegistry: PKPushRegistry?
    
    var voipProvider: CXProvider?
    
    weak var delegate: MSPushMediatorDelegate?
    
    private override init() {}
    
    func applicationDidFinishLaunchingWithOptions(launchOptions: [UIApplication.LaunchOptionsKey: Any]?,imConfig: IMSDKConfig) {
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.badge,.sound,.alert]) { granted, error in
            
            DispatchQueue.main.async {
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }else {
                    print("用户没有开通通知权限!")
                    let voipToken = UserDefaults.standard.string(forKey: kVoipTokenKey)
                    MSIMManager.sharedInstance().refreshPushToken(nil, voipToken: voipToken)
                }
            }
        }
        ///用户手动去设置界面更改了推送权限
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .authorized {
                    UIApplication.shared.registerForRemoteNotifications()
                }else {
                    print("用户没有开通通知权限!")
                    let voipToken = UserDefaults.standard.string(forKey: kVoipTokenKey)
                    MSIMManager.sharedInstance().refreshPushToken(nil, voipToken: voipToken)
                }
            }
        }
        if let userInfo = launchOptions?[.remoteNotification] as? [String: Any] {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.delegate?.didReceiveNotificationResponse(userInfo: userInfo)
            }
        }
        if imConfig.voipEnable {
            registerForVoIPPushes()
        }else {
            UserDefaults.standard.removeObject(forKey: kVoipTokenKey)
        }
    }
    
    private func registerForVoIPPushes() {
        self.voipRegistry = PKPushRegistry.init(queue: .main)
        self.voipRegistry?.delegate = self
        self.voipRegistry?.desiredPushTypes = [.voIP]
        
        if #available(iOS 14.0, *) {
            let config = CXProviderConfiguration()
            config.maximumCallsPerCallGroup = 1
            config.supportsVideo = true
            config.supportedHandleTypes = Set([.generic,.phoneNumber])
            self.voipProvider = CXProvider.init(configuration: config)
            self.voipProvider?.setDelegate(self, queue: .main)
        } else {
            let config = CXProviderConfiguration.init(localizedName: "voipCall")
            config.maximumCallsPerCallGroup = 1
            config.supportsVideo = true
            config.supportedHandleTypes = Set([.generic,.phoneNumber])
            config.iconTemplateImageData = UIImage.pngData(UIImage(named: "live_broadcast_camera_on") ?? UIImage())()!
            self.voipProvider = CXProvider.init(configuration: config)
            self.voipProvider?.setDelegate(self, queue: .main)
        }
    }
    
    ///** 请求APNs建立连接并获得deviceToken*/
    func didRegisterForRemoteNotifications(deviceToken: Data) {
        
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("APNS TOKEN: \(token)")
        UserDefaults.standard.setValue(token, forKey: kApnsTokenKey)
        let voipToken = UserDefaults.standard.string(forKey: kVoipTokenKey)
        MSIMManager.sharedInstance().refreshPushToken(token, voipToken: voipToken)
    }
    
    func didFailToRegisterForRemoteNotifications(error: Error) {
        print("did Fail To Register For Remote Notifications With Error: \(error)")
        let voipToken = UserDefaults.standard.string(forKey: kVoipTokenKey)
        MSIMManager.sharedInstance().refreshPushToken(nil, voipToken: voipToken)
    }

    ///App在前台运行时收到推送消息的回调
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler(UNNotificationPresentationOptions.alert)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let noti = response.notification
        if let userInfo = noti.request.content.userInfo as? [String: Any] {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.delegate?.didReceiveNotificationResponse(userInfo: userInfo)
            }
        }
    }
    func applicationContinueUserActivity(userActivity: NSUserActivity) {
        
        if MSIMTools.sharedInstance().user_id == nil {
            return
        }
        guard let intent = userActivity.interaction?.intent as? INStartCallIntent else {return}
        guard let room_id = intent.contacts?.first?.personHandle?.value else {return}
        guard let partner_id = MSCallManager.getCreatorFrom(room_id: room_id) else {return}
        if (intent.callCapability == .audioCall) {//语音通话
            MSCallManager.shared.callToPartner(partner_id: partner_id, creator: MSIMTools.sharedInstance().user_id!, callType: .voice, action: .call, room_id: nil)
        }else if (intent.callCapability == .videoCall) {//视频通话
            MSCallManager.shared.callToPartner(partner_id: partner_id, creator: MSIMTools.sharedInstance().user_id!, callType: .video, action: .call, room_id: nil)
        }
    }
}

extension MSPushMediator: PKPushRegistryDelegate {
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        
        let voipData = pushCredentials.token
        let voipTokenString = voipData.map { String(format: "%02.2hhx", $0) }.joined()
        
        print("VOIP TOKEN: \(voipTokenString)")
        UserDefaults.standard.setValue(voipTokenString, forKey: kVoipTokenKey)
        let anpsToken = UserDefaults.standard.string(forKey: kApnsTokenKey)
        MSIMManager.sharedInstance().refreshPushToken(anpsToken, voipToken: voipTokenString)
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("获取VOIP TOKEN 失败: \(type)")
        UserDefaults.standard.removeObject(forKey: kVoipTokenKey)
        let apnsToken = UserDefaults.standard.string(forKey: kApnsTokenKey)
        MSIMManager.sharedInstance().refreshPushToken(apnsToken, voipToken: nil)
    }
    
    //{
    //"aps": {
    //    "alert" : {
    //        "title": "this is a push title",
    //        "body": "this is a push body"
    //    }
    //    "mutable-content" : 1
    //},
    //"msim": {
    //     "from": 123,
    //     "to": 456,
    //     "mtype": 0, //消息type
    //     "body": "custom push data" //如果是自定义消息 则有这个值为body中的内容
    //},
    //}
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        
        self.startBgTask()
        guard let apsDic = payload.dictionaryPayload["aps"] as? [String: Any],
              let alertDic = apsDic["alert"] as? [String: Any],
              let title = alertDic["title"] as? String,
              let msimDic = payload.dictionaryPayload["msim"] as? [String: Any],
              let fromUid = msimDic["from"] as? Int,
              let bodyJson = msimDic["body"] as? String,
              let bodyDic = (bodyJson as NSString).el_convertToDictionary() as? [String: Any],
              let subType = bodyDic["type"] as? Int,
              let action = bodyDic["event"] as? Int,
              let room_id = bodyDic["room_id"] as? String else{
                  return
              }
                
        let callType: MSCallType = (subType == MSIMCustomSubType.VoiceCall.rawValue ? .voice : .video)
        if action == CallAction.call.rawValue {
            let uuid = MSVoipCenter.shared.createUUIDWithRoomID(room_id: room_id, fromUid: String(fromUid), callType: callType)
            
            let update = CXCallUpdate()
            update.localizedCallerName = title
            update.supportsGrouping = false
            update.supportsDTMF = false
            update.supportsHolding = false
            update.hasVideo = callType == .video
            let handle = CXHandle.init(type: .phoneNumber, value: room_id)
            update.remoteHandle = handle
            
            self.voipProvider?.reportNewIncomingCall(with: UUID(uuidString: uuid)!, update: update, completion: { _ in
                
            });
        }
        if action == CallAction.cancel.rawValue || action == CallAction.end.rawValue || action == CallAction.timeout.rawValue {
            NotificationCenter.default.post(name: NSNotification.Name.init("kRecieveNeedToDismissVoipView"), object: nil)
        }
        completion()
    }
    
    // 开启后台延时
    private func startBgTask() {
        let application = UIApplication.shared
        var taskID: UIBackgroundTaskIdentifier?
        taskID = UIApplication.shared.beginBackgroundTask {
            application.endBackgroundTask(taskID!)
        }
    }
}

extension MSPushMediator: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        
    }
    
    func providerDidBegin(_ provider: CXProvider) {
        
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        MSVoipCenter.shared.acceptCallWithUuid(uuid: action.callUUID.uuidString)
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        MSVoipCenter.shared.endCallWithUuid(uuid: action.callUUID.uuidString)
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        MSVoipCenter.shared.muteCall(isMute: action.isMuted,uuid: action.callUUID.uuidString)
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXPlayDTMFCallAction) {
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetGroupCallAction) {
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
        action.fail()
    }
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        MSVoipCenter.shared.didActivateAudioSession()
    }
    
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        
    }
}
