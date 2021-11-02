//
//  BFCallMessageCell.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/10/3.
//

import UIKit

class BFCallMessageCell: MSBubbleMessageCell {

    private var icon: UIImageView!
    
    private var titleL: UILabel!
    
    var callData: BFCallMessageCellData? {
        return self.messageData as? BFCallMessageCellData
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        icon = UIImageView()
        bubbleView.addSubview(icon)
        
        titleL = UILabel()
        bubbleView.addSubview(titleL)
    }
    
    override func fillWithData(data: MSMessageCellData) {
        super.fillWithData(data: data)
        if let callData = data as? BFCallMessageCellData {
            if data.direction == .inComing {
                titleL?.textColor = UIColor.d_color(light: MSMcros.TText_Color, dark: MSMcros.TText_Color)
            }else {
                titleL?.textColor = UIColor.d_color(light: .white, dark: .white)
            }
            titleL?.font = .systemFont(ofSize: 16)
            titleL?.text = callData.notice
            icon?.image = callData.iconImage
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleL?.frame = callData?.noticeFrame ?? .zero
        icon?.frame = callData?.iconFrame ?? .zero
    }
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
