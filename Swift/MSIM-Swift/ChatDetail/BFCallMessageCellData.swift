//
//  BFCallMessageCellData.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/10/3.
//

import UIKit

class BFCallMessageCellData: MSBubbleMessageCellData {

    var callType: MSCallType = .voice
    
    var notice: String = ""
    
    var iconImage: UIImage? {
        if callType == .voice {
            return direction == .inComing ? UIImage.bf_imageNamed(name: "call_decline") : UIImage.bf_imageNamed(name: "call_decline_white")
        }else {
            return direction == .inComing ? UIImage.bf_imageNamed(name: "video_right") : UIImage.bf_imageNamed(name: "video_left")
        }
    }
    
    private(set) var noticeFrame: CGRect = .zero
    
    private(set) var iconFrame: CGRect = .zero
    
    override init(direction: TMsgDirection) {
        super.init(direction: direction)
    }
    
    override func contentSize() -> CGSize {
        let contentInset = direction == .inComing ? UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 14) : UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 16)
        var size = (notice as NSString).textSize(in: CGSize(width: MSMcros.TTextMessageCell_Text_Width_Max, height: CGFloat.greatestFiniteMagnitude), font: .systemFont(ofSize: 16))
        if direction == .inComing {
            iconFrame = CGRect(x: contentInset.left, y: contentInset.top, width: size.height, height: size.height)
            noticeFrame = CGRect(x: iconFrame.maxX + 5, y: contentInset.top, width: size.width, height: size.height)
        }else {
            noticeFrame = CGRect(x: contentInset.left, y: contentInset.top, width: size.width, height: size.height)
            iconFrame = CGRect(x: noticeFrame.maxX + 5, y: contentInset.top, width: size.height, height: size.height)
        }
        size.width += contentInset.left + contentInset.right + size.height + 5
        size.height += contentInset.top + contentInset.bottom
        
        return size
    }
    
    override var reUseId: String {
        return "TCallMessageCell"
    }
}
