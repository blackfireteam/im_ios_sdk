//
//  MSSystemMessageCellData.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/5.
//

import UIKit
import MSIMSDK


open class MSSystemMessageCellData: MSMessageCellData {

    public var content: String?
    
    public var contentFont: UIFont!
    
    public var contentColor: UIColor!
    
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
