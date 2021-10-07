//
//  BFWinkMessageCell.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/9/1.
//

import UIKit
import Lottie


class BFWinkMessageCell: MSMessageCell {

    var animationView: AnimationView!
    
    var noticeL: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        animationView = AnimationView(name: "wink")
        animationView.loopMode = .loop
        container.addSubview(animationView)
        animationView.frame = container.bounds
        animationView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        animationView.play()
        
        noticeL = UILabel()
        noticeL.font = .systemFont(ofSize: 12)
        noticeL.text = "like"
        noticeL.textAlignment = .right
        noticeL.textColor = UIColor.d_color(light: MSMcros.TText_Color, dark: MSMcros.TText_Color_Dark)
        container.addSubview(noticeL)
    }
    
    override func fillWithData(data: MSMessageCellData) {
        super.fillWithData(data: data)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        noticeL.frame = CGRect(x: container.width - 50, y: container.height - 15, width: 50, height: 15)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
