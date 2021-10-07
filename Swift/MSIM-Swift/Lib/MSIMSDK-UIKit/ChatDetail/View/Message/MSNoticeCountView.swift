//
//  MSNoticeCountView.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/10.
//

import UIKit

public protocol MSNoticeCountViewDelegate: NSObjectProtocol {
    
    func countViewDidTap()
}

open class MSNoticeCountView: UIView {

    public weak var delegate: MSNoticeCountViewDelegate?
    
    public var countBtn: UIButton!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        countBtn = UIButton(type: .custom)
        countBtn.setTitleColor(.white, for: .normal)
        countBtn.titleLabel?.font = .systemFont(ofSize: 13)
        countBtn.backgroundColor = .blue
        countBtn.addTarget(self, action: #selector(countBtnDidClick), for: .touchUpInside)
        addSubview(countBtn)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func increaseCount(count: Int) {
        self.isHidden = false
        let countStr = countBtn.titleLabel?.text ?? ""
        let p_count = Int(countStr) ?? 0
        countBtn.setTitle(String(format: "%zd",p_count + count), for: .normal)
    }
    
    public func cleanCount() {
        countBtn.setTitle("0", for: .normal)
        self.isHidden = true
    }
    
    @objc func countBtnDidClick() {
        delegate?.countViewDidTap()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        countBtn.frame = bounds
        layer.cornerRadius = height * 0.5
        layer.masksToBounds = true
    }
}
