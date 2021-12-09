//
//  MSLocationMessageCellData.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/12/9.
//

import UIKit
import MSIMSDK


open class MSLocationMessageCellData: MSMessageCellData {

    public var locationElem: MSIMLocationElem {
        return self.elem! as! MSIMLocationElem
    }
    
    public override func contentSize() -> CGSize {
        return CGSize(width: MSMcros.TLocationMessageCell_Width, height: MSMcros.TLocationMessageCell_Height)
    }
    
    public override func heightOfWidth(width: CGFloat) -> CGFloat {
        var height: CGFloat = 0
        if self.showName {
            height += 25
        }
        let containerSize = self.contentSize()
        height += containerSize.height
        if self.direction == .outGoing {
            height += 20
        }
        height += 5 + 5
        return height
    }
    
    public override var reUseId: String {
        return MSMcros.TLocationMessageCell_ReuseId
    }
}
