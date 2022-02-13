//
//  MSLocationMessageCell.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/12/9.
//

import UIKit
import Kingfisher


open class MSLocationMessageCell: MSMessageCell {

    public var titleL: UILabel!
    
    public var detailL: UILabel!
    
    public var mapImageView: UIImageView!
    
    public var locationData: MSLocationMessageCellData?
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleL = UILabel()
        titleL.textColor = UIColor.d_color(light: MSMcros.TText_Color, dark: MSMcros.TText_Color_Dark)
        titleL.font = .systemFont(ofSize: 16)
        container.addSubview(titleL)
        
        detailL = UILabel()
        detailL.textColor = .gray
        detailL.font = .systemFont(ofSize: 13)
        container.addSubview(detailL)
        
        mapImageView = UIImageView()
        mapImageView.contentMode = .scaleAspectFill
        mapImageView.clipsToBounds = true
        container.addSubview(mapImageView)
        
        container.layer.cornerRadius = 5
        container.layer.masksToBounds = true
        container.backgroundColor = UIColor.d_color(light: .white, dark: .clear)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func fillWithData(data: MSMessageCellData) {
        super.fillWithData(data: data)
        if let data = data as? MSLocationMessageCellData {
            self.locationData = data
            self.titleL.text = data.message.locationElem!.title
            self.detailL.text = data.message.locationElem!.detail
            let mapUrl = "https://restapi.amap.com/v3/staticmap?location=\(data.message.locationElem!.longitude),\(data.message.locationElem!.latitude)&zoom=\(data.message.locationElem!.zoom)&size=550*300&markers=mid,,A:\(data.message.locationElem!.longitude),\(data.message.locationElem!.latitude)&key=\(MSMcros.GaodeAPIWebKey)"
            mapImageView.kf.setImage(with: URL(string: mapUrl))
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.titleL.frame = CGRect(x: 10, y: 10, width: self.container.width - 20, height: 16)
        self.detailL.frame = CGRect(x: 10, y: self.titleL.bottom + 6, width: self.titleL.width, height: 13)
        self.mapImageView.frame = CGRect(x: 0, y: self.detailL.bottom + 6, width: self.container.width, height: self.container.height - self.detailL.bottom - 6)
    }
}
