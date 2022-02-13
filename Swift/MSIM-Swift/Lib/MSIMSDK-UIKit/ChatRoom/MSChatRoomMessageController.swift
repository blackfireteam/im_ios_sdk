//
//  MSChatRoomMessageController.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/11/2.
//

import UIKit
import MSIMSDK


public protocol MSChatRoomMessageControllerDelegate: NSObjectProtocol {
    
    ///每条新消息在进入气泡展示区之前，都会通知给您
    func prepareForMessage(controller: MSChatRoomMessageController,message: MSIMMessage) -> MSMessageCellData?
    ///您可以通过该回调实现：根据传入的 data 初始化消息气泡并进行显示
    func onShowMessageData(controller: MSChatRoomMessageController,cellData: MSMessageCellData) -> MSMessageCell.Type?
    ///收到信令消息
    func onRecieveSignalMessage(controller: MSChatRoomMessageController,messages: [MSIMMessage])
    ///您可以通过该回调实现：重置 InputControoler，收起键盘
    func didTapInMessageController(controller: MSChatRoomMessageController)
    ///您可以通过该回调实现：跳转到对应用户的详细信息界面
    func onSelectMessageAvatar(controller: MSChatRoomMessageController,cell: MSMessageCell)
    ///点击消息内容委托
    func onSelectMessageContent(controller: MSChatRoomMessageController,cell: MSMessageCell)
    ///显示长按菜单前的回调函数
    func willShowMenuInCell(controller: MSChatRoomMessageController,view: UIView) -> Bool
    ///隐藏长按菜单后的回调函数
    func didHideMenuInMessageController(controller: MSChatRoomMessageController)
    
}

public class MSChatRoomMessageController: UITableViewController {

    public weak var delegate: MSChatRoomMessageControllerDelegate?
    
    public var roomInfo: MSGroupInfo!
    
    public private (set) var uiMsgs: [MSMessageCellData] = []
    
    public func scrollToBottom(animate: Bool) {
        if uiMsgs.count > 0 {
            tableView.scrollToRow(at: IndexPath(row: uiMsgs.count-1, section: 0), at: .bottom, animated: animate)
        }
    }
    
    public func addSystemTips(text: String) {
        let system = MSSystemMessageCellData(direction: .inComing)
        system.message = MSIMMessage()
        system.content = text
        system.sType = .SYS_OTHER
        let isAtBottom = (tableView.contentOffset.y + tableView.height + 20 >= tableView.contentSize.height)
        self.uiMsgs.append(system)
        tableView.reloadData()
        //当列表没有停留在底部时，不自动滚动显示出新消息。会在底部显示未读数，点击滚动到底部。
        //适当增加些容错
        if isAtBottom || self.isShowKeyboard {
            self.scrollToBottom(animate: true)
        }
    }
    
    private var heightCache: [CGFloat] = []
    
    private var isScrollBottom: Bool = false
    
    private var isShowKeyboard: Bool = false
    
    private var msgForDate: MSIMMessage?
    
    private var menuUIMsg: MSMessageCellData?
    
