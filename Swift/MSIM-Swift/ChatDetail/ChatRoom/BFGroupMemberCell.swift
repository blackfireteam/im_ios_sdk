//
//  BFGroupMemberCell.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/11/9.
//

import UIKit
import Kingfisher
import MSIMSDK

class BFGroupMemberCell: UICollectionViewCell {
    
    lazy var avatarView: UIImageView = {
        let avatarView = UIImageView()
        avatarView.contentMode = .scaleAspectFill
        avatarView.clipsToBounds = true
        return avatarView
    }()
    
    lazy var nameL: UILabel = {
        let nameL = UILabel()
        nameL.font = .boldSystemFont(ofSize: 16)
        nameL.textColor = UIColor.d_color(light: MSMcros.TText_Color, dark: MSMcros.TText_Color_Dark)
        nameL.textAlignment = .center
        return nameL
    }()
    
    lazy var idL: UILabel = {
        let idL = UILabel()
        idL.textAlignment = .center
        idL.font = .systemFont(ofSize: 12)
        idL.textColor = .white
        idL.backgroundColor = .lightGray
        return idL
    }()
    
    lazy var muteL: UILabel = {
        let muteL = UILabel()
        muteL.textAlignment = .center
        muteL.font = .systemFont(ofSize: 12)
        muteL.textColor = .white
        muteL.backgroundColor = .black
        muteL.text = "禁言"
        return muteL
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.d_color(light: MSMcros.TCell_Nomal, dark: MSMcros.TCell_Nomal_Dark)
        layer.cornerRadius = 6
        layer.masksToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.d_color(light: MSMcros.TCell_separatorColor, dark: MSMcros.TCell_separatorColor_Dark).cgColor
        
        addSubview(self.avatarView)
        addSubview(self.nameL)
        addSubview(self.idL)
        addSubview(self.muteL)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var info: MSGroupMemberItem? {
        didSet {
            if let _info = info {
                self.avatarView.kf.setImage(with: URL(string: _info.profile?.avatar ?? ""))
                if _info.uid == MSIMTools.sharedInstance().user_id {
                    self.nameL.text = "Me"
                }else {
                    self.nameL.text = _info.profile?.nick_name
                }
                if _info.role == 0 {
                    self.idL.text = "用户"
                }else if _info.role == 1 {
                    self.idL.text = "临时管理员"
                }else {
                    self.idL.text = "管理员"
                }
                self.muteL.isHidden = !_info.is_mute
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.avatarView.frame = CGRect(x: 0, y: 0, width: self.width, height: self.height - 40)
        self.nameL.frame = CGRect(x: 0, y: self.height - 40, width: self.width, height: 40)
        self.idL.frame = CGRect(x: 3, y: 3, width: 80, height: 30)
        self.muteL.frame = CGRect(x: self.width - 3 - 60, y: 3, width: 60, height: 30)
    }
}
