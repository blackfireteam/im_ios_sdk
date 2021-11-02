//
//  MSMessageController.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/31.
//

import UIKit
import MSIMSDK
import MJRefresh


let MAX_MESSAGE_SEP_DLAY: Int = 5 * 60
public protocol MSMessageControllerDelegate: NSObjectProtocol {
    
    ///每条新消息在进入气泡展示区之前，都会通知给您
    func prepareForMessage(controller: MSMessageController,elem: MSIMElem) -> MSMessageCellData?
    ///您可以通过该回调实现：根据传入的 data 初始化消息气泡并进行显示
    func onShowMessageData(controller: MSMessageController,cellData: MSMessageCellData) -> MSMessageCell.Type?
    ///收到信令消息
    func onRecieveSignalMessage(controller: MSMessageController,elems: [MSIMElem])
    ///您可以通过该回调实现：重置 InputControoler，收起键盘
    func didTapInMessageController(controller: MSMessageController)
    ///您可以通过该回调实现：跳转到对应用户的详细信息界面
    func onSelectMessageAvatar(controller: MSMessageController,cell: MSMessageCell)
    ///点击消息内容委托
    func onSelectMessageContent(controller: MSMessageController,cell: MSMessageCell)
    ///显示长按菜单前的回调函数
    func willShowMenuInCell(controller: MSMessageController,view: UIView) -> Bool
    ///隐藏长按菜单后的回调函数
    func didHideMenuInMessageController(controller: MSMessageController)
    
}

public class MSMessageController: UITableViewController {

    public weak var delegate: MSMessageControllerDelegate?
    
    public var partner_id: String!
    
    public private (set) var uiMsgs: [MSMessageCellData] = []
    
    public func scrollToBottom(animate: Bool) {
        if uiMsgs.count > 0 {
            tableView.scrollToRow(at: IndexPath(row: uiMsgs.count-1, section: 0), at: .bottom, animated: animate)
        }
    }
    
    private var heightCache: [CGFloat] = []
    
    private var isScrollBottom: Bool = false
    
    private var isShowKeyboard: Bool = false
    
    private var firstLoad: Bool = true
    
    private var isLoadingMsg: Bool = false
    
    private var noMoreMsg: Bool = false
    
    private var msgForDate: MSIMElem?
    
    private var menuUIMsg: MSMessageCellData?
    
    private var last_msg_sign: Int = 0
    