    private var countTipView: MSNoticeCountView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        addNotifications()
        setupUI()
        loadMessages()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let msgID = self.uiMsgs.last?.message.msgID {
            MSIMManager.sharedInstance().markChatRoomMessage(asRead: msgID) {
                
            } failed: { _, _ in
                
            }
        }
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
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init(MSUIKitNotification_ChatRoom_MessageListener), object: nil, queue: .main) {[weak self] note in
            self?.onNewMessage(note: note)
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init(MSUIKitNotification_ChatRoom_MessageUpdate), object: nil, queue: .main) {[weak self] note in
            self?.messageUpdate(note: note)
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init(MSUIKitNotification_MessageRecieveDelete), object: nil, queue: .main) {[weak self] note in
            self?.recieveMessageDelete(note: note)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func loadMessages() {
        if let msgs = MSChatRoomManager.sharedInstance().messages as? [MSIMMessage] {
            let uiMsgs = self.transUIMsgFromIMMsg(messages: msgs)
            self.uiMsgs.append(contentsOf: uiMsgs)
            self.tableView.reloadData()
        }
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
        
        countTipView = MSNoticeCountView()
        countTipView.isHidden = true
        countTipView.delegate = self
    }
    
    private func transUIMsgFromIMMsg(messages: [MSIMMessage]) -> [MSMessageCellData] {
    
        var uiMsgs: [MSMessageCellData] = []
        for k in (0..<messages.count).reversed() {
            let message = messages[k]
            let dateMsg = transSystemMsgFromDate(date: message.msgSign)
            
            var data: MSMessageCellData?
            if let cellData = self.delegate?.prepareForMessage(controller: self, message: message) {
                if dateMsg != nil {
                    self.msgForDate = message
                    uiMsgs.append(dateMsg!)
                }
                uiMsgs.append(cellData)
                continue
            }
            if message.type == .MSG_TYPE_REVOKE {//撤回的消息
                let revoke = MSSystemMessageCellData(direction: .inComing)
                if message.isSelf {
                    revoke.content = Bundle.bf_localizedString(key: "TUIKitMessageTipsYouRecallMessage")
                }else {
                    revoke.content = Bundle.bf_localizedString(key: "TUIkitMessageTipsOthersRecallMessage")
                }
                revoke.sType = .SYS_REVOKE
                revoke.message = message
                data = revoke
            }else if message.type == .MSG_TYPE_TEXT {
                let textMsg = MSTextMessageCellData(direction: message.isSelf ? .outGoing : .inComing)
                textMsg.showName = true
                textMsg.content = message.textElem?.text
                textMsg.message = message
                data = textMsg
            }else if message.type == .MSG_TYPE_IMAGE {
                let imageMsg = MSImageMessageCellData(direction: message.isSelf ? .outGoing : .inComing)
                imageMsg.showName = true
                imageMsg.message = message
                data = imageMsg
            }else if message.type == .MSG_TYPE_VIDEO {
                let videoMsg = MSVideoMessageCellData(direction: message.isSelf ? .outGoing : .inComing)
                videoMsg.showName = true
                videoMsg.message = message
                data = videoMsg
            }else if message.type == .MSG_TYPE_VOICE {
                let voiceMsg = MSVoiceMessageCellData(direction: message.isSelf ? .outGoing : .inComing)
                voiceMsg.showName = true
                voiceMsg.message = message
                data = voiceMsg
            }else {
                let unknowData = MSSystemMessageCellData(direction: .inComing)
                unknowData.content = Bundle.bf_localizedString(key: "TUIkitMessageTipsUnknowMessage")
                unknowData.message = message
                unknowData.sType = .SYS_UNKNOWN
                data = unknowData
            }
            if dateMsg != nil {
                self.msgForDate = message
                uiMsgs.append(dateMsg!)
            }
            uiMsgs.append(data!)
        }
        return uiMsgs
    }
    
    private func transSystemMsgFromDate(date: Int) -> MSSystemMessageCellData? {
        
        if self.msgForDate == nil || labs(date - self.msgForDate!.msgSign) / 1000 / 1000 > MAX_MESSAGE_SEP_DLAY {
            let system = MSSystemMessageCellData(direction: .inComing)
            system.message = MSIMMessage()
            system.content = Date(timeIntervalSince1970: TimeInterval(date / 1000 / 1000)).ms_messageString()
            system.sType = .SYS_TIME
            return system
        }
        return nil
    }
}

// MARK:  - 通知处理
private extension MSChatRoomMessageController {
    
    //收到新消息
    func onNewMessage(note: Notification) {
        
        if let messages = note.object as? [MSIMMessage] {
            let tempMessages = deduplicateMessage(messages: messages)
            let tempMsgs = transUIMsgFromIMMsg(messages: tempMessages)
            if tempMsgs.count > 0 {
                //当前列表是否停留在底部
                let isAtBottom = (tableView.contentOffset.y + tableView.height + 20 >= tableView.contentSize.height)
                self.uiMsgs.append(contentsOf: tempMsgs)
                tableView.reloadData()
                //当列表没有停留在底部时，不自动滚动显示出新消息。会在底部显示未读数，点击滚动到底部。
                //适当增加些容错
                if isAtBottom || self.isShowKeyboard {
                    self.scrollToBottom(animate: true)
                }else {
                    self.countTipView?.increaseCount(count: tempMessages.count)
                }
            }
        }
    }
    
    func deduplicateMessage(messages: [MSIMMessage]) -> [MSIMMessage] {
        
        var tempArr: [MSIMMessage] = []
        for message in messages {
            if message.chatType != .MSIM_CHAT_TYPE_CHATROOM {
                continue
            }
            if message.groupID != self.roomInfo.room_id {
                continue
            }
            var isExsit: Bool = false
            for data in self.uiMsgs {
                if message.msgSign == data.message.msgSign {
                    isExsit = true
                    data.message = message
                    tableView.reloadData()
                    break
                }
                if message.msgID > 0 && message.msgID == data.message.msgID {
                    isExsit = true
                    break
                }
            }
            if isExsit == false {
                tempArr.append(message)
            }
        }
        return tempArr
    }
    
