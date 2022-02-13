//
//  BFConversationListController.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/10.
//

import UIKit
import MSIMSDK


class BFConversationListController: BFBaseViewController {

    lazy var titleView: BFNaviBarIndicatorView = BFNaviBarIndicatorView()
    
    lazy var conVC: MSUIConversationListController = MSUIConversationListController()
    
    lazy var convHeader: BFConversationHeaderView = BFConversationHeaderView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: 103))
    
    var networkBarView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addChild(conVC)
        view.addSubview(conVC.view)
        setupNavigation()
        
        self.conVC.tableView.tableHeaderView = self.convHeader
        let tap = UITapGestureRecognizer(target: self, action: #selector(chatRoomTap))
        self.convHeader.addGestureRecognizer(tap)
        self.convHeader.reloadData()
        
        /// 当前的连接状态
        let status = MSIMManager.sharedInstance().connStatus
        updateTitleView(status: status)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        conVC.delegate = self
        addNotifications()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNavigation() {
        titleView.setTitle(title: "MESSAGE")
        navigationItem.titleView = titleView
        updateTitleView(status: MSIMManager.sharedInstance().connStatus)
    }

    private func addNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNetworkChanged), name: NSNotification.Name.init(rawValue: MSUIKitNotification_ConnListener), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(conversationSyncStart), name: NSNotification.Name.init(rawValue: MSUIKitNotification_ConversationSyncStart), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(conversationSyncFinish), name: NSNotification.Name.init(rawValue: MSUIKitNotification_ConversationSyncFinish), object: nil)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init(rawValue: MSUIKitNotification_ChatRoomConv_update), object: nil, queue: .main) {[weak self] note in
            self?.onChatRoomConvUpdate(note: note)
        }
    }
    
    private func updateTitleView(status: MSIMNetStatus) {
        switch status {
        case .IMNET_STATUS_SUCC:
            titleView.stopAnimating()
            titleView.setTitle(title: "MESSAGE")
        case .IMNET_STATUS_CONNECTING:
            hideNetworkDisconnetBar()
            titleView.startAnimating()
            titleView.setTitle(title: "连接中...")
        case .IMNET_STATUS_DISCONNECT:
            titleView.stopAnimating()
            titleView.setTitle(title: "MESSAGE(断开连接)")
            showNetworkDisconnetBar()
        case .IMNET_STATUS_CONNFAILED:
            titleView.stopAnimating()
            titleView.setTitle(title: "MESSAGE(连接失败)")
        default:
            break
        }
    }
    
    @objc func onNetworkChanged(note: Notification) {
        if let statusInt = note.object as? Int,let status = MSIMNetStatus(rawValue: UInt(statusInt)) {
            updateTitleView(status: status)
        }
    }
    
    @objc func conversationSyncStart() {
        titleView.startAnimating()
        titleView.setTitle(title: "拉取中...")
    }
    
    @objc func conversationSyncFinish() {
        titleView.stopAnimating()
        titleView.setTitle(title: "MESSAGE")
        updateTabbarUnreadCount()
    }
    
    private func hideNetworkDisconnetBar() {
        conVC.tableView.tableHeaderView = nil
        networkBarView = nil
    }
    
    private func showNetworkDisconnetBar() {
        networkBarView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: 40))
        networkBarView?.backgroundColor = .red
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.width - 20, height: 40))
        label.font = .systemFont(ofSize: 15)
        label.textColor = .white
        label.text = "当前网络不可用，请检查网络设置"
        networkBarView?.addSubview(label)
        conVC.tableView.tableHeaderView = networkBarView
    }
    
    private func updateTabbarUnreadCount() {
        let count = MSConversationProvider.shared().allUnreadCount()
        DispatchQueue.main.async {
            self.tabBarItem.badgeValue = count > 0 ? "\(count)" : nil
        }
    }
    
    /// 进入聊天室
    @objc func chatRoomTap() {
        let vc = BFChatRoomViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func onChatRoomConvUpdate(note: Notification) {
        self.convHeader.reloadData()
    }
}

extension BFConversationListController: MSUIConversationListControllerDelegate {
    func didSelectConversation(cell: MSUIConversationCell) {
        
        if let uid = cell.convData?.conv.partner_id {
            let vc = BFChatViewController()
            vc.partner_id = uid
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func conversationListUnreadCountChanged() {
        updateTabbarUnreadCount()
    }
}
