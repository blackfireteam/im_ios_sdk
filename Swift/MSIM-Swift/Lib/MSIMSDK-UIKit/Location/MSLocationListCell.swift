//
//  MSLocationListCell.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/12/9.
//

import UIKit

class MSLocationListCell: UITableViewCell {

    public var locationInfo:  MSLocationInfo! {
        didSet {
            titleL.text = locationInfo.name
            addressL.text = "\(locationInfo.distance) m | \(locationInfo.district)\(locationInfo.address)"
            checkIcon.isHidden = !locationInfo.isSelect
        }
    }
    
    lazy private var titleL: UILabel = {
        let titleL = UILabel()
        titleL.font = .systemFont(ofSize: 16)
        titleL.textColor = UIColor.d_color(light: MSMcros.TText_Color, dark: MSMcros.TText_Color_Dark)
        return titleL
    }()
    
    lazy private var addressL: UILabel = {
        let addressL = UILabel()
        addressL.font = .systemFont(ofSize: 13)
        addressL.textColor = .systemGray
        return addressL
    }()
    
    lazy private var checkIcon: UIImageView = {
        let checkIcon = UIImageView()
        checkIcon.image = UIImage.bf_imageNamed(name: "ic_selected")
        return checkIcon
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.d_color(light: MSMcros.TCell_Nomal, dark: MSMcros.TCell_Nomal_Dark)
        
        contentView.addSubview(titleL)
        contentView.addSubview(addressL)
        contentView.addSubview(checkIcon)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleL.frame = CGRect(x: 15, y: 15, width: UIScreen.width - 30 - 40, height: 16)
        addressL.frame = CGRect(x: 15, y: titleL.bottom + 10, width: titleL.width, height: 13)
        checkIcon.frame = CGRect(x: UIScreen.width - 15 - 22, y: self.height * 0.5 - 11, width: 22, height: 22)
    }
}
