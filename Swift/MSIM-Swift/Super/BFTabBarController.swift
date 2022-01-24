//
//  BFTabBarController.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/7/28.
//

import UIKit
import MSIMSDK


class BFTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
        tabBar.unselectedItemTintColor = .gray
        tabBar.tintColor = .darkGray
        
        let item = UITabBarItem.appearance()
        item.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)], for: .normal)
        item.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)], for: .selected)
        
        let homeVC = BFHomeController()
        homeVC.tabBarItem.title = Bundle.bf_localizedString(key: "Home_tab")
        homeVC.tabBarItem.image = UIImage(named: "home_tab_nor")?.withRenderingMode(.alwaysOriginal)
        homeVC.tabBarItem.selectedImage = UIImage(named: "home_tab_sel")?.withRenderingMode(.alwaysOriginal)
        let homeNav = BFNavigationController(rootViewController: homeVC)
        addChild(homeNav)
        
        let tactVC = BFDiscoveryController()
        tactVC.tabBarItem.title = Bundle.bf_localizedString(key: "Discovery_tab")
        tactVC.tabBarItem.image = UIImage(named: "contact_normal")?.withRenderingMode(.alwaysOriginal)
        tactVC.tabBarItem.selectedImage = UIImage(named: "contact_selected")?.withRenderingMode(.alwaysOriginal)
        let tactNav = BFNavigationController(rootViewController: tactVC)
        addChild(tactNav)
        
        let convVC = BFConversationListController()
        convVC.tabBarItem.title = Bundle.bf_localizedString(key: "Message_tab")
        convVC.tabBarItem.image = UIImage(named: "session_normal")?.withRenderingMode(.alwaysOriginal)
        convVC.tabBarItem.selectedImage = UIImage(named: "session_selected")?.withRenderingMode(.alwaysOriginal)
        let convNav = BFNavigationController(rootViewController: convVC)
        addChild(convNav)
        
        let profileVC = BFEditProfileController()
        profileVC.tabBarItem.title = Bundle.bf_localizedString(key: "Profile_tab")
        profileVC.tabBarItem.image = UIImage(named: "myself_normal")?.withRenderingMode(.alwaysOriginal)
        profileVC.tabBarItem.selectedImage = UIImage(named: "myself_selected")?.withRenderingMode(.alwaysOriginal)
        let profileNav = BFNavigationController(rootViewController: profileVC)
        addChild(profileNav)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onUserLogStatusChanged), name: NSNotification.Name.init(rawValue: MSUIKitNotification_UserStatusListener), object: nil)
    }
    
    @objc func onUserLogStatusChanged(note: Notification) {
        
        if let status = note.object as? Int,let userStatus = MSIMUserStatus.init(rawValue: UInt(status)) {
            switch userStatus {
            case .IMUSER_STATUS_FORCEOFFLINE:  //用户被强制下线
                
                let alert = UIAlertController(title: "提醒", message: "您的帐号已经在其它的设备上登录", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: {[weak self] _ in
                    self?.logout()
                }))
                self.present(alert, animated: true, completion: nil)
                
            case .IMUSER_STATUS_SIGEXPIRED:
                
                let alert = UIAlertController(title: "提醒", message: "您的登录授权已过期，请重新登录", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: {[weak self] _ in
                    self?.logout()
                }))
                self.present(alert, animated: true, completion: nil)
                
            default:
                break
            }
        }
    }
    
    private func logout() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.window?.rootViewController = BFNavigationController(rootViewController: BFLoginController())
        }
    }
}
