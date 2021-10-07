//
//  BFSparkCardCell.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/2.
//

import UIKit
import MSIMSDK
import Kingfisher

protocol BFSparkCardCellDelegate: NSObjectProtocol {
    
    func winkBtnDidClick(cell: BFSparkCardCell)
    
    func chatBtnDidClick(cell: BFSparkCardCell)
}

class BFSparkCardCell: BFCardViewCell {

    var delegate: BFSparkCardCellDelegate?
    
    var titleL: UILabel!
    
    var imageView: UIImageView!
    
    var dislike: UIImageView!
    
    var like: UIImageView!
    
    var chatBtn: UIButton!
    
    var winkBtn: UIButton!
    
    var gradientLayer: CAGradientLayer!
    
    var profile: MSProfileInfo?
    
    override init(reuseIdentifier: String) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .white
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        addSubview(imageView)
        
        gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(r: 0, g: 0, b: 0, alpha: 0).cgColor,UIColor(r: 0, g: 0, b: 0, alpha: 0.8).cgColor]
        gradientLayer.startPoint = .zero
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        imageView.layer.addSublayer(gradientLayer)
        
        titleL = UILabel()
        titleL.textColor = .white
        titleL.font = .boldSystemFont(ofSize: 18)
        imageView.addSubview(titleL)
        
        dislike = UIImageView()
        dislike.image = UIImage(named: "finder_dislike_btn")
        dislike.alpha = 0
        imageView.addSubview(dislike)
        
        like = UIImageView()
        like.image = UIImage(named: "finder_like_btn")
        like.alpha = 0
        imageView.addSubview(like)
        
        winkBtn = UIButton(type: .custom)
        winkBtn.setImage(UIImage(named: "spark_wink"), for: .normal)
        winkBtn.setImage(UIImage(named: "spark_wink_sel"), for: .selected)
        winkBtn.setImage(UIImage(named: "spark_wink_sel"), for: [.selected,.highlighted])
        winkBtn.addTarget(self, action: #selector(winkBtnDidClick), for: .touchUpInside)
        imageView.addSubview(winkBtn)
        
        chatBtn = UIButton(type: .custom)
        chatBtn.setImage(UIImage(named: "spark_chat"), for: .normal)
        chatBtn.addTarget(self, action: #selector(chatBtnDidClick), for: .touchUpInside)
        imageView.addSubview(chatBtn)
        
        layer.cornerRadius = 10
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1
        clipsToBounds = true
    }
    
    func configItem(item: MSProfileInfo) {
        
        self.profile = item
        imageView.kf.setImage(with: URL(string: item.pic))
        titleL.text = item.nick_name
        winkBtn.isSelected = false
    }
    
    @objc func winkBtnDidClick() {
        delegate?.winkBtnDidClick(cell: self)
        UIDevice.impactFeedback()
    }
    
    @objc func chatBtnDidClick() {
        delegate?.chatBtnDidClick(cell: self)
        UIDevice.impactFeedback()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        gradientLayer.frame = CGRect(x: 0, y: imageView.height - 250, width: imageView.width, height: 250)
        titleL.frame = CGRect(x: 20, y: height - 120, width: 200, height: 30)
        like.frame = CGRect(x: 16, y: 16, width: 75, height: 75)
        dislike.frame = CGRect(x: width - 21 - 75, y: 16, width: 75, height: 75)
        winkBtn.frame = CGRect(x: 20, y: titleL.bottom + 15, width: 50, height: 50)
        chatBtn.frame = CGRect(x: winkBtn.right + 15, y: winkBtn.top, width: winkBtn.width, height: winkBtn.height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
