//
//  BFWinkMessageCellData.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/9/1.
//

import UIKit
import MSIMSDK


class BFWinkMessageCellData: MSMessageCellData {


    override func contentSize() -> CGSize {
        return CGSize(width: 150, height: 150)
    }
    
    override func heightOfWidth(width: CGFloat) -> CGFloat {
        var height: CGFloat = 0
        if showName {
            height += 25
        }
        let containerSize = self.contentSize()
        height += containerSize.height
        if direction == .outGoing {
            height += 20
        }
        height += 5 + 5
        return height
    }
    
    override var reUseId: String {
        return "TWinkMessageCell"
    }
}
