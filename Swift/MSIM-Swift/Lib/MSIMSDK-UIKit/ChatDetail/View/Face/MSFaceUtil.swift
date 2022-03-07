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
    
    lazy var defaultEmojiGroup: MSFaceGroup? = {
        
        var emojiFaces: [MSFaceCellData] = []
        if let emojis = NSArray(contentsOfFile: MSMcros.TUIKitFace(name: "emoji/emoji.plist")) as? [NSDictionary] {
            for dic in emojis {
                let data = MSFaceCellData()
                data.e_id = dic["face_id"] as? String
                data.name = dic["face_name"] as? String
                data.facePath = MSMcros.TUIKitFace(name: "emoji/") + data.name!
                emojiFaces.append(data)
            }
            if emojiFaces.count != 0 {
                let emojiGroup = MSFaceGroup()
                emojiGroup.groupIndex = 0
                emojiGroup.groupPath = MSMcros.TUIKitFace(name: "emoji/")
                emojiGroup.faces = emojiFaces
                emojiGroup.rowCount = 3
                emojiGroup.itemCountPerRow = 9
                emojiGroup.needBackDelete = true
                emojiGroup.needSendBtn = true
                emojiGroup.menuNormalPath = MSMcros.TUIKitFace(name: "emoji/emoj_normal")
                emojiGroup.menuSelectPath = MSMcros.TUIKitFace(name: "emoji/emoj_pressed")
                return emojiGroup
            }
        }
        return nil
    }()
    
    lazy var faceGroups: [MSFaceGroup] = {
        
        var faceGroups: [MSFaceGroup] = []
        if self.defaultEmojiGroup != nil {
            faceGroups.append(self.defaultEmojiGroup!)
        }
        
        var emotionFaces: [MSFaceCellData] = []
        if let emotions = NSArray(contentsOfFile: MSMcros.TUIKitFace(name: "emotion/emotion.plist")) as? [NSDictionary] {
            for dic in emotions {
                let data = MSFaceCellData()
                data.e_id = dic["id"] as? String
                data.name = dic["image"] as? String
                data.facePath = MSMcros.TUIKitFace(name: "emotion/") + data.name!
                emotionFaces.append(data)
            }
            if emotionFaces.count != 0 {
                let emotionGroup = MSFaceGroup()
                emotionGroup.groupIndex = 1
                emotionGroup.groupPath = MSMcros.TUIKitFace(name: "emotion/")
                emotionGroup.faces = emotionFaces
                emotionGroup.rowCount = 2
                emotionGroup.itemCountPerRow = 5
                emotionGroup.needBackDelete = false
                emotionGroup.needSendBtn = false
                emotionGroup.menuNormalPath = MSMcros.TUIKitFace(name: "emotion/emotion_normal")
                emotionGroup.menuSelectPath = MSMcros.TUIKitFace(name: "emotion/emotion_pressed")
                faceGroups.append(emotionGroup)
            }
        }
        return faceGroups
    }()
}
