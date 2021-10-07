//
//  MSFaceUtil.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/3.
//

import UIKit

open class MSFaceUtil: NSObject {

    static let shared = MSFaceUtil()
    
    private override init() {}
    
    lazy var defaultFace: [BFFaceGroup] = {
        
        var defaultFace = [BFFaceGroup]()
        var emojiFaces: [BFFaceCellData] = []
        if let emojis = NSArray(contentsOfFile: MSMcros.TUIKitFace(name: "emoji/emoji.plist")) as? [NSDictionary] {
            for dic in emojis {
                let data = BFFaceCellData()
                let name = dic["face_name"] as! String
                data.name = "emoji/\(name)"
                emojiFaces.append(data)
            }
            if emojiFaces.count != 0 {
                let emojiGroup = BFFaceGroup()
                emojiGroup.groupIndex = 0
                emojiGroup.groupPath = MSMcros.TUIKitFace(name: "emoji/")
                emojiGroup.faces = emojiFaces
                emojiGroup.rowCount = 3
                emojiGroup.itemCountPerRow = 9
                emojiGroup.needBackDelete = true
                defaultFace.append(emojiGroup)
            }
        }
        return defaultFace
    }()
}
