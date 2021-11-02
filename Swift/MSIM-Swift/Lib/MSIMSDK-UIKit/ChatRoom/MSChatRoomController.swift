//
//  MSChatRoomController.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/11/2.
//

import UIKit
import MSIMSDK
import AVFoundation

public protocol MSChatRoomControllerDelegate: NSObjectProtocol {
    
    ///发送新消息时的回调
    func didSendMessage(controller: MSChatRoomController,elem: MSIMElem)
    ///每条新消息在进入气泡展示区之前，都会通知给您
    ///主要用于甄别自定义消息
    ///如果您返回 nil，MSChatViewController 会认为该条消息非自定义消息，会将其按照普通消息的处理流程进行处理。
    ///如果您返回一个 MSMessageCellData 类型的对象，MSChatViewController 会在随后触发的 onShowMessageData() 回调里传入您返回的 cellData 对象。
    ///也就是说，onNewMessage() 负责让您甄别自己的个性化消息，而 onShowMessageData() 回调则负责让您展示这条个性化消息。
    func prepareForMessage(controller: MSChatRoomController,elem: MSIMElem) -> MSMessageCellData?
    
    ///展示自定义个性化消息
    ///您可以通过重载 onShowMessageData() 改变消息气泡的默认展示逻辑，只需要返回一个自定义的 MSMessageCell 对象即可。
    func onShowMessageData(controller: MSChatRoomController,cellData: MSMessageCellData) -> MSMessageCell.Type?
    
    ///点击某一“更多”单元的回调委托
    func onSelectMoreCell(controller: MSChatRoomController,cell: MSInputMoreCell)
    
    ///点击消息头像回调
    func onSelectMessageAvatar(controller: MSChatRoomController,cell: MSMessageCell)
    
    ///点击消息内容回调
    func onSelectMessageContent(controller: MSChatRoomController,cell: MSMessageCell)
}

public class MSChatRoomController: UIViewController {

    
    public var room_id: String? {
        didSet {
            self.messageController.room_id = room_id
        }
    }
    
    public weak var delegate: MSChatRoomControllerDelegate?
    
    public private(set) var messageController: MSChatRoomMessageController = MSChatRoomMessageController()
    
    public private(set) var inputController: MSInputViewController!
    
    func sendMessage(message: MSIMElem) {
        if self.room_id == nil {
            MSHelper.showToastWithText(text: "room_id is nill")
            return
        }
        MSIMManager.sharedInstance().sendChatRoomMessage(message, toRoomID: self.room_id!) { _ in
            
        } failed: { _, desc in
            MSHelper.showToastFailWithText(text: desc ?? "")
        }
        delegate?.didSendMessage(controller: self, elem: message)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    deinit {
        print("\(self) dealloc")
    }
    
    private func setupUI() {
        messageController.delegate = self
        messageController.room_id = self.room_id
        messageController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height - MSMcros.TTextView_Height - UIScreen.safeAreaBottomHeight)
        addChild(messageController)
        view.addSubview(messageController.view)
        
        inputController = MSInputViewController(chatType: .MSIM_CHAT_TYPE_CHATROOM, delegate: self)
        inputController.view.frame = CGRect(x: 0, y: UIScreen.height - MSMcros.TTextView_Height - UIScreen.safeAreaBottomHeight, width: UIScreen.width, height: MSMcros.TTextView_Height + UIScreen.safeAreaBottomHeight)
        inputController.view.autoresizingMask = .flexibleTopMargin
        addChild(inputController)
        view.addSubview(inputController.view)
    }
}

// MARK: - MSInputViewControllerDelegate
extension MSChatRoomController: MSInputViewControllerDelegate {
    public func didChangeHeight(inputController: MSInputViewController, height: CGFloat) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            
            var msgFrame = self.messageController.view.frame
            msgFrame.size.height = self.view.frame.size.height - height
            self.messageController.view.frame = msgFrame
            
            var inputFrame = self.inputController.view.frame
            inputFrame.origin.y = msgFrame.origin.y + msgFrame.size.height
            inputFrame.size.height = height
            self.inputController.view.frame = inputFrame
            self.messageController.scrollToBottom(animate: false)
            
        } completion: { _ in
            
        }
    }
    
    public func didSendTextMessage(inputController: MSInputViewController, msg: String) {
        let textElem = MSIMManager.sharedInstance().createTextMessage(msg)
        self.sendMessage(message: textElem)
    }
    
    public func didSendVoiceMessage(inputController: MSInputViewController, filePath: String) {
        
        let url = URL(fileURLWithPath: filePath)
        let audioAsset = AVURLAsset(url: url, options: nil)
        let duration = Int(CMTimeGetSeconds(audioAsset.duration))
        if let length = try? FileManager.default.attributesOfItem(atPath: filePath)[FileAttributeKey.size] as? Int {
            var voiceElem = MSIMVoiceElem()
            voiceElem.path = filePath
            voiceElem.duration = duration
            voiceElem.dataSize = length
            voiceElem = MSIMManager.sharedInstance().createVoiceMessage(voiceElem)
            self.sendMessage(message: voiceElem)
        }
    }
    
    public func contentDidChanged(inputController: MSInputViewController, text: String) {
        
    }
    
    public func inputControllerDidInputAt(inputController: MSInputViewController) {
        
    }
    
    public func didDeleteAt(inputController: MSInputViewController, atText: String) {
        
    }
    
    public func didSelectMoreCell(inputController: MSInputViewController, cell: MSInputMoreCell) {
        
        delegate?.onSelectMoreCell(controller: self, cell: cell)
    }
}

// MARK: MSChatRoomMessageControllerDelegate
extension MSChatRoomController: MSChatRoomMessageControllerDelegate {
    public func onRecieveSignalMessage(controller: MSChatRoomMessageController, elems: [MSIMElem]) {
        
    }
    
    public func prepareForMessage(controller: MSChatRoomMessageController, elem: MSIMElem) -> MSMessageCellData? {
        if let data = delegate?.prepareForMessage(controller: self, elem: elem) {
            return data
        }
        return nil
    }
    
    public func onShowMessageData(controller: MSChatRoomMessageController, cellData: MSMessageCellData) -> MSMessageCell.Type? {
        
        if let type = delegate?.onShowMessageData(controller: self, cellData: cellData) {
            return type
        }
        return nil
    }
    
    public func didTapInMessageController(controller: MSChatRoomMessageController) {
        self.inputController.reset()
    }
    
    public func onSelectMessageAvatar(controller: MSChatRoomMessageController, cell: MSMessageCell) {
        delegate?.onSelectMessageAvatar(controller: self, cell: cell)
        self.inputController.reset()
    }
    
    public func onSelectMessageContent(controller: MSChatRoomMessageController, cell: MSMessageCell) {
        delegate?.onSelectMessageContent(controller: self, cell: cell)
        self.inputController.reset()
    }
    
    public func willShowMenuInCell(controller: MSChatRoomMessageController, view: UIView) -> Bool {
        if self.inputController.inputBar.inputTextView.isFirstResponder {
            self.inputController.inputBar.inputTextView.overrideNextResponder = view
            return true
        }
        return false
    }
    
    public func didHideMenuInMessageController(controller: MSChatRoomMessageController) {
        self.inputController.inputBar.inputTextView.overrideNextResponder = nil
    }
}
