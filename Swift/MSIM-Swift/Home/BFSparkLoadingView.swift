//
//  BFSparkLoadingView.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/7/29.
//

import UIKit
import MSIMSDK
import Kingfisher

class BFSparkLoadingView: UIView {

    public func beginAnimating() {
        
        alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        } completion: { _ in
            let ani = CABasicAnimation(keyPath: "transform.rotation.z")
            ani.fromValue = NSNumber(floatLiteral: 0)
            ani.toValue = NSNumber(floatLiteral: Double.pi * 2)
            ani.duration = 3
            ani.autoreverses = false
            ani.fillMode = .forwards
            ani.repeatCount = Float.greatestFiniteMagnitude
            ani.isRemovedOnCompletion = false
            self.topImg.layer.add(ani, forKey: nil)
        }
    }
    
    public func stopAnimating() {
        
        UIView.animate(withDuration: 0.25) {
            self.alpha = 0
        } completion: { _ in
            self.topImg.layer.removeAllAnimations()
        }
    }
    
    private let bgImg = UIImageView(image: UIImage(named: "loadingbg"))
    
    private let topImg = UIImageView(image: UIImage(named: "loadingtop"))
    
    private let maskImg = UIImageView(image: UIImage(named: "loadingheadmask"))
    
    private var headImg = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bgImg)
        addSubview(topImg)
        addSubview(maskImg)
        
        headImg.contentMode = .scaleAspectFill;
        headImg.layer.cornerRadius = 4
        headImg.layer.masksToBounds = true
        if let uid = MSIMTools.sharedInstance().user_id,let me = MSProfileProvider().providerProfile(fromLocal: uid) {
            headImg.kf.setImage(with: URL(string: me.avatar))
        }
        addSubview(headImg)
        alpha = 0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bgImg.frame = CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.width)
        bgImg.center = center
        topImg.frame = CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.width)
        topImg.center = center
        maskImg.frame = CGRect(x: 0, y: 0, width: 97, height: 97)
        maskImg.center = center
        headImg.frame = CGRect(x: 0, y: 0, width: 41, height: 55)
        headImg.center = center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
