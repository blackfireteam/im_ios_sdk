//
//  BFNaviBarIndicatorView.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/10.
//

import UIKit

class BFNaviBarIndicatorView: UIView {

    var indicator: UIActivityIndicatorView!
    
    var label: UILabel!
    
    func setTitle(title: String) {
        
        label.text = title
        updateLayout()
    }
    
    func startAnimating() {
        indicator.startAnimating()
    }
    
    func stopAnimating() {
        indicator.stopAnimating()
    }
    
    private func updateLayout() {
        
        let labelSize = label.sizeThatFits(CGSize(width: UIScreen.width, height: UIScreen.height))
        let labelY: CGFloat = 0
        let labelX: CGFloat = indicator.isHidden ? 0 : (indicator.left + indicator.width + 5)
        label.frame = CGRect(x: labelX, y: labelY, width: labelSize.width, height: UIScreen.navBarHeight)
        frame = CGRect(x: 0, y: 0, width: labelX + labelSize.width + 5, height: UIScreen.navBarHeight)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        indicator.center = CGPoint(x: 0, y: UIScreen.navBarHeight * 0.5)
        indicator.style = .medium
        addSubview(indicator)
        
        label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = UIColor.d_color(light: MSMcros.TText_Color, dark: MSMcros.TText_Color_Dark)
        addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