    private var countTipView: MSNoticeCountView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        addNotifications()
        setupUI()
        loadMessages()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if countTipView.superview == nil {
            self.parent!.view.addSubview(countTipView)
        }
        countTipView.frame = CGRect(x: tableView.width - 30 - 10, y: tableView.height - 30 - 10, width: 30, height: 30)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("\(self) dealloc")
    }

    private func addNotifications() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init(MSUIKitNotification_MessageListener), object: nil, queue: .main) {[weak self] note in
            self?.onNewMessage(note: note)
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init(MSUIKitNotification_SignalMessageListener), object: nil, queue: .main) {[weak self] note in
            self?.onSignalMessage(note: note)
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init(MSUIKitNotification_MessageSendStatusUpdate), object: nil, queue: .main) {[weak self] note in
            self?.messageStatusUpdate(note: note)
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init(MSUIKitNotification_ProfileUpdate), object: nil, queue: .main) {[weak self] note in
            self?.profileUpdate(note: note)
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init(MSUIKitNotification_MessageRecieveRevoke), object: nil, queue: .main) {[weak self] note in
            self?.recieveRevokeMessage(note: note)
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init(MSUIKitNotification_MessageReceipt), object: nil, queue: .main) {[weak self] note in
            self?.profileUpdate(note: note)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupUI() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapViewController))
        view.addGestureRecognizer(tap)
        
        tableView.scrollsToTop = false
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.d_color(light: MSMcros.TController_Background_Color, dark: MSMcros.TController_Background_Color_Dark)
        tableView.register(MSTextMessageCell.self, forCellReuseIdentifier: MSMcros.TTextMessageCell_ReuseId)
        tableView.register(MSImageMessageCell.self, forCellReuseIdentifier: MSMcros.TImageMessageCell_ReuseId)
        tableView.register(MSSystemMessageCell.self, forCellReuseIdentifier: MSMcros.TSystemMessageCell_ReuseId)
        tableView.register(MSVideoMessageCell.self, forCellReuseIdentifier: MSMcros.TVideoMessageCell_ReuseId)
        tableView.register(MSVoiceMessageCell.self, forCellReuseIdentifier: MSMcros.TVoiceMessageCell_ReuseId)
        
        let header = MJRefreshNormalHeader {[weak self] in
            self?.loadMessages()
        }
        header.lastUpdatedTimeLabel?.isHidden = true
        header.stateLabel?.isHidden = true
        self.tableView.mj_header = header
        
        countTipView = MSNoticeCountView()
        countTipView.isHidden = true
        countTipView.delegate = self
    }
    
    private func loadMessages() {
        if isLoadingMsg || noMoreMsg {return}
        isLoadingMsg = true
        let msgCount: Int32 = 20
        MSIMManager.sharedInstance().getC2CHistoryMessageList(self.partner_id, count: msgCount, lastMsg: self.last_msg_sign) { msgs, isFinished in
            
            let tempElems = self.deduplicateMessage(elems: msgs)
            self.tableView.mj_header?.endRefreshing()
            self.last_msg_sign = msgs.last?.msg_sign ?? 0
            if isFinished {
                self.noMoreMsg = true
                self.tableView.mj_header?.isHidden = true
            }
            let results = self.transUIMsgFromIMMsg(elems: tempElems)
            if results.count != 0 {
                self.uiMsgs.insert(contentsOf: results, at: 0)
                self.heightCache.removeAll()
                self.tableView.reloadData()
                self.tableView.layoutIfNeeded()
                if self.firstLoad == false {
                    var visibleHeight: CGFloat = 0
                    for i in 0..<results.count {
                        let indexPath = IndexPath(row: i, section: 0)
                        visibleHeight += self.tableView(self.tableView, heightForRowAt: indexPath)
                    }
                    self.tableView.scrollRectToVisible(CGRect(x: 0, y: self.tableView.contentOffset.y + visibleHeight, width: self.tableView.width, height: self.tableView.height), animated: false)
                }else {
                    if let conv = MSConversationProvider.shared().providerConversation(self.partner_id),conv.unread_count > 0 {
                        self.readedReport(datas: results)
                    }
                }
            }
            self.isLoadingMsg = false
            self.firstLoad = false
            
        } fail: { cdoe, desc in
            self.isLoadingMsg = false
            self.firstLoad = false
            self.tableView.mj_header?.endRefreshing()
        }
    }
    
    private func transUIMsgFromIMMsg(elems: [MSIMElem]) -> [MSMessageCellData] {
        
        var uiMsgs: [MSMessageCellData] = []
        for k in (0..<elems.count).reversed() {
            let elem = elems[k]
            let dateMsg = transSystemMsgFromDate(date: elem.msg_sign)
            
            var data: MSMessageCellData?
            if let cellData = self.delegate?.prepareForMessage(controller: self, elem: elem) {
                if dateMsg != nil {
                    self.msgForDate = elem
                    uiMsgs.append(dateMsg!)
                }
                uiMsgs.append(cellData)
                continue
            }
            if elem.type == .MSG_TYPE_REVOKE {//撤回的消息
                let revoke = MSSystemMessageCellData(direction: .inComing)
                if elem.isSelf() {
                    revoke.content = Bundle.bf_localizedString(key: "TUIKitMessageTipsYouRecallMessage")
                }else {
                    revoke.content = Bundle.bf_localizedString(key: "TUIkitMessageTipsOthersRecallMessage")
                }
                revoke.elem = elem
                data = revoke
            }else if elem.type == .MSG_TYPE_TEXT {
                let textElem = elem as! MSIMTextElem
                let textMsg = MSTextMessageCellData(direction: elem.isSelf() ? .outGoing : .inComing)
                textMsg.showName = true
                textMsg.content = textElem.text
                textMsg.elem = textElem
                data = textMsg
            }else if elem.type == .MSG_TYPE_IMAGE {
                let imageMsg = MSImageMessageCellData(direction: elem.isSelf() ? .outGoing : .inComing)
                imageMsg.showName = true
                imageMsg.elem = elem
                data = imageMsg
            }else if elem.type == .MSG_TYPE_VIDEO {
                let videoMsg = MSVideoMessageCellData(direction: elem.isSelf() ? .outGoing : .inComing)
                videoMsg.showName = true
                videoMsg.elem = elem
                data = videoMsg
            }else if elem.type == .MSG_TYPE_VOICE {
                let voiceMsg = MSVoiceMessageCellData(direction: elem.isSelf() ? .outGoing : .inComing)
                voiceMsg.showName = true
                voiceMsg.elem = elem
                data = voiceMsg
            }else {
                let unknowData = MSSystemMessageCellData(direction: .inComing)
                unknowData.content = Bundle.bf_localizedString(key: "TUIkitMessageTipsUnknowMessage")
                unknowData.elem = elem
                data = unknowData
            }
            if dateMsg != nil {
                self.msgForDate = elem
                uiMsgs.append(dateMsg!)
            }
            uiMsgs.append(data!)
        }
        return uiMsgs
    }
    
    private func transSystemMsgFromDate(date: Int) -> MSSystemMessageCellData? {
        
        if self.msgForDate == nil || labs(date - self.msgForDate!.msg_sign) / 1000 / 1000 > MAX_MESSAGE_SEP_DLAY {
            let system = MSSystemMessageCellData(direction: .inComing)
            system.content = Date(timeIntervalSince1970: TimeInterval(date / 1000 / 1000)).ms_messageString()
            return system
        }
        return nil
    }
    
    private func readedReport(datas: [MSMessageCellData]) {
        MSIMManager.sharedInstance().markC2CMessage(asRead: self.partner_id) {
            
        } failed: { _, _ in
            
        }
    }
}

