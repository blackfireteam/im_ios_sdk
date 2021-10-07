//
//  BFUserListCell.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/10.
//

import UIKit
import MSIMSDK
import Kingfisher

class BFUserListCell: UICollectionViewCell {

    var avatarView: UIImageView!
    
    var nameLabel: UILabel!
    
    var liveIcon: UIImageView!
    
    func config(info: MSProfileInfo?) {
        if let info = info {
            avatarView.kf.setImage(with: URL(string: info.avatar))
            nameLabel.text = info.nick_name
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.d_color(light: MSMcros.TCell_Nomal, dark: MSMcros.TCell_Nomal_Dark)
        layer.cornerRadius = 6
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.d_color(light: MSMcros.TCell_separatorColor, dark: MSMcros.TCell_separatorColor_Dark).cgColor
        
        avatarView = UIImageView()
        avatarView.contentMode = .scaleAspectFill
        avatarView.clipsToBounds = true
        contentView.addSubview(avatarView)
        
        nameLabel = UILabel()
        nameLabel.font = .boldSystemFont(ofSize: 16)
        nameLabel.textColor = UIColor.d_color(light: MSMcros.TText_Color, dark: MSMcros.TText_Color_Dark)
        nameLabel.textAlignment = .center
        contentView.addSubview(nameLabel)
        
        liveIcon = UIImageView()
        liveIcon.image = UIImage(named: "user_living")
        contentView.addSubview(liveIcon)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarView.frame = CGRect(x: 0, y: 0, width: width, height: height - 40)
        nameLabel.frame = CGRect(x: 0, y: height - 40, width: width, height: 40)
        liveIcon.frame = CGRect(x: 3, y: 3, width: 14, height: 14)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
