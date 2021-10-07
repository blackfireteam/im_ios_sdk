//
//  MSTextMessageCell.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/6.
//

import UIKit

open class MSTextMessageCell: MSBubbleMessageCell {

    
    public var content: UILabel!
    
    public var textData: MSTextMessageCellData?
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        content = UILabel()
        content.numberOfLines = 0
        bubbleView.addSubview(content)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func fillWithData(data: MSMessageCellData) {
        super.fillWithData(data: data)
        if let textCellData = data as? MSTextMessageCellData {
            self.textData = textCellData
            content.attributedText = textCellData.attributedString
            content.textColor = textCellData.textColor
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if textData != nil {
            content.frame = CGRect(origin: textData!.textOrigin, size: textData!.textSize)
        }
    }
}