// MARK:  - 通知处理
private extension MSMessageController {
    
    //收到新消息
    func onNewMessage(note: Notification) {
        
        if let elems = note.object as? [MSIMElem] {
            let tempElems = deduplicateMessage(elems: elems)
            let tempMsgs = transUIMsgFromIMMsg(elems: tempElems)
            if tempMsgs.count > 0 {
                //当前列表是否停留在底部
                let isAtBottom = (tableView.contentOffset.y + tableView.height + 20 >= tableView.contentSize.height)
                self.uiMsgs.append(contentsOf: tempMsgs)
                tableView.reloadData()
                //当列表没有停留在底部时，不自动滚动显示出新消息。会在底部显示未读数，点击滚动到底部。
                //适当增加些容错
                if isAtBottom || self.isShowKeyboard {
                    self.scrollToBottom(animate: true)
                    self.readedReport(datas: tempMsgs)
                }else {
                    self.countTipView?.increaseCount(count: tempElems.count)
                }
            }
        }
    }
    
    func deduplicateMessage(elems: [MSIMElem]) -> [MSIMElem] {
        
        var tempArr: [MSIMElem] = []
        for elem in elems {
            if elem.partner_id() != self.partner_id {return []}
            var isExsit: Bool = false
            for data in self.uiMsgs {
                if elem.msg_sign == data.elem?.msg_sign {
                    isExsit = true
                    data.elem = elem
                    tableView.reloadData()
                    break
                }
                if elem.msg_id > 0 && elem.msg_id == data.elem?.msg_id {
                    isExsit = true
                    break
                }
            }
            if isExsit == false {
                tempArr.append(elem)
            }
        }
        return tempArr
    }
    
    //收到指令消息
    func onSignalMessage(note: Notification) {
        if let elems = note.object as? [MSIMElem] {
            delegate?.onRecieveSignalMessage(controller: self, elems: elems)
        }
    }
    
    //收到一条对方撤回的消息
    func recieveRevokeMessage(note: Notification) {
        if let elem = note.object as? MSIMElem {
            if elem.partner_id() != self.partner_id {return}
            var revokeData: MSMessageCellData?
            for data in self.uiMsgs {
                if data.elem?.msg_id == elem.revoke_msg_id {
                    revokeData = data
                }
            }
            if revokeData != nil {
                self.revokeMsg(msg: revokeData!)
            }
        }
    }
    
    func revokeMsg(msg: MSMessageCellData) {
        if let index = self.uiMsgs.firstIndex(of: msg) {
            self.uiMsgs.remove(at: index)
            if index < self.heightCache.count {
                self.heightCache[index] = 0
            }
            tableView.beginUpdates()
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
            let data = MSSystemMessageCellData(direction: .inComing)
            if msg.elem?.isSelf() == true {
                data.content = Bundle.bf_localizedString(key: "TUIKitMessageTipsYouRecallMessage")
            }else {
                data.content = Bundle.bf_localizedString(key: "TUIkitMessageTipsOthersRecallMessage")
            }
            self.uiMsgs.insert(data, at: index)
            tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .fade)
            tableView.endUpdates()
        }
    }
    
    //收到对方发出的消息已读回执
    func recieveMessageReceipt(note: Notification) {
        
        if let receipt = note.object as? MSIMMessageReceipt {
            if receipt.user_id != self.partner_id {return}
            for data in self.uiMsgs {
                if let msg_id = data.elem?.msg_id, msg_id <= receipt.msg_id {
                    data.elem?.readStatus = .MSG_STATUS_READ
                }else {
                    data.elem?.readStatus = .MSG_STATUS_UNREAD
                }
            }
            tableView.reloadData()
        }
    }
    
    //消息状态发生变化通知
    func messageStatusUpdate(note: Notification) {
        if let elem = note.object as? MSIMElem {
            if elem.partner_id() != self.partner_id {return}
            for (index,data) in self.uiMsgs.enumerated() {
                if data.elem?.msg_sign == elem.msg_sign {
                    data.elem = elem
                    let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? MSMessageCell
                    cell?.fillWithData(data: data)
                }
            }
        }
    }
    
    //用户个人信息更新通知
    func profileUpdate(note: Notification) {
        if let profiles = note.object as? [MSProfileInfo] {
            for info in profiles {
                if info.user_id == self.partner_id || info.user_id == MSIMTools.sharedInstance().user_id {
                    tableView.reloadData()
                }
                if info.user_id == self.partner_id {
                    navigationItem.title = info.nick_name
                }
            }
        }
    }
    
    @objc func keyboardWillShow() {
        self.isShowKeyboard = true
    }
    
    @objc func keyboardWillHidden() {
        self.isShowKeyboard = false
    }
    
    @objc func menuDidHide(note: Notification) {
        delegate?.didHideMenuInMessageController(controller: self)
        NotificationCenter.default.removeObserver(self, name: UIMenuController.didHideMenuNotification, object: nil)
    }
}

