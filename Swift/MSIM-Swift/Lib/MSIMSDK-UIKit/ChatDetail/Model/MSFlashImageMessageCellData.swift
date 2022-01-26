//
//  MSFlashImageMessageCellData.swift
//  MSIM-Swift
//
//  Created by benny wang on 2022/1/26.
//

import UIKit
import MSIMSDK


open class MSFlashImageMessageCellData: MSMessageCellData {

    public var flashElem: MSIMFlashElem {
        return self.elem! as! MSIMFlashElem
    }
    
    public override func contentSize() -> CGSize {
        
        return CGSize(width: 200, height: 200)
    }
    
    public override func heightOfWidth(width: CGFloat) -> CGFloat {
        var height: CGFloat = 0
        if showName {
            height += 20
        }
        let containerSize = contentSize()
        height += containerSize.height
        if direction == .outGoing {
            height += 20
        }
        height += 5 + 5
        return height
    }
    
    public override var reUseId: String {
        return MSMcros.TFlashImageMessageCell_ReuseId
    }
}
