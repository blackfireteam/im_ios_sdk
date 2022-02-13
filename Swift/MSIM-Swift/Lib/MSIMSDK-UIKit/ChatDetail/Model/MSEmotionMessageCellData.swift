//
//  MSEmotionMessageCellData.swift
//  MSIM-Swift
//
//  Created by benny wang on 2022/2/13.
//

import UIKit
import MSIMSDK


open class MSEmotionMessageCellData: MSMessageCellData {

    public override func contentSize() -> CGSize {
        return MSMcros.TEmotionMessageCell_Container_Size
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
        return MSMcros.TEmotionMessageCell_ReuseId
    }
}
