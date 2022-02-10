//
//  MSImageMessageCellData.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/5.
//

import UIKit
import MSIMSDK


open class MSImageMessageCellData: MSMessageCellData {

    
    public override func contentSize() -> CGSize {
        var size: CGSize = .zero
        size = CGSize(width: message.imageElem!.width, height: message.imageElem!.height)
        if size == .zero {
            return CGSize(width: 200, height: 200)
        }
        if size.height > size.width {
            size.width = size.width / size.height * MSMcros.TImageMessageCell_Image_Height_Max
            size.height = MSMcros.TImageMessageCell_Image_Height_Max
        }else {
            size.height = size.height / size.width * MSMcros.TImageMessageCell_Image_Width_Max
            size.width = MSMcros.TImageMessageCell_Image_Width_Max
        }
        return size
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
        return MSMcros.TImageMessageCell_ReuseId
    }
}
