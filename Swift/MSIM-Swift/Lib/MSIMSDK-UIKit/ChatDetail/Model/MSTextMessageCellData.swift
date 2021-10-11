//
//  MSTextMessageCellData.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/5.
//

import UIKit

open class MSTextMessageCellData: MSBubbleMessageCellData {

    
    public var content: String?
    
    public var textFont: UIFont!
    
    public var textColor: UIColor!
    
    public lazy var attributedString: NSAttributedString = {
        let attr = formatMessageString(text: content)
        return attr
    }()
    
    public var outgoingTextColor: UIColor = UIColor.d_color(light: .white, dark: MSMcros.TText_OutMessage_Color_Dark)
    
    public var outgoingTextFont: UIFont = .systemFont(ofSize: 16)
    
    public var incommingTextColor: UIColor = UIColor.d_color(light: MSMcros.TText_Color, dark: MSMcros.TText_Color)
    
    public var incommingTextFont: UIFont = .systemFont(ofSize: 16)
    
    public private(set) var textSize: CGSize = .zero
    
    public private(set) var textOrigin: CGPoint = .zero
    
    public override init(direction: TMsgDirection) {
        super.init(direction: direction)
        
        if direction == .inComing {
            textColor = incommingTextColor
            textFont = incommingTextFont
        }else {
            textColor = outgoingTextColor
            textFont = outgoingTextFont
        }
    }
    
    public override func contentSize() -> CGSize {
        let contentInset = (direction == .inComing ? UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 14) : UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 16))
        let rect = attributedString.boundingRect(with: CGSize(width: MSMcros.TTextMessageCell_Text_Width_Max, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin,.usesFontLeading], context: nil)
        var size = CGSize(width: ceil(rect.size.width), height: ceil(rect.size.height))
        textSize = size
        textOrigin = CGPoint(x: contentInset.left, y: contentInset.top)
        
        size.height += contentInset.top + contentInset.bottom
        size.width += contentInset.left + contentInset.right
        return size
    }
    
    private func formatMessageString(text: String?) -> NSAttributedString {
        guard let content = text,content.count != 0 else {
            print("TTextMessageCell formatMessageString failed , current text is nil")
            return NSMutableAttributedString(string: "")
        }
        let attributeString = NSMutableAttributedString(string: content)
        let regex_emoji = "\\[[a-zA-Z0-9\\/\\u4e00-\\u9fa5-_]+\\]" //匹配表情
        guard let re = try? NSRegularExpression(pattern: regex_emoji, options: .caseInsensitive) else {
            return attributedString
        }
        let resultArray = re.matches(in: content, options: [], range: NSRange(location: 0, length: content.count))
        let group = MSFaceUtil.shared.defaultFace.first
        var imageArray: [[String: Any]] = []
        
        for match in resultArray {
            let range = match.range
            let subStr = (content as NSString).substring(with: range)
            for face in group!.faces {
                let beginIndex = face.name!.index(face.name!.startIndex, offsetBy: "emoji/".count)
                let faceName = face.name![beginIndex..<face.name!.endIndex]
                if faceName == subStr {
                    let textAttachment = NSTextAttachment()
                    textAttachment.image = UIImage.bf_emoji(name: face.name!)
                    let imageSize = textAttachment.image!.size
                    textAttachment.bounds = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
                    let imageStr = NSAttributedString(attachment: textAttachment)
                    let imageDic = ["image": imageStr,"range": range] as [String : Any]
                    imageArray.append(imageDic)
                    break
                }
            }
        }
        for i in (0..<imageArray.count).reversed() {
            if let range = imageArray[i]["range"] as? NSRange,let attr = imageArray[i]["image"] as? NSAttributedString {
                attributeString.replaceCharacters(in: range, with: attr)
            }
        }
        attributeString.addAttribute(NSAttributedString.Key.font, value: textFont!, range: NSRange(location: 0, length: attributeString.length))
        return attributeString
    }
    
    public override var reUseId: String {
        return MSMcros.TTextMessageCell_ReuseId
    }
}
