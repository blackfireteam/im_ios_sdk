//
//  MSChatViewController.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/9/1.
//

import UIKit
import MSIMSDK
import AVFoundation

public protocol MSChatViewControllerDelegate: NSObjectProtocol {
    
    ///发送新消息时的回调
    func didSendMessage(controller: MSChatViewController,message: MSIMMessage)
    ///每条新消息在进入气泡展示区之前，都会通知给您
    ///主要用于甄别自定义消息
    ///如果您返回 nil，MSChatViewController 会认为该条消息非自定义消息，会将其按照普通消息的处理流程进行处理。
    ///如果您返回一个 MSMessageCellData 类型的对象，MSChatViewController 会在随后触发的 onShowMessageData() 回调里传入您返回的 cellData 对象。
    ///也就是说，onNewMessage() 负责让您甄别自己的个性化消息，而 onShowMessageData() 回调则负责让您展示这条个性化消息。
    func prepareForMessage(controller: MSChatViewController,message: MSIMMessage) -> MSMessageCellData?
    
    ///展示自定义个性化消息
    ///您可以通过重载 onShowMessageData() 改变消息气泡的默认展示逻辑，只需要返回一个自定义的 MSMessageCell 对象即可。
    func onShowMessageData(controller: MSChatViewController,cellData: MSMessageCellData) -> MSMessageCell.Type?
    
    ///点击某一“更多”单元的回调委托
    func onSelectMoreCell(controller: MSChatViewController,cell: MSInputMoreCell)
    
    ///点击消息头像回调
    func onSelectMessageAvatar(controller: MSChatViewController,cell: MSMessageCell)
    
    ///点击消息内容回调
    func onSelectMessageContent(controller: MSChatViewController,cell: MSMessageCell)
    
    ///收到对方正在输入消息通知
    func onRecieveTextingMessage(controller: MSChatViewController,message: MSIMMessage)
    
    ///点击自定义表情，应该直接发送自定义表情消息
    func onDidSelectEmotionItem(controller: MSChatViewController,data: MSFaceCellData)
}

public class MSChatViewController: UIViewController {

    
    public var partner_id: String!
    
    public weak var delegate: MSChatViewControllerDelegate?
    
    public private(set) var messageController: MSMessageController = MSMessageController()
    
    public private(set) var inputController: MSInputViewController!
    
    func sendMessage(message: MSIMMessage) {
        MSIMManager.sharedInstance().sendC2CMessage(message, toReciever: self.partner_id) { _ in
            
        } failed: { _, desc in
            MSHelper.showToastFailWithText(text: desc ?? "")
        }
        delegate?.didSendMessage(controller: self, message: message)
    }
    
    private var _textingFlag: Bool = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    deinit {
        saveDraft()
        print("\(self) dealloc")
    }
    
    private func setupUI() {
        messageController.delegate = self
        messageController.partner_id = self.partner_id
        messageController.view.frame = CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height - MSMcros.TTextView_Height - UIScreen.safeAreaBottomHeight)
        addChild(messageController)
        view.addSubview(messageController.view)
        
        inputController = MSInputViewController(chatType: .MSIM_CHAT_TYPE_C2C, delegate: self)
        inputController.view.frame = CGRect(x: 0, y: UIScreen.height - MSMcros.TTextView_Height - UIScreen.safeAreaBottomHeight, width: UIScreen.width, height: MSMcros.TTextView_Height + UIScreen.safeAreaBottomHeight)
        inputController.view.autoresizingMask = .flexibleTopMargin
        addChild(inputController)
        view.addSubview(inputController.view)
        //设置草稿
        if let conv = MSConversationProvider.shared().providerConversation(self.partner_id),conv.draftText.count > 0 {
            inputController.inputBar.inputTextView.text = conv.draftText
            inputController.inputBar.inputTextView.becomeFirstResponder()
            inputController.inputBar.updateTextViewFrame()
        }
    }
    
    private func saveDraft() {
        var draft = self.inputController.inputBar.inputTextView.text
        draft = draft?.trimmingCharacters(in: .whitespacesAndNewlines)
        MSIMManager.sharedInstance().setConversationDraft(self.partner_id, draftText: draft ?? "", succ: nil, failed: nil)
    }
}

