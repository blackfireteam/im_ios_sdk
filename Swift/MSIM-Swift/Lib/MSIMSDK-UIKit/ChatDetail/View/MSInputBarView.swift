//
//  MSInputBarView.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/4.
//

import UIKit
import AVFoundation


public protocol MSInputBarViewDelegate: NSObjectProtocol {
    //点击表情按钮，即“笑脸”后的回调委托
    func inputBarDidTouchFace(textView: MSInputBarView)
    //点击更多按钮，即“+”后的回调委托
    func inputBarDidTouchMore(textView: MSInputBarView)
    //点击语音按钮，即“声波”图标后的回调委托
    func inputBarDidTouchVoice(textView: MSInputBarView)
    /**
     *  输入条高度更改时的回调委托
     *  当您点击语音按钮、表情按钮、“+”按钮或者呼出/收回键盘时，InputBar 高度会发生改变时，执行该回调
     *  您可以通过该回调实现：通过该回调函数进行 InputBar 高度改变时的 UI 布局调整。
     */
    func inputBarDidChangeInputHeight(textView: MSInputBarView,offset: CGFloat)
    
    /**
     *  发送文本消息时的回调委托。
     *  当您通过 InputBar 发送文本消息（通过键盘点击发送时），执行该回调函数。
     *  您可以通过该回调实现：获取 InputBar 的内容，并将消息进行发送。
     *  在 TUIKit 默认的实现中，本回调函数在处理了表情视图与更多视图的浮现后，进一步调用了 TUIInputController 中的 didSendMessage 委托进行消息发送的进一步逻辑处理。
     */
    func inputBarDidSendText(textView: MSInputBarView,text: String)
    
    /**
     *  发送语音后的回调委托
     *  当您长按语音按钮并松开时，执行该回调函数。
     *  您可以通过该回调实现：对录制到的语音信息进行处理并发送该语音消息。
     *  在 TUIKit 默认的实现中，本回调函数在处理了表情视图与更多视图的浮现后，进一步调用了 TUIInputController 中的 didSendMessage 委托进行消息发送的进一步逻辑处理。
     */
    func inputBarDidSendVoice(textView: MSInputBarView,path: String)
    
     //输入含有 @ 字符的委托
    func inputBarDidInputAt(textView: MSInputBarView)
    
    //删除含有 @ 字符的委托（比如删除 @xxx）
    func inputBarDidDeleteAt(textView: MSInputBarView,text: String)
    /**
     *  点击键盘按钮后的回调委托
     *  点击表情按钮后，对应位置的“笑脸”会变成“键盘”图标，此时为键盘按钮。
     *  您可以通过该回调实现：隐藏当前显示的表情视图或者更多视图，并浮现键盘。
     */
    func inputBarDidTouchKeyboard(textView: MSInputBarView)

    //输入框中的内容发生变化时的回调委托
    func inputBarContentDidChanged(textView: MSInputBarView)
}

open class MSInputBarView: UIView {

    ///在视图中的分界线，使得 InputBar 与其他视图在视觉上区分，从而让 InputBar 在显示逻辑上更加清晰有序
    public var lineView: UIView!
    
    ///即在输入条最右侧的，具有“音波”图标的按钮
    public var micButton: UIButton!
    
    ///即点击表情按钮（“笑脸”）后，笑脸变化后的按钮
    public var keyboardButton: UIButton!
    
    ///即在输入条中占据大部分面积的白色文本输入框
    public var inputTextView: MSResponderTextView!
    
    ///在您点击了语音按钮（“声波图标”）后，原本的文本输入框会变成改按钮。
    public var recordButton: UIButton!
    
    ///即在输入条中的“笑脸”按钮。
    public var faceButton: UIButton!
    
    ///即在输入条中的“+”号按钮
    public var moreButton: UIButton!
    
    public weak var delegate: MSInputBarViewDelegate?
    
    ///添加表情
    public func addEmoji(emoji: String) {
        inputTextView.text = inputTextView.text.appending(emoji)
        if inputTextView.contentSize.height > MSMcros.TTextView_TextView_Height_Max {
            let offset = inputTextView.contentSize.height - inputTextView.height
            inputTextView.scrollRectToVisible(CGRect(x: 0, y: offset, width: inputTextView.width, height: inputTextView.height), animated: true)
        }
        textViewDidChange(inputTextView)
    }
    
