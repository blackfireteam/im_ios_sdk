//
//  MSInputViewController.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/30.
//

import UIKit
import MSIMSDK


public protocol MSInputViewControllerDelegate: NSObjectProtocol {
    
    ///当前 InputController 高度改变时的回调
    func didChangeHeight(inputController: MSInputViewController,height: CGFloat)
    ///当前 InputCOntroller 发送文本消息时的回调
    func didSendTextMessage(inputController: MSInputViewController,msg: String)
    ///当前 InputCOntroller 发送语音信息时的回调
    func didSendVoiceMessage(inputController: MSInputViewController,filePath: String)
    ///输入框中内容发生变化时的回调
    func contentDidChanged(inputController: MSInputViewController,text: String)
    ///有 @ 字符输入
    func inputControllerDidInputAt(inputController: MSInputViewController)
    ///有 @xxx 字符删除
    func didDeleteAt(inputController: MSInputViewController,atText: String)
    ///点击拍照，照片等更多功能
    func didSelectMoreCell(inputController: MSInputViewController,cell: MSInputMoreCell)
    /// 点击发送自定义表情
    func didSendEmotion(inputController: MSInputViewController,data: MSFaceCellData)
}

enum InputStatus {
    case input,face,more,keyboard,talk
}
public class MSInputViewController: UIViewController {

    var inputBar: MSInputBarView!
    
    lazy var faceView: MSFaceView = {
        let faceView = MSFaceView(frame: CGRect(x: 0, y: inputBar.top + inputBar.height, width: view.width, height: 180))
        faceView.delegate = self
        faceView.setData(data: MSFaceUtil.shared.faceGroups)
        return faceView
    }()
    
    lazy var menuView: MSMenuView = {
        let menuView = MSMenuView(frame: CGRect(x: 0, y: faceView.top + faceView.height, width: view.width, height: 40))
        menuView.delegate = self
        var menus: [MSMenuCellData] = []
        for (index,group) in MSFaceUtil.shared.faceGroups.enumerated() {
            let data = MSMenuCellData()
            data.normalPath = group.menuNormalPath
            data.selectPath = group.menuSelectPath
            data.isSelected = index == 0
            menus.append(data)
        }
        menuView.data = menus
        return menuView
    }()
    
    lazy var moreView: MSChatMoreView = {
        let moreView = MSChatMoreView(frame: CGRect(x: 0, y: inputBar.top + inputBar.height, width: view.width, height: 0))
        moreView.delegate = self
        var cameraData = MSInputMoreCellData(type: .photo)
        cameraData.title = Bundle.bf_localizedString(key: "TUIKitMorePhoto")
        cameraData.image = UIImage.bf_imageNamed(name: "more_picture")
        
        var photoData = MSInputMoreCellData(type: .video)
        photoData.title = Bundle.bf_localizedString(key: "TUIKitMoreVideo")
        photoData.image = UIImage.bf_imageNamed(name: "more_camera")
        
        var voiceData = MSInputMoreCellData(type: .voiceCall)
        voiceData.title = Bundle.bf_localizedString(key: "TUIKitMoreVoiceCall")
        voiceData.image = UIImage.bf_imageNamed(name: "more_voice_call")
        
        var videoData = MSInputMoreCellData(type: .videoCall)
        videoData.title = Bundle.bf_localizedString(key: "TUIKitMoreVideoCall")
        videoData.image = UIImage.bf_imageNamed(name: "more_video_call")
        
        var locationData = MSInputMoreCellData(type: .location)
        locationData.title = Bundle.bf_localizedString(key: "TUIKitMoreLocation")
        locationData.image = UIImage.bf_imageNamed(name: "more_location")
        
        if self.type == .MSIM_CHAT_TYPE_C2C {
            moreView.setData(data: [cameraData,photoData,voiceData,videoData,locationData])
        }else {
            moreView.setData(data: [cameraData,photoData])
        }
        return moreView
    }()
    
