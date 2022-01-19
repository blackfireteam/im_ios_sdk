//
//  MSSystemMessageCellData.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/5.
//

import UIKit
import MSIMSDK

public enum MSSystemMessageType: Int {
    case SYS_UNKNOWN = 0 //未指定
    case SYS_TIME  //显示时间
    case SYS_REVOKE //撤回提示
    case SYS_OTHER
}
open class MSSystemMessageCellData: MSMessageCellData {

    public var content: String?
    
    public var contentFont: UIFont!
    
    public var contentColor: UIColor!
    
    public var sType: MSSystemMessageType = .SYS_UNKNOWN
    
    public override init(direction: TMsgDirection) {
        super.init(direction: direction)
        contentFont = .systemFont(ofSize: 13)
        contentColor = UIColor.systemGray
    }
    
    public override func contentSize() -> CGSize {
        var size = ((content ?? "") as NSString).textSize(in: CGSize(width: MSMcros.TSystemMessageCell_Text_Width_Max, height: CGFloat.greatestFiniteMagnitude), font: contentFont)
        size.height += 10
        size.width += 16
        return size
    }
    
    public override func heightOfWidth(width: CGFloat) -> CGFloat {
        return contentSize().height + 16
    }
    
    public override var reUseId: String {
        return MSMcros.TSystemMessageCell_ReuseId
    }
}
