//
//  MSImageMessageCell.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/6.
//

import UIKit
import Kingfisher


open class MSImageMessageCell: MSMessageCell {

    public var thumb: UIImageView!
    
    public var progress: UILabel!
    
    public var imageData: MSImageMessageCellData?
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        thumb = UIImageView()
        thumb.layer.cornerRadius = 5
        thumb.layer.masksToBounds = true
        thumb.contentMode = .scaleAspectFit
        thumb.backgroundColor = .white
        container.addSubview(thumb)
        thumb.frame = container.bounds
        thumb.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        
        progress = UILabel()
        progress.textColor = .white
        progress.font = .systemFont(ofSize: 15)
        progress.textAlignment = .center
        progress.layer.cornerRadius = 5
        progress.isHidden = true
        progress.backgroundColor = MSMcros.TImageMessageCell_Progress_Color
        progress.layer.masksToBounds = true
        container.addSubview(progress)
        progress.frame = container.bounds
        progress.autoresizingMask = [.flexibleWidth,.flexibleHeight]
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func fillWithData(data: MSMessageCellData) {
        super.fillWithData(data: data)
        if let imageData = data as? MSImageMessageCellData {
            self.imageData = imageData
            let progress = imageData.message.imageElem!.progress * 100
            self.progress.text = "\(progress)%"
            self.progress.isHidden = !(progress > 0 && progress < 100)
            thumb.image = nil
            if imageData.message.imageElem!.image != nil {
                thumb.image = imageData.message.imageElem!.image
            }else if imageData.message.imageElem!.path != nil && FileManager.default.fileExists(atPath: imageData.message.imageElem!.path!) {
                let image = UIImage(contentsOfFile: imageData.message.imageElem!.path!)!
                thumb.image = image
                imageData.message.imageElem!.image = image
            }else if imageData.message.imageElem!.url != nil {
                let thumbUrl = imageData.message.imageElem!.url! + "?imageMogr2/thumbnail/300x/interlace/0"
                thumb.kf.setImage(with: URL(string: thumbUrl), options: [KingfisherOptionsInfoItem.onFailureImage(UIImage.bf_imageNamed(name: "placeholder_delete"))])
            }
        }
    }
}
