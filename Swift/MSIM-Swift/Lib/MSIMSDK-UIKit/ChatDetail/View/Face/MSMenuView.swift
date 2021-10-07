//
//  MSMenuView.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/3.
//

import UIKit

protocol MSMenuViewDelegate: NSObjectProtocol {
    
    func menuViewDidSendMessage(menuView: MSMenuView)
}

class MSMenuView: UIView {

    weak var delegate: MSMenuViewDelegate?
    
    private var sendButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.d_color(light: MSMcros.TInput_Background_Color, dark: MSMcros.TInput_Background_Color_Dark)
        
        sendButton = UIButton()
        sendButton.titleLabel?.font = .systemFont(ofSize: 15)
        sendButton.setTitle(Bundle.bf_localizedString(key: "Send"), for: .normal)
        sendButton.backgroundColor = UIColor(r: 87, g: 190, b: 105)
        sendButton.addTarget(self, action: #selector(sendUpInside), for: .touchUpInside)
        addSubview(sendButton)
        
        let buttonWidth = frame.height * 1.3
        sendButton.frame = CGRect(x: frame.width - buttonWidth, y: 0, width: buttonWidth, height: frame.height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func sendUpInside() {
        
        delegate?.menuViewDidSendMessage(menuView: self)
    }
}
