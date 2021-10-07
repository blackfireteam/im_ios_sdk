//
//  MSBubbleMessageCellData.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/4.
//

import UIKit

open class MSBubbleMessageCellData: MSMessageCellData {

    /**
     *  气泡图标（正常）
     *  气泡图标会根据消息是发送还是接受作出改变，数据源中已实现相关业务逻辑。您也可以根据需求进行个性化定制。
     */
    public var bubble: UIImage?
    
    /**
     *  气泡图标（高亮）
     *  气泡图标会根据消息是发送还是接受作出改变，数据源中已实现相关业务逻辑。您也可以根据需求进行个性化定制。
     */
    public var highlightedBubble: UIImage?
    
    /**
     *  发送气泡图标（正常）
     *  气泡的发送图标，当气泡消息单元为发送时赋值给 bubble。
     */
    public var outgoingBubble: UIImage = UIImage.bf_imageNamed(name: "sender_text_normal")!.resizableImage(withCapInsets: UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 22), resizingMode: .stretch)
    
    /**
     *  发送气泡图标（高亮）
     *  气泡的发送图标（高亮），当气泡消息单元为发送时赋值给 highlightedBubble。
     */
    public var outgoingHighlightedBubble: UIImage = UIImage.bf_imageNamed(name: "sender_text_pressed")!.resizableImage(withCapInsets: UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 22), resizingMode: .stretch)
    
    /**
     *  接收气泡图标（正常）
     *  气泡的接收图标，当气泡消息单元为接收时赋值给 bubble。
     */
    public var incommingBubble: UIImage = UIImage.bf_image(light: "receiver_text_normal", dark: "receiver_text_pressed")!.resizableImage(withCapInsets: UIEdgeInsets(top: 15, left: 23, bottom: 15, right: 16), resizingMode: .stretch)
    
    /**
     *  接收气泡图标（高亮）
     *  气泡的接收图标，当气泡消息单元为接收时赋值给 highlightedBubble。
     */
    public var incommingHighlightedBubble: UIImage = UIImage.bf_imageNamed(name: "receiver_text_pressed")!.resizableImage(withCapInsets: UIEdgeInsets(top: 15, left: 23, bottom: 15, right: 16), resizingMode: .stretch)
    
    public override init(direction: TMsgDirection) {
        super.init(direction: direction)
        if direction == .inComing {
            bubble = incommingBubble
            highlightedBubble = incommingHighlightedBubble
        }else {
            bubble = outgoingBubble
            highlightedBubble = outgoingHighlightedBubble
        }
    }
}
