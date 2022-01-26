//
//  MSFlashImageMessageCell.swift
//  MSIM-Swift
//
//  Created by benny wang on 2022/1/26.
//

import UIKit

open class MSFlashImageMessageCell: MSMessageCell {

    public var maskCoverView: UIImageView!
    
    public var fireIcon: UIImageView!
    
    public var progressL: UILabel!
    
    public var flashImageData: MSFlashImageMessageCellData?
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        maskCoverView = UIImageView()
        maskCoverView.layer.cornerRadius = 5
        maskCoverView.layer.masksToBounds = true
        maskCoverView.contentMode = .scaleAspectFill
        container.addSubview(maskCoverView)
        maskCoverView.frame = container.bounds
        maskCoverView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        
        fireIcon = UIImageView()
        container.addSubview(fireIcon)
        
        progressL = UILabel()
        progressL.textColor = .white
        progressL.font = .systemFont(ofSize: 15)
        progressL.textAlignment = .center
        progressL.layer.cornerRadius = 5
        progressL.isHidden = true
        progressL.backgroundColor = MSMcros.TImageMessageCell_Progress_Color
        progressL.layer.masksToBounds = true
        container.addSubview(progressL)
        progressL.frame = container.bounds
        progressL.autoresizingMask = [.flexibleWidth,.flexibleHeight]
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func fillWithData(data: MSMessageCellData) {
        super.fillWithData(data: data)
        if let flashData = data as? MSFlashImageMessageCellData {
            self.flashImageData = flashData
            let progress = flashData.flashElem.progress * 100
            self.progressL.text = "\(progress)%"
            self.progressL.isHidden = !(progress > 0 && progress < 100)
            
            let isRead = flashData.flashElem.isSelf ? flashData.flashElem.from_see : flashData.flashElem.to_see
            self.maskCoverView.image = isRead ? UIImage.bf_imageNamed(name: "flashImg_sel") : UIImage.bf_imageNamed(name: "flashImg_nor")
            self.fireIcon.image = isRead ? UIImage.bf_imageNamed(name: "flashFire_sel") : UIImage.bf_imageNamed(name: "flashFire_nor")
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        self.fireIcon.frame = CGRect(x: self.container.width * 0.5 - 25, y: self.container.height * 0.5 - 25, width: 50, height: 50)
    }
}