    ///删除当前文本输入框中最右侧的字符（替换为“”）
    public func backDelete() {
        _ = textView(inputTextView, shouldChangeTextIn: NSRange(location: inputTextView.text.count - 1, length: 1), replacementText: "")
        textViewDidChange(inputTextView)
    }
    
    ///清空整个文本输入框中的内容（替换为“”）
    public func clearInput() {
        inputTextView.text = ""
        textViewDidChange(inputTextView)
    }
    
    ///获取文本输入框中的内容
    public func getInput() -> String {
        return inputTextView.text
    }
    
    ///更新 textView 坐标
    public func updateTextViewFrame() {
        textViewDidChange(UITextView())
    }
    
    private var record: MSRecordView?
    
    private var recorder: AVAudioRecorder?
    
    private var recordTimer: Timer?
    
    private var recordStartTime: Date?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        defaultLayout()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension MSInputBarView {
    
    func setupUI() {
        backgroundColor = UIColor.d_color(light: MSMcros.TInput_Background_Color, dark: MSMcros.TInput_Background_Color_Dark)
        
        lineView = UIView()
        lineView.backgroundColor = UIColor.d_color(light: MSMcros.TLine_Color, dark: MSMcros.TLine_Color_Dark)
        addSubview(lineView)
        
        micButton = UIButton()
        micButton.addTarget(self, action: #selector(clickVoiceBtn), for: .touchUpInside)
        micButton.setImage(UIImage.bf_imageNamed(name: "ToolViewInputVoice"), for: .normal)
        micButton.setImage(UIImage.bf_imageNamed(name: "ToolViewInputVoiceHL"), for: .highlighted)
        addSubview(micButton)
        
        faceButton = UIButton()
        faceButton.addTarget(self, action: #selector(clickFaceBtn), for: .touchUpInside)
        faceButton.setImage(UIImage.bf_imageNamed(name: "ToolViewEmotion"), for: .normal)
        faceButton.setImage(UIImage.bf_imageNamed(name: "ToolViewEmotionHL"), for: .highlighted)
        addSubview(faceButton)
        
        keyboardButton = UIButton()
        keyboardButton.addTarget(self, action: #selector(clickKeyboardBtn), for: .touchUpInside)
        keyboardButton.setImage(UIImage.bf_imageNamed(name: "ToolViewKeyboard"), for: .normal)
        keyboardButton.setImage(UIImage.bf_imageNamed(name: "ToolViewKeyboardHL"), for: .highlighted)
        keyboardButton.isHidden = true
        addSubview(keyboardButton)
        
        moreButton = UIButton()
        moreButton.addTarget(self, action: #selector(clickMoreBtn), for: .touchUpInside)
        moreButton.setImage(UIImage.bf_imageNamed(name: "TypeSelectorBtn_Black"), for: .normal)
        moreButton.setImage(UIImage.bf_imageNamed(name: "TypeSelectorBtnHL_Black"), for: .highlighted)
        addSubview(moreButton)
        
        recordButton = UIButton()
        recordButton.titleLabel?.font = .systemFont(ofSize: 15)
        recordButton.layer.cornerRadius = 4
        recordButton.layer.masksToBounds = true
        recordButton.layer.borderWidth = 0.5
        recordButton.layer.borderColor = UIColor.d_color(light: MSMcros.TLine_Color, dark: MSMcros.TLine_Color_Dark).cgColor
        recordButton.addTarget(self, action: #selector(recordBtnDown), for: .touchDown)
        recordButton.addTarget(self, action: #selector(recordBtnUp), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(recordBtnCancel), for: [.touchUpOutside,.touchCancel])
        recordButton.addTarget(self, action: #selector(recordBtnExit), for: .touchDragExit)
        recordButton.addTarget(self, action: #selector(recordBtnEnter), for: .touchDragEnter)
        recordButton.setTitle(Bundle.bf_localizedString(key: "TUIKitInputHoldToTalk"), for: .normal)
        recordButton.setTitleColor(UIColor.d_color(light: MSMcros.TText_Color, dark: MSMcros.TText_Color_Dark), for: .normal)
        recordButton.isHidden = true
        addSubview(recordButton)
        
        inputTextView = MSResponderTextView()
        inputTextView.delegate = self
        inputTextView.font = .systemFont(ofSize: 16)
        inputTextView.layer.masksToBounds = true
        inputTextView.layer.cornerRadius = 4
        inputTextView.layer.borderWidth = 0.5
        inputTextView.layer.borderColor = UIColor.d_color(light: MSMcros.TLine_Color, dark: MSMcros.TLine_Color_Dark).cgColor
        inputTextView.enablesReturnKeyAutomatically = true
        inputTextView.returnKeyType = .send
        addSubview(inputTextView)
    }
    
    func defaultLayout() {
        
        lineView.frame = CGRect(x: 0, y: 0, width: UIScreen.width, height: MSMcros.TLine_Heigh)
        let buttonSize = MSMcros.TTextView_Button_Size
        let buttonOriginY = (MSMcros.TTextView_Height - buttonSize.height) * 0.5
        micButton.frame = CGRect(x: MSMcros.TTextView_Margin, y: buttonOriginY, width: buttonSize.width, height: buttonSize.height)
        keyboardButton.frame = micButton.frame
        moreButton.frame = CGRect(x: UIScreen.width - buttonSize.width - MSMcros.TTextView_Margin, y: buttonOriginY, width: buttonSize.width, height: buttonSize.height)
        faceButton.frame = CGRect(x: moreButton.left - buttonSize.width - MSMcros.TTextView_Margin, y: buttonOriginY, width: buttonSize.width, height: buttonSize.height)
        
        let beginX = micButton.left + micButton.width + MSMcros.TTextView_Margin
        let endX = faceButton.left - MSMcros.TTextView_Margin
        recordButton.frame = CGRect(x: beginX, y: (MSMcros.TTextView_Height - MSMcros.TTextView_TextView_Height_Min) * 0.5, width: endX - beginX, height: MSMcros.TTextView_TextView_Height_Min)
        inputTextView.frame = recordButton.frame
    }
    
    func layoutButton(height: CGFloat) {
        
        var frame = self.frame
        let offset = height - frame.height
        frame.size.height = height
        self.frame = frame
        
        let buttonSize = MSMcros.TTextView_Button_Size
        let bottomMargin = (MSMcros.TTextView_Height - buttonSize.height) * 0.5
        let originY = frame.height - buttonSize.height - bottomMargin
        
        var faceFrame = faceButton.frame
        faceFrame.origin.y = originY
        faceButton.frame = faceFrame
        
        var moreFrame = moreButton.frame
        moreFrame.origin.y = originY
        moreButton.frame = moreFrame

        var voiceFrame = micButton.frame
        voiceFrame.origin.y = originY
        micButton.frame = voiceFrame
        
        delegate?.inputBarDidChangeInputHeight(textView: self, offset: offset)
    }
    
    @objc func clickVoiceBtn(sender: UIButton) {
        
        recordButton.isHidden = false
        inputTextView.isHidden = true
        micButton.isHidden = true
        keyboardButton.isHidden = false
        faceButton.isHidden = false
        inputTextView.resignFirstResponder()
        layoutButton(height: MSMcros.TTextView_Height)
        
        delegate?.inputBarDidTouchVoice(textView: self)
        keyboardButton.frame = micButton.frame
    }
    
    @objc func clickKeyboardBtn(sender: UIButton) {
        
        micButton.isHidden = false
        keyboardButton.isHidden = true
        recordButton.isHidden = true
        inputTextView.isHidden = false
        faceButton.isHidden = false
        layoutButton(height: inputTextView.height + 2 * MSMcros.TTextView_Margin)
        delegate?.inputBarDidTouchKeyboard(textView: self)
    }
    
    @objc func clickFaceBtn(sender: UIButton) {
        
        micButton.isHidden = false
        faceButton.isHidden = true
        keyboardButton.isHidden = false
        recordButton.isHidden = true
        inputTextView.isHidden = false
        delegate?.inputBarDidTouchFace(textView: self)
        keyboardButton.frame = faceButton.frame
    }
    
    @objc func clickMoreBtn(sender: UIButton) {
        delegate?.inputBarDidTouchMore(textView: self)
    }
    
    @objc func recordBtnDown(sender: UIButton) {
        
        let permission = AVAudioSession.sharedInstance().recordPermission
        //在此添加新的判定 undetermined，否则新安装后的第一次询问会出错。新安装后的第一次询问为 undetermined，而非 denied。
        if permission == .denied || permission == .undetermined {
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                if !granted {
                    let ac = UIAlertController(title: Bundle.bf_localizedString(key: "TUIKitInputNoMicTitle"), message: Bundle.bf_localizedString(key: "TUIKitInputNoMicTips"), preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: Bundle.bf_localizedString(key: "TUIKitInputNoMicOperateLater"), style: .cancel, handler: nil))
                    ac.addAction(UIAlertAction(title: Bundle.bf_localizedString(key: "TUIKitInputNoMicOperateEnable"), style: .default, handler: { action in
                        let app = UIApplication.shared
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString),app.canOpenURL(settingsURL) {
                            app.open(settingsURL, options: [:], completionHandler: nil)
                        }
                    }))
                    DispatchQueue.main.async {
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.window?.rootViewController?.present(ac, animated: true, completion: nil)
                    }
                }
            }
            return
        }
        if permission == .granted {
            if record == nil {
                record = MSRecordView()
                record?.frame = UIScreen.main.bounds
            }
            window?.addSubview(record!)
            recordStartTime = Date()
            record?.setStatus(status: .recording)
            recordButton.backgroundColor = .lightGray
            recordButton.setTitle(Bundle.bf_localizedString(key: "TUIKitInputReleaseToSend"), for: .normal)
            startRecord()
        }
    }
    
    @objc func recordBtnUp(sender: UIButton) {
        if AVAudioSession.sharedInstance().recordPermission != .granted {return}
        
        recordButton.backgroundColor = .clear
        recordButton.setTitle(Bundle.bf_localizedString(key: "TUIKitInputHoldToTalk"), for: .normal)
        let interval = Date().timeIntervalSince(recordStartTime!)
        if interval < 1 || interval > 60 {
            if interval < 1 {
                record?.setStatus(status: .tooShort)
            }else {
                record?.setStatus(status: .tooLong)
            }
            cancelRecord()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.record?.removeFromSuperview()
            }
        }else {
            record?.removeFromSuperview()
            let path = stopRecord()
            record = nil
            if path != nil {
                delegate?.inputBarDidSendVoice(textView: self, path: path!)
            }
        }
    }
    
    @objc func recordBtnCancel(sender: UIButton) {
        record?.removeFromSuperview()
        recordButton.backgroundColor = .clear
        recordButton.setTitle(Bundle.bf_localizedString(key: "TUIKitInputHoldToTalk"), for: .normal)
        cancelRecord()
    }
    
    @objc func recordBtnExit(sender: UIButton) {
        record?.setStatus(status: .cancel)
        recordButton.setTitle(Bundle.bf_localizedString(key: "TUIKitInputReleaseToCancel"), for: .normal)
    }
    
    @objc func recordBtnEnter(sender: UIButton) {
        record?.setStatus(status: .recording)
        recordButton.setTitle(Bundle.bf_localizedString(key: "TUIKitInputReleaseToSend"), for: .normal)
    }
}

extension MSInputBarView: UITextViewDelegate {
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        keyboardButton.isHidden = true
        micButton.isHidden = false
        faceButton.isHidden = false
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        let size = inputTextView.sizeThatFits(CGSize(width: inputTextView.width, height: MSMcros.TTextView_TextView_Height_Max))
        let oldHeight = inputTextView.height
        var newHeight = size.height
        if newHeight > MSMcros.TTextView_TextView_Height_Max {
            newHeight = MSMcros.TTextView_TextView_Height_Max
        }
        if newHeight < MSMcros.TTextView_TextView_Height_Min {
            newHeight = MSMcros.TTextView_TextView_Height_Min
        }
        delegate?.inputBarContentDidChanged(textView: self)
        
        if oldHeight == newHeight {return}
        UIView.animate(withDuration: 0.3) {
            var textFrame = self.inputTextView.frame
            textFrame.size.height += newHeight - oldHeight
            self.inputTextView.frame = textFrame
            self.layoutButton(height: newHeight + 2 * MSMcros.TTextView_Margin)
        }
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            let sp = textView.text.trimmingCharacters(in: .whitespaces)
            if sp.count == 0 {
                let ac = UIAlertController(title: Bundle.bf_localizedString(key: "TUIKitInputBlankMessageTitle"), message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: Bundle.bf_localizedString(key: "Confirm"), style: .default, handler: nil))
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController?.present(ac, animated: true, completion: nil)
            }else {
                delegate?.inputBarDidSendText(textView: self, text: textView.text)
                clearInput()
            }
            return false
        }else if text == "" {
            let content = textView.text ?? ""
            if content.count > range.location {
                // 一次性删除 [微笑] 这种表情消息
                if content.last == "]" {
                    var location = range.location
                    var length = range.length
//                    let left = 91 // '[' 对应的ascii码
//                    let right = 93 // ']' 对应的ascii码
                    while location >= 0 {
                        let c = content.subString(from: location, to: location)
                        if c == "[" {
                            textView.text = (content as NSString).replacingCharacters(in: NSRange(location: location, length: length), with: "")
                            return false
                        }
                        location -= 1
                        length += 1
                    }
                }else if content.last == " " {// 一次性删除 @xxx 这种 @ 消息
                    var location = range.location
                    var length = range.length
//                    let at = 64  // '@' 对应的ascii码
                    while location >= 0 {
                        let c = content.subString(from: location, to: location)
                        if c == "@" {
                            let atText = content.subString(from: location, to: location + length - 1)
                            textView.text = (content as NSString).replacingCharacters(in: NSRange(location: location, length: length), with: "")
                            delegate?.inputBarDidDeleteAt(textView: self, text: atText)
                            return false
                        }
                        location -= 1
                        length += 1
                    }
                }
            }
        }else if text == "@" {// 监听 @ 字符的输入
            delegate?.inputBarDidInputAt(textView: self)
        }
        return true
    }
    
}

/// 录音相关
private extension MSInputBarView {
    
    func startRecord() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord)
        try? session.setActive(true, options: .notifyOthersOnDeactivation)
        
        let recordSetting = [AVSampleRateKey: 8000.0,AVFormatIDKey: Int(kAudioFormatMPEG4AAC),AVLinearPCMBitDepthKey: 16,AVNumberOfChannelsKey: 1,AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue] as [String : Any]
        let fileName = String(format: "%@.m4a", NSString.uuid())
        let path = FileManager.pathForIMVoice() + fileName
        let url = URL(fileURLWithPath: path)
        
        recorder = try? AVAudioRecorder(url: url, settings: recordSetting)
        recorder?.isMeteringEnabled = true
        recorder?.prepareToRecord()
        recorder?.record()
        recorder?.updateMeters()
        
        recordTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(recordTick), userInfo: nil, repeats: true)
    }
    
    @objc func recordTick(timer: Timer) {
        
        recorder?.updateMeters()
        if let power = recorder?.averagePower(forChannel: 0) {
            print("power = \(power)")
            record?.setPower(power: Int(power))
        }
        //在此处添加一个时长判定，如果时长超过60s，则取消录制，提示时间过长,同时不再显示 recordView。
        //此处使用 recorder 的属性，使得录音结果尽量精准。注意：由于语音的时长为整形，所以 60.X 秒的情况会被向下取整。但因为 ticker 0.5秒执行一次，所以因该都会在超时时显示为60s
        if let interval = recorder?.currentTime {
            if interval >= 55 && interval < 60 {
                let seconds = 60 - interval
                let secondsString = String(format: Bundle.bf_localizedString(key: "TUIKitInputWillFinishRecordInSeconds"), seconds + 1)
                record?.title.text = secondsString
            }
            if interval >= 60 {
                let path = stopRecord()
                record?.setStatus(status: .tooLong)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.record?.removeFromSuperview()
                }
                if path != nil {
                    delegate?.inputBarDidSendVoice(textView: self, path: path!)
                }
            }
        }
    }
    
    func stopRecord() -> String? {
        if recordTimer != nil {
            recordTimer?.invalidate()
            recordTimer = nil
        }
        if recorder?.isRecording == true {
            recorder?.stop()
        }
        return recorder?.url.path
    }
    
    func cancelRecord() {
        if recordTimer != nil {
            recordTimer?.invalidate()
            recordTimer = nil
        }
        if recorder?.isRecording == true {
            recorder?.stop()
        }
        if let path = recorder?.url.path,FileManager.default.fileExists(atPath: path) == true {
            try? FileManager.default.removeItem(atPath: path)
        }
    }
}
