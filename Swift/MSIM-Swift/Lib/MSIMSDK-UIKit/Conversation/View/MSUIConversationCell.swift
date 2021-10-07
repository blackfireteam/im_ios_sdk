//
//  MSUIConversationCell.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/10.
//

import UIKit
import MSIMSDK
import Kingfisher

open class MSUIConversationCell: UITableViewCell {

    public var headImageView: UIImageView!
    
    public var titleLabel: UILabel!
    
    public var subTitleLabel: UILabel!
    
    public var timeLabel: UILabel!
    
    public var genderIcon: UIImageView!
    
    public var matchIcon: UIImageView!
    
    public var verifyIcon: UIImageView!
    
    public var unReadView: MSUnreadView!
    
    public var convData: MSUIConversationCellData?
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.d_color(light: MSMcros.TCell_Nomal, dark: MSMcros.TCell_Nomal_Dark)
        
        headImageView = UIImageView()
        headImageView.contentMode = .scaleAspectFill
        contentView.addSubview(headImageView)
        
        timeLabel = UILabel()
        timeLabel.font = .systemFont(ofSize: 12)
        timeLabel.textColor = .systemGray
        contentView.addSubview(timeLabel)
        
        titleLabel = UILabel()
        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.textColor = UIColor.d_color(light: MSMcros.TText_Color, dark: MSMcros.TText_Color_Dark)
        contentView.addSubview(titleLabel)
        
        unReadView = MSUnreadView()
        contentView.addSubview(unReadView)
        
        subTitleLabel = UILabel()
        subTitleLabel.font = .systemFont(ofSize: 13)
        subTitleLabel.textColor = .systemGray
        contentView.addSubview(subTitleLabel)
        
        genderIcon = UIImageView()
        contentView.addSubview(genderIcon)

        separatorInset = UIEdgeInsets(top: 0, left: 97, bottom: 0, right: 0)
        selectionStyle = .none
        
        headImageView.layer.cornerRadius = 34
        headImageView.layer.masksToBounds = true
    }
    
    public func configWithData(convData: MSUIConversationCellData) {
        
        self.convData = convData
        titleLabel.text = convData.title
        timeLabel.text = convData.time.ms_messageString()
        subTitleLabel.attributedText = convData.subTitle
        unReadView.setNum(num: convData.conv.unread_count)
            genderIcon.image = convData.conv.userInfo.gender == 1 ? UIImage.bf_imageNamed(name: "male") : UIImage.bf_imageNamed(name: "female")
        headImageView.kf.setImage(with: URL(string: convData.conv.userInfo.avatar),placeholder: convData.avatarImage)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        headImageView.frame = CGRect(x: 15, y: 17, width: 68, height: 68)
        let titleSize = titleLabel.sizeThatFits(.zero)
        titleLabel.frame = CGRect(x: headImageView.right + 14, y: 31, width: min(titleSize.width, 150), height: 22)
        let timeSize = timeLabel.sizeThatFits(CGSize(width: 200, height: 20))
        timeLabel.frame = CGRect(x: contentView.width - 15 - timeSize.width, y: titleLabel.centerY - timeSize.height * 0.5, width: timeSize.width, height: timeSize.height)
        subTitleLabel.frame = CGRect(x: titleLabel.left, y: titleLabel.bottom + 5, width: 250, height: 16)
        unReadView.right = width - 15
        unReadView.top = subTitleLabel.top
            self.genderIcon.frame = CGRect(x: titleLabel.right + 5, y: titleLabel.centerY - 6, width: 12, height: 12)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
