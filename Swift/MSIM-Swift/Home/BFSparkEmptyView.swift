//
//  BFSparkEmptyView.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/7/29.
//

import UIKit

class BFSparkEmptyView: UIView {

    var titleL: UILabel!
    
    var noDataIcon: UIImageView!
    
    var retryBtn: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        noDataIcon = UIImageView()
        noDataIcon.image = UIImage(named: "meet_nodata")
        noDataIcon.frame = CGRect(x: (UIScreen.width - 148) * 0.5, y: 0, width: 148, height: 148)
        addSubview(noDataIcon)
        
        titleL = UILabel()
        titleL.textColor = UIColor(r: 144, g: 144, b: 144)
        titleL.textAlignment = .center
        titleL.font = .systemFont(ofSize: 16)
        titleL.text = Bundle.bf_localizedString(key: "TUIKitNoMoreData")
        titleL.frame = CGRect(x: 0, y: noDataIcon.bottom + 10, width: UIScreen.width, height: 20)
        addSubview(titleL)
        
        retryBtn = UIButton(type: .custom)
        retryBtn.backgroundColor = UIColor(r: 245, g: 245, b: 245)
        retryBtn.setTitle(Bundle.bf_localizedString(key: "TUIKitRefresh"), for: .normal)
        retryBtn.setTitleColor(UIColor(r: 51, g: 51, b: 51), for: .normal)
        retryBtn.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        retryBtn.frame = CGRect(x: (UIScreen.width - 203) * 0.5, y: titleL.bottom + 16, width: 203, height: 44)
        retryBtn.layer.cornerRadius = 8
        retryBtn.layer.masksToBounds = true
        addSubview(retryBtn)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