extension MSMessageController {
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.uiMsgs.count
    }
    
    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 0
        if heightCache.count > indexPath.row {
            height = heightCache[indexPath.row]
        }
        if height > 0 {
            return height
        }
        let data = self.uiMsgs[indexPath.row]
        height = data.heightOfWidth(width: UIScreen.width)
        heightCache.insert(height, at: indexPath.row)
        return height
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = self.uiMsgs[indexPath.row]
        var cell: MSMessageCell?
        if let classType = delegate?.onShowMessageData(controller: self, cellData: data) {
            tableView.register(classType, forCellReuseIdentifier: data.reUseId)
            cell = tableView.dequeueReusableCell(withIdentifier: data.reUseId, for: indexPath) as? MSMessageCell
            cell!.delegate = self
            cell!.fillWithData(data: data)
            return cell!
        }
        cell = tableView.dequeueReusableCell(withIdentifier: data.reUseId, for: indexPath) as? MSMessageCell
        cell!.delegate = self
        cell!.fillWithData(data: data)
        return cell!
    }
    
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.isScrollBottom == false {
            self.scrollToBottom(animate: false)
            if indexPath.row == self.uiMsgs.count - 1 {
                self.isScrollBottom = true
            }
        }
        //当滚动到第二个时，自动触发加载下一页
        if self.noMoreMsg == false && indexPath.row == 0 {
            self.loadMessages()
        }
    }
    
    @objc func didTapViewController() {
        delegate?.didTapInMessageController(controller: self)
    }
    
    public override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.height + 20 >= scrollView.contentSize.height {
            if self.countTipView.isHidden == false {
                self.countTipView.cleanCount()
                self.readedReport(datas: self.uiMsgs)//标记已读
            }
        }
    }
    
    public override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.didTapInMessageController(controller: self)
    }
}

// MARK: - MSNoticeCountViewDelegate
extension MSMessageController: MSNoticeCountViewDelegate {
    
    public func countViewDidTap() {
        self.countTipView.cleanCount()
        self.scrollToBottom(animate: true)
        self.readedReport(datas: self.uiMsgs)//标记已读
    }
}

// MARK: -MSMessageCellDelegate
extension MSMessageController: MSMessageCellDelegate {
    
