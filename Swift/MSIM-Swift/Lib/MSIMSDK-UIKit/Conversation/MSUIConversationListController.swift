//
//  MSUIConversationListController.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/10.
//

import UIKit
import MJRefresh
import MSIMSDK

public protocol MSUIConversationListControllerDelegate: NSObjectProtocol {
    
    func didSelectConversation(cell: MSUIConversationCell)
    func conversationListUnreadCountChanged()
}

open class MSUIConversationListController: UIViewController {

    public var tableView: UITableView = UITableView(frame: .zero, style: .plain)
    
    public var dataList: [MSUIConversationCellData] = []
    
    public weak var delegate: MSUIConversationListControllerDelegate?
    
    private var lastConvSign: Int = 0
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadConversation()
        
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        addNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension MSUIConversationListController {
    
    func setupViews() {
        view.backgroundColor = UIColor.d_color(light: MSMcros.TController_Background_Color, dark: MSMcros.TController_Background_Color_Dark)
        tableView.tableFooterView = UIView()
        tableView.register(MSUIConversationCell.self, forCellReuseIdentifier: "TConversationCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 103
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        tableView.contentInset = UIEdgeInsets(top: UIScreen.status_navi_height, left: 0, bottom: UIScreen.tabBarHeight, right: 0)
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.separatorColor = UIColor.d_color(light: MSMcros.TCell_separatorColor, dark: MSMcros.TCell_separatorColor_Dark)
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {[weak self] in
            self?.loadConversation()
        })
        tableView.mj_footer?.isHidden = true
        view.addSubview(tableView)
    }
    
    func addNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNewConvUpdate), name: NSNotification.Name.init(rawValue: MSUIKitNotification_ConversationUpdate), object: nil)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init(rawValue: MSUIKitNotification_ProfileUpdate), object: nil, queue: OperationQueue.main) {[weak self] note in
            self?.profileUpdate(note: note)
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init(rawValue: MSUIKitNotification_ConversationDelete), object: nil, queue: OperationQueue.main) {[weak self] note in
            self?.onConversationDelete(note: note)
        }
    }
    
    func loadConversation() {
        MSIMManager.sharedInstance().getConversationList(lastConvSign) { convs, nexSeq, isFinished in
            
            self.lastConvSign = nexSeq
            self.updateConversation(convs: convs)
            if isFinished {
                self.tableView.mj_footer?.endRefreshingWithNoMoreData()
            }else {
                self.tableView.mj_footer?.endRefreshing()
            }
        } fail: { _, _ in
            self.tableView.mj_footer?.endRefreshing()
        }
    }
    
    func removeConversation(conv: MSUIConversationCellData) {
        
        tableView.beginUpdates()
        let index = dataList.firstIndex(of: conv)!
        dataList.remove(at: index)
        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .none)
        tableView.endUpdates()
        updateTabbarUnreadCount()
    }
    
    func updateTabbarUnreadCount() {
        delegate?.conversationListUnreadCountChanged()
    }
    
    func updateConversation(convs: [MSIMConversation]) {
        
        // 更新 UI 会话列表，如果 UI 会话列表有新增的会话，就替换，如果没有，就新增
        for (_,conv) in convs.enumerated() {
            var isExist: Bool = false
            for (_,localConv) in dataList.enumerated() {
                if localConv.conv.conversation_id == conv.conversation_id {
                    localConv.conv = conv
                    isExist = true
                    break
                }
            }
            if isExist == false {
                let data = MSUIConversationCellData(conv: conv)
                dataList.append(data)
            }
        }
        // UI 会话列表根据 lastMessage 时间戳重新排序
        sortDataList(list: dataList)
        DispatchQueue.main.async {
            self.tableView.mj_footer?.isHidden = self.dataList.count <= 10
            self.tableView.reloadData()
        }
    }
    
    func sortDataList(list: [MSUIConversationCellData]) {
        
        self.dataList = list.sorted(by: {$0.time > $1.time})
    }
    
    @objc func onNewConvUpdate(note: Notification) {
        
        if let list = note.object as? [MSIMConversation] {
            updateConversation(convs: list)
            updateTabbarUnreadCount()
        }
    }
    
    func onConversationDelete(note: Notification) {
        if let partner_id = note.object as? String {
            for data in dataList {
                if data.conv.partner_id == partner_id {
                    removeConversation(conv: data)
                    break
                }
            }
        }
    }
    
    func profileUpdate(note: Notification) {
        tableView.reloadData()
    }
}

extension MSUIConversationListController: UITableViewDataSource,UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TConversationCell", for: indexPath) as! MSUIConversationCell
        cell.configWithData(convData: dataList[indexPath.row])
        return cell
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    public func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return Bundle.bf_localizedString(key: "Delete")
    }
    
    public func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let data = dataList[indexPath.row]
            MSIMManager.sharedInstance().delete(data.conv) {
                
                self.removeConversation(conv: data)
            } failed: { code, desc in
                MSHelper.showToastFailWithText(text: desc ?? "")
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! MSUIConversationCell
        delegate?.didSelectConversation(cell: cell)
    }
}