// MARK: - MSInputViewControllerDelegate
extension MSChatViewController: MSInputViewControllerDelegate {
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
        let message = MSIMManager.sharedInstance().createTextMessage(msg)
        self.sendMessage(message: message)
        _textingFlag = false
    }
    
    public func didSendVoiceMessage(inputController: MSInputViewController, filePath: String) {
        
        let url = URL(fileURLWithPath: filePath)
        let audioAsset = AVURLAsset(url: url, options: nil)
        let duration = Int(CMTimeGetSeconds(audioAsset.duration))
        let message = MSIMManager.sharedInstance().createVoiceMessage(filePath, duration: duration)
        self.sendMessage(message: message)
    }
    
    //处理正在输入消息逻辑
    //当满足以下两条规则，会发送一条正在输入的信令消息
    //1.上一条消息是对方发的消息
    //2.当前时间距离上一条消息间隔在10秒内
    public func contentDidChanged(inputController: MSInputViewController, text: String) {
        
        guard let lastData = messageController.uiMsgs.last,lastData.message.fromUid.count > 0 else {
            return
        }
        let diff = MSIMTools.sharedInstance().adjustLocalTimeInterval - lastData.message.msgSign
        if _textingFlag == false && lastData.message.isSelf == false && diff <= 10 * 1000 * 1000 {
            let extDic: NSDictionary = ["type": MSIMCustomSubType.Texting.rawValue,"desc": "我正在输入..."] as NSDictionary
            let message = MSIMManager.sharedInstance().createCustomMessage(extDic.el_convertJsonString(), option: .IMCUSTOM_SIGNAL, pushExt: nil)
            MSIMManager.sharedInstance().sendC2CMessage(message, toReciever: self.partner_id) { _ in
                
            } failed: { _, _ in
                
            }
            _textingFlag = true
        }
    }
    
    public func inputControllerDidInputAt(inputController: MSInputViewController) {
        
    }
    
    public func didDeleteAt(inputController: MSInputViewController, atText: String) {
        
    }
    
    public func didSelectMoreCell(inputController: MSInputViewController, cell: MSInputMoreCell) {
        
        delegate?.onSelectMoreCell(controller: self, cell: cell)
    }
    
    public func didSendEmotion(inputController: MSInputViewController, data: MSFaceCellData) {
        
        delegate?.onDidSelectEmotionItem(controller: self, data: data)
    }
}

// MARK: MSMessageControllerDelegate
extension MSChatViewController: MSMessageControllerDelegate {
    public func prepareForMessage(controller: MSMessageController, message: MSIMMessage) -> MSMessageCellData? {
        if let data = delegate?.prepareForMessage(controller: self, message: message) {
            return data
        }
        return nil
    }
    
    public func onShowMessageData(controller: MSMessageController, cellData: MSMessageCellData) -> MSMessageCell.Type? {
        
        if let type = delegate?.onShowMessageData(controller: self, cellData: cellData) {
            return type
        }
        return nil
    }
    
    public func onRecieveSignalMessage(controller: MSMessageController, messages: [MSIMMessage]) {
        
        for message in messages {
            if let customElem = message.customElem {
                let dic = (customElem.jsonStr as NSString).el_convertToDictionary()
                if let type = dic["type"] as? Int,type == MSIMCustomSubType.Texting.rawValue {
                    delegate?.onRecieveTextingMessage(controller: self, message: message)
                    return
                }
            }
        }
    }
    
    public func didTapInMessageController(controller: MSMessageController) {
        self.inputController.reset()
    }
    
    public func onSelectMessageAvatar(controller: MSMessageController, cell: MSMessageCell) {
        delegate?.onSelectMessageAvatar(controller: self, cell: cell)
        self.inputController.reset()
    }
    
    public func onSelectMessageContent(controller: MSMessageController, cell: MSMessageCell) {
        delegate?.onSelectMessageContent(controller: self, cell: cell)
        self.inputController.reset()
    }
    
    public func willShowMenuInCell(controller: MSMessageController, view: UIView) -> Bool {
        if self.inputController.inputBar.inputTextView.isFirstResponder {
            self.inputController.inputBar.inputTextView.overrideNextResponder = view
            return true
        }
        return false
    }
    
    public func didHideMenuInMessageController(controller: MSMessageController) {
        self.inputController.inputBar.inputTextView.overrideNextResponder = nil
    }
}