    private weak var delegate: MSInputViewControllerDelegate?
    
    private var type: MSIMAChatType = .MSIM_CHAT_TYPE_C2C
    
    private var status: InputStatus = .input
    
    public func reset() {
        
        if status == .input {return}
        if status == .more {
            hideMoreAnimation()
        }else if status == .face {
            hideFaceAnimation()
        }
        status = .input
        inputBar.inputTextView.resignFirstResponder()
        delegate?.didChangeHeight(inputController: self, height: inputBar.height + UIScreen.safeAreaBottomHeight)
    }
    
    init(chatType: MSIMAChatType,delegate: MSInputViewControllerDelegate?) {
        super.init(nibName: nil, bundle: nil)
        self.type = chatType
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("\(self) dealloc")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.d_color(light: MSMcros.TInput_Background_Color, dark: MSMcros.TInput_Background_Color_Dark)
        inputBar = MSInputBarView(frame: CGRect(x: 0, y: 0, width: view.width, height: MSMcros.TTextView_Height))
        inputBar.delegate = self
        view.addSubview(inputBar)
    }
}

extension MSInputViewController {
    
    @objc func keyboardWillHide() {
        delegate?.didChangeHeight(inputController: self, height: inputBar.height + UIScreen.safeAreaBottomHeight)
    }
    
    @objc func keyboardWillShow() {
        
        if status == .face {
            hideFaceAnimation()
        }else if status == .more {
            hideMoreAnimation()
        }else {
            
        }
        status = .keyboard
    }
    
    @objc func keyboardWillChangeFrame(note: Notification) {
        if let keyboardFrame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            delegate?.didChangeHeight(inputController: self, height: keyboardFrame.height + inputBar.height)
        }
    }
    
    func hideFaceAnimation() {
        faceView.isHidden = false
        faceView.alpha = 1
        menuView.isHidden = false
        menuView.alpha = 1
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {[weak self] in
            self?.faceView.alpha = 0
            self?.menuView.alpha = 0
        } completion: {[weak self] _ in
            self?.faceView.isHidden = true
            self?.faceView.alpha = 1
            self?.menuView.isHidden = true
            self?.menuView.alpha = 1
            self?.menuView.removeFromSuperview()
            self?.faceView.removeFromSuperview()
        }
    }
    
    func showFaceAnimation() {
        view.addSubview(faceView)
        view.addSubview(menuView)
        
        faceView.isHidden = false
        var frame = faceView.frame
        frame.origin.y = UIScreen.height
        faceView.frame = frame
        
        menuView.isHidden = false
        frame = menuView.frame
        frame.origin.y = faceView.top + faceView.height
        menuView.frame = frame
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            
            var newFrame = self.faceView.frame
            newFrame.origin.y = self.inputBar.top + self.inputBar.height
            self.faceView.frame = newFrame
            
            newFrame = self.menuView.frame
            newFrame.origin.y = self.faceView.top + self.faceView.height
            self.menuView.frame = newFrame
            
        } completion: { _ in
            
        }
    }
    
    func hideMoreAnimation() {
        
        moreView.isHidden = false
        moreView.alpha = 1
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.moreView.alpha = 0
        } completion: { _ in
            
            self.moreView.isHidden = true
            self.moreView.alpha = 1
            self.moreView.removeFromSuperview()
        }
    }
    
    func showMoreAnimation() {
        view.addSubview(moreView)
        moreView.isHidden = false
        var frame = moreView.frame
        frame.origin.y = UIScreen.height
        moreView.frame = frame
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            
            var newFrame = self.moreView.frame
            newFrame.origin.y = self.inputBar.top + self.inputBar.height
            self.moreView.frame = newFrame
            
        } completion: { _ in
            
        }
    }
}

