//
//  MSUIConversationCellData.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/10.
//

import UIKit
import MSIMSDK


open class MSUIConversationCellData: NSObject {

    public var conv: MSIMConversation
    
    init(conv: MSIMConversation) {
        self.conv = conv
        super.init()
    }
    
    public var subTitle: NSAttributedString? {
        
        let lastMsgStr = getDisplayString(elem: conv.show_msg)
        if lastMsgStr.count == 0 && conv.draftText.count == 0 {
            return nil
        }
        var attr: NSMutableAttributedString?
        if conv.draftText.count > 0 {
            let show_msg = String(format: "%@%@", Bundle.bf_localizedString(key: "TUIKitMessageTypeDraft"),conv.draftText)
            attr = NSMutableAttributedString(string: show_msg)
            attr?.setAttributes([NSAttributedString.Key.foregroundColor: UIColor.systemGray,NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], range: NSRange(location: 0, length: attr!.length))
            attr?.setAttributes([NSAttributedString.Key.foregroundColor: UIColor.red,NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], range: NSRange(location: 0, length: Bundle.bf_localizedString(key: "TUIKitMessageTypeDraft").count))
        }else {
            attr = NSMutableAttributedString(string: lastMsgStr)
            attr?.setAttributes([NSAttributedString.Key.foregroundColor: UIColor.systemGray,NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], range: NSRange(location: 0, length: attr!.length))
        }
        return attr
    }
    
    public var title: String {
        return conv.userInfo.nick_name
    }
    
    public var avatarImage: UIImage {
        
        if conv.chat_type == .MSIM_CHAT_TYPE_C2C {
            return UIImage.bf_imageNamed(name: "default_c2c_head")!
        }else {
            return UIImage.bf_imageNamed(name: "default_group_head")!
        }
    }
    
    public var time: Date {
        
        return Date(timeIntervalSince1970: TimeInterval(conv.time / 1000 / 1000))
    }
    
    private func getDisplayString(elem: MSIMElem) -> String {
        
        var str: String = ""
        if elem.type == .MSG_TYPE_REVOKE {
            if elem.isSelf() {
                str = Bundle.bf_localizedString(key: "TUIKitMessageTipsYouRecallMessage")
            }else {
                str = Bundle.bf_localizedString(key: "TUIkitMessageTipsOthersRecallMessage")
            }
        }else {
            switch elem.type {
            case .MSG_TYPE_TEXT:
                str = (elem as! MSIMTextElem).text
            case .MSG_TYPE_IMAGE:
                str = Bundle.bf_localizedString(key: "TUIkitMessageTypeImage")
            case .MSG_TYPE_VOICE:
                str = Bundle.bf_localizedString(key: "TUIKitMessageTypeVoice")
            case .MSG_TYPE_VIDEO:
                str = Bundle.bf_localizedString(key: "TUIkitMessageTypeVideo")
            case .MSG_TYPE_CUSTOM_UNREADCOUNT_RECAL,
                 .MSG_TYPE_CUSTOM_UNREADCOUNT_NO_RECALL,
                 .MSG_TYPE_CUSTOM_IGNORE_UNREADCOUNT_RECALL:
                str = getCustomElemContent(elem: elem)
            default:
                str = Bundle.bf_localizedString(key: "TUIkitMessageTipsUnknowMessage")
            }
        }
        return str
    }
    
    private func getCustomElemContent(elem: MSIMElem) -> String {
        
        let customElem = elem as! MSIMCustomElem
        if let dic = (customElem.jsonStr as NSString).el_convertToDictionary() as? [String: Any],let type = dic["type"] as? Int {
            if type == MSIMCustomSubType.Like.rawValue {
                return "[Like]"
            }else if type == MSIMCustomSubType.VoiceCall.rawValue {
                return MSCallManager.parseToConversationShow(customParams: dic, callType: .voice, isSelf: customElem.isSelf())!
            }else if type == MSIMCustomSubType.VideoCall.rawValue {
                return MSCallManager.parseToConversationShow(customParams: dic, callType: .video, isSelf: customElem.isSelf())!
            }
        }
        return Bundle.bf_localizedString(key: "TUIKitMessageTipsUnsupportCustomMessage")
    }
}
