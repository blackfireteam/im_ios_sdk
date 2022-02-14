//
//  AppDelegate.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/7/28.
//

import UIKit
import MSIMSDK
import PushKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    

    var window: UIWindow?

    let pushRegistry = PKPushRegistry(queue: .main)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.makeKeyAndVisible()
        
        pushRegistry.delegate = self
        pushRegistry.desiredPushTypes = [.voIP]
        
        /// im sdk初始化
        let imConfig = IMSDKConfig.default()
        imConfig.logEnable = true
        imConfig.uploadMediator = MSUploadManager.shared // im内部用到的上传服务，用户可以自定义
        MSIMKit.sharedInstance().initWith(imConfig)
        
        if MSIMTools.sharedInstance().user_id != nil {
            window?.rootViewController = BFTabBarController()
        }else {
            window?.rootViewController = BFNavigationController(rootViewController: BFLoginController())
        }
        
        MSPushMediator.shared.applicationDidFinishLaunchingWithOptions(launchOptions: launchOptions)
        MSPushMediator.shared.delegate = self
        return true
    }
    
    ///** 请求APNs建立连接并获得deviceToken*/
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        MSPushMediator.shared.didRegisterForRemoteNotifications(deviceToken: deviceToken)
    }
    
    ///获取device-token失败
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        MSPushMediator.shared.didFailToRegisterForRemoteNotifications(error: error)
    }
    
    ///当 payload 包含参数 content-available=1 时，该推送就是静默推送，静默推送不会显示任何推送消息，当 App 在后台挂起时，静默推送的回调方法会被执行，开发者有 30s 的时间内在该回调方法中处理一些业务逻辑，并在处理完成后调用 fetchCompletionHandler
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
}

extension AppDelegate: MSPushMediatorDelegate {
    
    /** 点击推送消息进入的app,可以做些跳转操作*/
    func didReceiveNotificationResponse(userInfo: [String : Any]) {
        
        guard let _ = userInfo["data"] as? [String: Any] else { return}
        guard let _ = MSIMTools.sharedInstance().user_id else {return}
        if let tabbar = window?.rootViewController as? BFTabBarController {
            tabbar.selectedIndex = 2
        }
    }
}


extension AppDelegate: PKPushRegistryDelegate {
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        
        
        let deviceToken = pushCredentials.token.map { String(format: "%02.2hhx", $0) }.joined()
        print("\(#function) token is: \(deviceToken)")
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        
        print("\(#function) incoming voip notfication: \(payload.dictionaryPayload)")
        if let uuidString = payload.dictionaryPayload["UUID"] as? String,
            let handle = payload.dictionaryPayload["handle"] as? String,
            let uuid = UUID(uuidString: uuidString) {
            
//            OTAudioDeviceManager.setAudioDevice(OTDefaultAudioDevice.sharedInstance())
                
            // display incoming call UI when receiving incoming voip notification
            let backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
            self.displayIncomingCall(uuid: uuid, handle: handle, hasVideo: false) { _ in
                UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
            }
        }
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("\(#function) token invalidated")
    }
        
    /// Display the incoming call to the user
    func displayIncomingCall(uuid: UUID, handle: String, hasVideo: Bool = false, completion: ((NSError?) -> Void)? = nil) {
//        providerDelegate?.reportIncomingCall(uuid: uuid, handle: handle, hasVideo: hasVideo, completion: completion)
    }
}