    //消息状态发生变化通知
    func messageUpdate(note: Notification) {
        
        guard let message = note.object as? MSIMMessage, message.chatType == .MSIM_CHAT_TYPE_CHATROOM, message.groupID == self.roomInfo.room_id else {return}
        if message.type == .MSG_TYPE_REVOKE {//撤回消息导致cell高度发生变化，需要更新缓存的高度
            for (index,data) in self.uiMsgs.enumerated() {
                if data.message.msgID == message.msgID {
                    self.uiMsgs.remove(at: index)
                    if index < self.heightCache.count {
                        self.heightCache[index] = 0
                    }
                    self.tableView.beginUpdates()
                    self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                    let sysData = MSSystemMessageCellData(direction: .inComing)
                    sysData.message = MSIMMessage()
                    if message.isSelf == true {
                        sysData.content = Bundle.bf_localizedString(key: "TUIKitMessageTipsYouRecallMessage")
                    }else {
                        sysData.content = Bundle.bf_localizedString(key: "TUIkitMessageTipsOthersRecallMessage")
                    }
                    sysData.sType = .SYS_REVOKE
                    self.uiMsgs.insert(sysData, at: index)
                    self.tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                    self.tableView.endUpdates()
                    break
                }
            }
            return
        }
        for (index,data) in self.uiMsgs.enumerated() {
            if data.message.msgSign == message.msgSign {
                data.message = message
                if let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? MSMessageCell {
                    cell.fillWithData(data: data)
                }
            }
        }
    }
    
    ///收到服务器将消息删除
    func recieveMessageDelete(note: Notification) {
        
//        guard let msg_ids = note.object as? [Int] else {return}
        //TO DO
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

extension MSChatRoomMessageController {
    
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
    }
    
    @objc func didTapViewController() {
        delegate?.didTapInMessageController(controller: self)
    }
    
    public override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.height + 20 >= scrollView.contentSize.height {
            if self.countTipView.isHidden == false {
                self.countTipView.cleanCount()
            }
        }
    }
    
    public override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.didTapInMessageController(controller: self)
    }
}

// MARK: - MSNoticeCountViewDelegate
extension MSChatRoomMessageController: MSNoticeCountViewDelegate {
    
    public func countViewDidTap() {
        self.countTipView.cleanCount()
        self.scrollToBottom(animate: true)
    }
}

// MARK: -MSMessageCellDelegate
extension MSChatRoomMessageController: MSMessageCellDelegate {
    
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
            if data.message.isSelf == true && data.message.sendStatus == .MSG_STATUS_SEND_SUCC && data.message.type != .MSG_TYPE_CUSTOM_UNREADCOUNT_NO_RECALL {
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
        
        if let msg_id = self.menuUIMsg?.message.msgID {
            MSIMManager.sharedInstance().chatRoomRevokeMessage(msg_id, fromRoomID: self.roomInfo.room_id) {
                
                print("撤回成功")
            } failed: { _, _ in
                
            }
        }
    }
    
    @objc func onDelete() {
        
        //删除消息有权限要求，管理员才能删除
        if self.roomInfo.action_del_msg == false && self.menuUIMsg?.message.sendStatus == .MSG_STATUS_SEND_SUCC {
            MSHelper.showToastFailWithText(text: "You have no permission to do this!")
            return
        }
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
            if (preData?.isKind(of: MSSystemMessageCellData.self) == true && (preData as! MSSystemMessageCellData).sType == .SYS_TIME && nextData?.isKind(of: MSSystemMessageCellData.self) == true && (nextData as! MSSystemMessageCellData).sType == .SYS_TIME) || (preData?.isKind(of: MSSystemMessageCellData.self) == true && (preData as! MSSystemMessageCellData).sType == .SYS_TIME && nextData == nil) {
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
            
            // 通知服务器删除
            if let msg_id = self.menuUIMsg?.message.msgID {
                MSIMManager.sharedInstance().deleteChatroomMsgs(self.roomInfo.room_id, msgIDs: [NSNumber(value: msg_id)]) {
                    
                } failed: { _, _ in
                    
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
        
        MSIMManager.sharedInstance().resendChatRoomMessage(data.message, toRoomID: self.roomInfo.room_id) { msg_id in
            data.message.msgID = msg_id
        } failed: { code, desc in
            MSHelper.showToastFailWithText(text: desc ?? "")
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