    public func onLongPressMessage(cell: MSMessageCell) {
        if let data = cell.messageData {
            if data.isKind(of: MSSystemMessageCellData.self) {return}
            var isFirstResponder: Bool = false
            if let isShow = delegate?.willShowMenuInCell(controller: self, view: cell) {
                isFirstResponder = isShow
            }
            if isFirstResponder {
                NotificationCenter.default.addObserver(self, selector: #selector(menuDidHide), name: UIMenuController.didHideMenuNotification, object: nil)
            }else {
                self.becomeFirstResponder()
            }
            var items: [UIMenuItem] = []
            if data.isKind(of: MSTextMessageCellData.self) {
                items.append(UIMenuItem(title: Bundle.bf_localizedString(key: "Copy"), action: #selector(onCopyMsg)))
            }
            if data.elem?.isSelf() == true && data.elem?.sendStatus == .MSG_STATUS_SEND_SUCC && data.elem?.type != .MSG_TYPE_CUSTOM_UNREADCOUNT_NO_RECALL {
                items.append(UIMenuItem(title: Bundle.bf_localizedString(key: "Revoke"), action: #selector(onRevoke)))
            }
            items.append(UIMenuItem(title: Bundle.bf_localizedString(key: "Delete"), action: #selector(onDelete)))
            let vc = UIMenuController.shared
            vc.menuItems = items
            self.menuUIMsg = data
            vc.showMenu(from: cell.container, rect: cell.container.bounds)
        }
    }
    
    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(onRevoke) || action == #selector(onCopyMsg) || action == #selector(onDelete) {
            return true
        }
        return false
    }
    
    public override var canBecomeFirstResponder: Bool {
        return true
    }
    
    @objc func onCopyMsg() {
        if self.menuUIMsg?.isKind(of: MSTextMessageCellData.self) == true {
            let textMsg = self.menuUIMsg as! MSTextMessageCellData
            let pasteboard = UIPasteboard.general
            pasteboard.string = textMsg.content
        }
    }
    
    @objc func onRevoke() {
        if let msg_id = self.menuUIMsg?.elem?.msg_id,let partner_id = Int(self.partner_id) {
            MSIMManager.sharedInstance().revokeMessage(msg_id, toReciever: partner_id) {
                
            } failed: { _, _ in
                
            }
        }
    }
    
    @objc func onDelete() {
        if let msg_sign = self.menuUIMsg?.elem?.msg_sign {
            if MSIMManager.sharedInstance().deleteMessage(msg_sign, user_id: self.partner_id) == true {
                if let index = self.uiMsgs.firstIndex(of: self.menuUIMsg!) {
                    
                    var deleteArr: [IndexPath] = []
                    let preData: MSMessageCellData? = index >= 1 ? self.uiMsgs[index - 1] : nil
                    let nextData: MSMessageCellData? = index < self.uiMsgs.count - 1 ? self.uiMsgs[index + 1] : nil
                    
                    self.uiMsgs.remove(at: index)
                    deleteArr.append(IndexPath(row: index, section: 0))
                    if index < self.heightCache.count {
                        self.heightCache[index] = 0
                    }
                    //时间显示的处理
                    if (preData?.isKind(of: MSSystemMessageCellData.self) == true && nextData?.isKind(of: MSSystemMessageCellData.self) == true) || (preData?.isKind(of: MSSystemMessageCellData.self) == true && nextData == nil) {
                        if let preIndex = self.uiMsgs.firstIndex(of: preData!) {
                            self.uiMsgs.remove(at: preIndex)
                            if preIndex < self.heightCache.count {
                                self.heightCache[preIndex] = 0
                            }
                            deleteArr.append(IndexPath(row: preIndex, section: 0))
                        }
                    }
                    tableView.beginUpdates()
                    tableView.deleteRows(at: deleteArr, with: .fade)
                    tableView.endUpdates()
                }
            }
        }
    }
    
    ///消息失败重发
    public func onRetryMessage(cell: MSMessageCell) {
        let alert = UIAlertController(title: Bundle.bf_localizedString(key: "TUIKitTipsConfirmResendMessage"), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Bundle.bf_localizedString(key: "Re-send"), style: .default, handler: {[weak self] _ in
            self?.resendMessage(data: cell.messageData!)
        }))
        alert.addAction(UIAlertAction(title: Bundle.bf_localizedString(key: "Cancel"), style: .cancel, handler: nil))
        navigationController?.present(alert, animated: true, completion: nil)
    }
    
    func resendMessage(data: MSMessageCellData) {
        
        if let elem = data.elem,let toUid = data.elem?.toUid {
            MSIMManager.sharedInstance().resendC2CMessage(elem, toReciever: toUid) { msg_id in
                data.elem?.msg_id = msg_id
            } failed: { code, desc in
                MSHelper.showToastFailWithText(text: desc ?? "")
            }
        }
    }
    
    public func onSelectMessage(cell: MSMessageCell) {
        if cell is MSVoiceMessageCell {//点击音频
            let voiceCell = cell as! MSVoiceMessageCell
            for index in 0..<self.uiMsgs.count {
                if self.uiMsgs[index] is MSVoiceMessageCellData == false {
                    continue
                }
                let voiceData = self.uiMsgs[index] as! MSVoiceMessageCellData
                if voiceData === voiceCell.voiceData {
                    if voiceData.isPlaying {
                        voiceData.stopVoiceMessage()
                    }else {
                        voiceData.playVoiceMessage()
                    }
                }else {
                    voiceData.stopVoiceMessage()
                }
            }
            return
        }
        delegate?.onSelectMessageContent(controller: self, cell: cell)
    }
    
    public func onSelectMessageAvatar(cell: MSMessageCell) {
        delegate?.onSelectMessageAvatar(controller: self, cell: cell)
    }
}