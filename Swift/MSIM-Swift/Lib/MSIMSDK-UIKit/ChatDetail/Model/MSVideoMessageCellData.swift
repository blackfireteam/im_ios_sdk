//
//  MSVideoMessageCellData.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/6.
//

import UIKit
import MSIMSDK


open class MSVideoMessageCellData: MSMessageCellData {

    public var videoElem: MSIMVideoElem {
        return self.elem! as! MSIMVideoElem
    }
    
    public override func contentSize() -> CGSize {
        var size: CGSize = .zero
        size = CGSize(width: videoElem.width, height: videoElem.height)
        if size == .zero {
            return CGSize(width: 200, height: 200)
        }
        if size.height > size.width {
            size.width = size.width / size.height * MSMcros.TVideoMessageCell_Image_Height_Max
            size.height = MSMcros.TVideoMessageCell_Image_Height_Max
        }else {
            size.height = size.height / size.width * MSMcros.TVideoMessageCell_Image_Width_Max
            size.width = MSMcros.TVideoMessageCell_Image_Width_Max
        }
        return size
    }
    
    public override func heightOfWidth(width: CGFloat) -> CGFloat {
        var height: CGFloat = 0
        if showName {
            height += 25
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
        return MSMcros.TVideoMessageCell_ReuseId
    }
}
