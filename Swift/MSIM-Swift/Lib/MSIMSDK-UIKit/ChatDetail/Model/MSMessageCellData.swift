//
//  MSMessageCellData.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/4.
//

import UIKit
import MSIMSDK


/**
 *  消息方向枚举
 *  消息方向影响气泡图标、气泡位置等 UI 风格。
 */
public enum TMsgDirection {
    case inComing  //消息接收
    case outGoing //消息发送
}

open class MSMessageCellData: NSObject {

    public var defaultAvatar: UIImage?
    
    public var direction: TMsgDirection = .inComing
    
    public var showName: Bool = false
    
    public var message: MSIMMessage!
    
    public var reUseId: String {
        return "MSMessageCell"
    }
    
    public func contentSize() -> CGSize {
        return .zero
    }
    
    public func heightOfWidth(width: CGFloat) -> CGFloat {
        var height: CGFloat = 0
        if showName {
            height += 25
        }
        let containerSize = contentSize()
        height += containerSize.height
        if direction == .outGoing {
            height += 20
        }
        height += 5
        return height
    }
    
    public init(direction: TMsgDirection) {
        self.direction = direction
        super.init()
        
        defaultAvatar = UIImage.bf_imageNamed(name: "holder_avatar")
    }
}
