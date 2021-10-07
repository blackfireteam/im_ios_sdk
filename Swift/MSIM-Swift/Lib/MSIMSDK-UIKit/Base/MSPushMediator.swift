//
//  MSPushMediator.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/3.
//

import UIKit
import MSIMSDK


protocol MSPushMediatorDelegate: NSObjectProtocol {
    
    ///点击推送消息进入的app,可以做些跳转操作
    func didReceiveNotificationResponse(userInfo: [String: Any])
}

class MSPushMediator: NSObject, UNUserNotificationCenterDelegate {
    
    static let shared = MSPushMediator()
    
    var device_token: String?
    
    weak var delegate: MSPushMediatorDelegate?
    
    private override init() {}
    
    func applicationDidFinishLaunchingWithOptions(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.badge,.sound,.alert]) { granted, error in
            
            DispatchQueue.main.async {
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }else {
                    print("用户没有开通通知权限!")
                    MSIMManager.sharedInstance().refreshPushDeviceToken(nil)
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
                    MSIMManager.sharedInstance().refreshPushDeviceToken(nil)
                }
            }
        }
        if let userInfo = launchOptions?[.remoteNotification] as? [String: Any] {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.delegate?.didReceiveNotificationResponse(userInfo: userInfo)
            }
        }
    }
    
    ///** 请求APNs建立连接并获得deviceToken*/
    func didRegisterForRemoteNotifications(deviceToken: Data) {
        
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("注册APNS成功\(token)")
        UserDefaults.standard.setValue(token, forKey: "ms_device_token")
        MSIMManager.sharedInstance().refreshPushDeviceToken(token)
    }
    
    func didFailToRegisterForRemoteNotifications(error: Error) {
        print("did Fail To Register For Remote Notifications With Error: \(error)")
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
}
