//
//  MSSystemMessageCell.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/10.
//

import UIKit

open class MSSystemMessageCell: MSMessageCell {

    public private(set) var messageLabel: UILabel!
    
    public private(set) var systemData: MSSystemMessageCellData!
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        messageLabel = UILabel()
        messageLabel.font = .systemFont(ofSize: 13)
        messageLabel.textColor = .systemGray
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.backgroundColor = .clear
        messageLabel.layer.cornerRadius = 3
        messageLabel.layer.masksToBounds = true
        container.addSubview(messageLabel)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func fillWithData(data: MSMessageCellData) {
        super.fillWithData(data: data)
        if let systemData = data as? MSSystemMessageCellData {
            self.systemData = systemData
            
            messageLabel.text = systemData.content
            messageLabel.textColor = systemData.contentColor
            nameLabel.isHidden = true
            avatarView.isHidden = true
            retryView.isHidden = true
            indicator.stopAnimating()
            setNeedsLayout()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        container.center = container.superview!.center
        messageLabel.frame = container.bounds
    }
}
