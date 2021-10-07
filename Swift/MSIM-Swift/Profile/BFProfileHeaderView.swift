//
//  BFProfileHeaderView.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/7/29.
//

import UIKit

class BFProfileHeaderView: UIView {

    var avatarIcon: UIImageView!
    
    var nickNameL: UILabel!
    
    var editIcon: UIImageView!
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        avatarIcon = UIImageView()
        avatarIcon.contentMode = .scaleAspectFill
        avatarIcon.layer.cornerRadius = 57
        avatarIcon.layer.masksToBounds = true
        avatarIcon.frame = CGRect(x: UIScreen.width * 0.5 - 57, y: UIScreen.statusbarHeight + 30, width: 114, height: 114)
        avatarIcon.backgroundColor = .lightGray
        avatarIcon.isUserInteractionEnabled = true
        addSubview(avatarIcon)
        
        nickNameL = UILabel()
        nickNameL.textColor = UIColor.d_color(light: .black, dark: .white)
        nickNameL.font = .boldSystemFont(ofSize: 20)
        nickNameL.textAlignment = .center
        nickNameL.frame = CGRect(x: UIScreen.width * 0.5 - 100, y: avatarIcon.bottom + 25, width: 200, height: 27)
        addSubview(nickNameL)
        
        editIcon = UIImageView()
        editIcon.image = UIImage(named: "edit_avatar")
        editIcon.frame = CGRect(x: avatarIcon.right - 45, y: avatarIcon.bottom - 18, width: 25, height: 25)
        addSubview(editIcon)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
