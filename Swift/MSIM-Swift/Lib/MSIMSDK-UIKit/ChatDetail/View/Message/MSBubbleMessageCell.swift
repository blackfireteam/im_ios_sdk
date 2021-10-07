//
//  MSBubbleMessageCell.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/6.
//

import UIKit

open class MSBubbleMessageCell: MSMessageCell {

    public var bubbleView: UIImageView!
    
    public var bubbleData: MSBubbleMessageCellData?
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        bubbleView = UIImageView(frame: .zero)
        container.addSubview(bubbleView)
        bubbleView.bounds = container.bounds
        bubbleView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func fillWithData(data: MSMessageCellData) {
        super.fillWithData(data: data)
        if let bubbleData = data as? MSBubbleMessageCellData {
            self.bubbleData = bubbleData
            bubbleView.image = bubbleData.bubble
            bubbleView.highlightedImage = bubbleData.highlightedBubble
        }
    }
}
