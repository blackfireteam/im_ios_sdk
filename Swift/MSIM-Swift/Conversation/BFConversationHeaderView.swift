//
//  BFConversationHeaderView.swift
//  MSIM-Swift
//
//  Created by benny wang on 2022/2/13.
//

import UIKit
import MSIMSDK


class BFConversationHeaderView: UIView {

    var icon: UIImageView!
    
    var titleL: UILabel!
    
    var redDot: UIView!
    
    var subTitleL: UILabel!
    
    var timeL: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.d_color(light: MSMcros.TCell_Nomal, dark: MSMcros.TCell_Nomal_Dark)
        
        icon = UIImageView()
        icon.contentMode = .scaleAspectFill
        icon.clipsToBounds = true
        icon.image = UIImage(named: "chat_btn")
        addSubview(icon)
        
        titleL = UILabel()
        titleL.textColor = UIColor.d_color(light: MSMcros.TText_Color, dark: MSMcros.TText_Color_Dark)
        titleL.text = "聊天室"
        titleL.font = .boldSystemFont(ofSize: 17)
        addSubview(titleL)
        
        subTitleL = UILabel()
        subTitleL.font = .systemFont(ofSize: 13)
        subTitleL.textColor = UIColor.systemGray
        addSubview(subTitleL)
        
        timeL = UILabel()
        timeL.font = .systemFont(ofSize: 12)
        timeL.textColor = UIColor.systemGray
        addSubview(timeL)
        
        redDot = UIView()
        redDot.backgroundColor = .red
        redDot.layer.cornerRadius = 4
        redDot.layer.masksToBounds = true
        addSubview(redDot)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadData() {
        
        //模拟会话列表的展示方式
        let roomName = MSChatRoomManager.sharedInstance().chatroomInfo?.room_name
        self.titleL.text = roomName ?? "聊天室"
        let conv = MSIMConversation()
        let convData = MSUIConversationCellData(conv: conv)
        conv.show_msg = MSChatRoomManager.sharedInstance().last_show_msg ?? MSIMMessage()
        conv.time = MSChatRoomManager.sharedInstance().last_show_msg?.msgSign ?? 0
        self.subTitleL.attributedText = convData.subTitle;
        self.timeL.text = convData.time.ms_messageString()
        self.redDot.isHidden = !(MSChatRoomManager.sharedInstance().unreadCount > 0);
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        icon.frame = CGRect(x: 15, y: 17, width: 68, height: 68)
        titleL.frame = CGRect(x: icon.right + 14, y: 31, width: 200, height: 22)
        let timeSize = timeL.sizeThatFits(CGSize(width: 200, height: 20))
        timeL.frame = CGRect(x: self.width - 15 - timeSize.width, y: titleL.centerY - timeSize.height * 0.5, width: timeSize.width, height: timeSize.height)
        subTitleL.frame = CGRect(x: titleL.left, y: titleL.bottom + 5, width: 250, height: 16)
        redDot.frame = CGRect(x: self.width - 15 - 8, y: subTitleL.top, width: 8, height: 8)
    }
}
