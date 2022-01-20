//
//  MSVideoMessageCell.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/10.
//

import UIKit
import Kingfisher



open class MSVideoMessageCell: MSMessageCell {

    public var thumb: UIImageView!
    
    public var durationL: UILabel!
    
    public var playIcon: UIImageView!
    
    public var progressL: UILabel!
    
    public var videoData: MSVideoMessageCellData?
    
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
        
        let playSize = MSMcros.TVideoMessageCell_Play_Size
        playIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: playSize.width, height: playSize.height))
        playIcon.contentMode = .scaleAspectFit
        playIcon.image = UIImage.bf_imageNamed(name: "play_normal")
        container.addSubview(playIcon)
        
        durationL = UILabel()
        durationL.textColor = .white
        durationL.font = .systemFont(ofSize: 12)
        container.addSubview(durationL)
        
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
        if let videoData = data as? MSVideoMessageCellData {
            self.videoData = videoData
            self.durationL.text = String(format: "%02zd:%02zd", videoData.videoElem.duration / 60, videoData.videoElem.duration % 60)
            self.durationL.sizeToFit()
            let progress = videoData.videoElem.progress * 100
            self.progressL.text = String.init(format: "%.1f%%", videoData.videoElem.progress * 100)
            self.progressL.isHidden = !(progress > 0 && progress < 100)
            thumb.image = nil
            if videoData.videoElem.coverImage != nil {
                thumb.image = videoData.videoElem.coverImage
            }else if videoData.videoElem.coverPath != nil && FileManager.default.fileExists(atPath: videoData.videoElem.coverPath!) {
                let image = UIImage(contentsOfFile: videoData.videoElem.coverPath!)!
                thumb.image = image
                videoData.videoElem.coverImage = image
            }else if videoData.videoElem.coverUrl != nil {
                let thumbUrl = videoData.videoElem.coverUrl! + "?imageMogr2/thumbnail/300x/interlace/0"
                thumb.kf.setImage(with: URL(string: thumbUrl), options: [KingfisherOptionsInfoItem.onFailureImage(UIImage.bf_imageNamed(name: "placeholder_delete"))])
            }
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        playIcon.center = CGPoint(x: container.width * 0.5, y: container.height * 0.5)
        durationL.bottom = container.height - MSMcros.TVideoMessageCell_Margin_3
        durationL.right = container.width  - MSMcros.TVideoMessageCell_Margin_3
    }
}
