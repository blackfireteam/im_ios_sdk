//
//  MSUnreadView.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/10.
//

import UIKit

open class MSUnreadView: UIView {

    public var unReadLabel: UILabel!
    
    public func setNum(num: Int) {
        
        let unReadStr = String(num)
        unReadLabel.text = unReadStr
        isHidden = num <= 0 ? true : false
        defaultLayout()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        unReadLabel = UILabel()
        unReadLabel.text = "99"
        unReadLabel.font = .systemFont(ofSize: 12)
        unReadLabel.textColor = .white
        unReadLabel.textAlignment = .center
        unReadLabel.sizeToFit()
        addSubview(unReadLabel)
        
        layer.cornerRadius = (unReadLabel.height + 2 * 2) * 0.5
        layer.masksToBounds = true
        backgroundColor = .red
        isHidden = true
        
        defaultLayout()
    }
    
    private func defaultLayout() {
        
        unReadLabel.sizeToFit()
        var width = unReadLabel.width + 2 * 4
        let height = unReadLabel.height + 2 * 2
        if width < height {
            width = height
        }
        bounds = CGRect(x: 0, y: 0, width: width, height: height)
        unReadLabel.frame = bounds
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        var view: UIView = self
        while view.isKind(of: UINavigationBar.self) == false && view.superview != nil {
            view = view.superview!
            if view.isKind(of: UIStackView.self) && view.superview != nil {
                let margin: CGFloat = 40
                view.superview?.addConstraint(NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: view.superview, attribute: .leading, multiplier: 1.0, constant: margin))
            }
        }
    }
}