extension MSInputViewController: MSInputBarViewDelegate {
    public func inputBarDidTouchFace(textView: MSInputBarView) {
        if status == .more {
            hideMoreAnimation()
        }
        inputBar.inputTextView.resignFirstResponder()
        showFaceAnimation()
        status = .face
        delegate?.didChangeHeight(inputController: self, height: inputBar.height + faceView.height + menuView.height + UIScreen.safeAreaBottomHeight)
    }
    
    public func inputBarDidTouchMore(textView: MSInputBarView) {
        if status == .more {
            return
        }
        if status == .face {
            hideFaceAnimation()
        }
        inputBar.inputTextView.resignFirstResponder()
        showMoreAnimation()
        status = .more
        delegate?.didChangeHeight(inputController: self, height: inputBar.height + moreView.height + UIScreen.safeAreaBottomHeight)
    }
    
    public func inputBarDidTouchVoice(textView: MSInputBarView) {
        
        if status == .talk {
            return
        }
        inputBar.inputTextView.resignFirstResponder()
        hideFaceAnimation()
        hideMoreAnimation()
        status = .talk
        delegate?.didChangeHeight(inputController: self, height: MSMcros.TTextView_Height + UIScreen.safeAreaBottomHeight)
    }
    
    public func inputBarDidChangeInputHeight(textView: MSInputBarView, offset: CGFloat) {
        
        if status == .face {
            showFaceAnimation()
        }else if status == .more {
            showMoreAnimation()
        }
        delegate?.didChangeHeight(inputController: self, height: view.height + offset)
    }
    
    public func inputBarDidSendText(textView: MSInputBarView, text: String) {
        delegate?.didSendTextMessage(inputController: self, msg: text)
    }
    
    public func inputBarDidSendVoice(textView: MSInputBarView, path: String) {
        delegate?.didSendVoiceMessage(inputController: self, filePath: path)
    }
    
    public func inputBarDidInputAt(textView: MSInputBarView) {
        delegate?.inputControllerDidInputAt(inputController: self)
    }
    
    public func inputBarDidDeleteAt(textView: MSInputBarView, text: String) {
        delegate?.didDeleteAt(inputController: self, atText:text )
    }
    
    public func inputBarDidTouchKeyboard(textView: MSInputBarView) {
        
        if status == .more {
            hideMoreAnimation()
        }
        if status == .face {
            hideFaceAnimation()
        }
        status = .keyboard
        inputBar.inputTextView.becomeFirstResponder()
    }
    
    public func inputBarContentDidChanged(textView: MSInputBarView) {
        
        delegate?.contentDidChanged(inputController: self, text: textView.inputTextView.text)
    }
    
}


extension MSInputViewController: MSChatMoreViewDelegate,MSFaceViewDelegate,MSMenuViewDelegate {
    
    public func faceViewDidBackDelete(faceView: MSFaceView) {
        inputBar.backDelete()
    }
    
    
    public func didSelectMoreCell(moreView: MSChatMoreView, cell: MSInputMoreCell) {
        delegate?.didSelectMoreCell(inputController: self, cell: cell)
    }
    
    public func scrollToFaceGroup(faceVeiw: MSFaceView, index: Int) {
        menuView.scrollToMenu(at: index, in: faceVeiw.faceGroups[index])
    }
    
    public func didSelectItem(faceView: MSFaceView, indexPath: IndexPath) {
        let group = MSFaceUtil.shared.faceGroups[indexPath.section]
        let face = group.faces[indexPath.row]
        if indexPath.section == 0 {
            inputBar.addEmoji(emoji: face.name!)
        }else {
            self.delegate?.didSendEmotion(inputController: self, data: face)
        }
    }
    
    func menuViewDidSendMessage(menuView: MSMenuView) {
        
        let text = inputBar.getInput()
        if text.count == 0 {return}
        inputBar.clearInput()
        delegate?.didSendTextMessage(inputController: self, msg: text)
    }
    
    func menuViewDidSelectItemAtIndex(index: Int) {
        
        self.faceView.scrollToFaceGroup(index: index)
    }
}
