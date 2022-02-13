//
//  MSVoiceMessageCellData.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/5.
//

import UIKit
import MSIMSDK
import AVFoundation


open class MSVoiceMessageCellData: MSBubbleMessageCellData {

    public var voiceAnimationImages: [UIImage] = []
    
    public var voiceImage: UIImage!
    
    @objc dynamic public var isPlaying: Bool = false
    
    public private(set) var isDownloading: Bool = false
    
    public func playVoiceMessage() {
        if isPlaying {return}
        isPlaying = true
        guard let path = message.voiceElem!.path else {return}
        if FileManager.default.fileExists(atPath: path) {
            playInternal(path: path)
        }else {
            if isDownloading {return}
            if message.voiceElem?.url == nil {return}
            isDownloading = true
            let savePath = FileManager.pathForIMVoice().appendingFormat("/%@", (message.voiceElem!.url! as NSString).lastPathComponent)
            MSIMManager.sharedInstance().uploadMediator?.ms_download?(fromUrl: message.voiceElem!.url!, toSavePath: savePath, progress: { progress in
                
            }, succ: { url in
                
                self.isDownloading = false
                self.message.voiceElem?.path = savePath
                self.playInternal(path: savePath)
                
            }, fail: { code, desc in
                self.isDownloading = false
                self.stopVoiceMessage()
            })
        }
    }
    
    public func stopVoiceMessage() {
        if audioPlayer?.isPlaying == true {
            audioPlayer?.stop()
            audioPlayer = nil
        }
        isPlaying = false
    }
    
    private var audioPlayer: AVAudioPlayer?
    
    public override init(direction: TMsgDirection) {
        super.init(direction: direction)
        if direction == .inComing {
            voiceImage = UIImage.bf_imageNamed(name: "receiver_voice")
            voiceAnimationImages = [UIImage.bf_imageNamed(name: "receiver_voice_play_1")!,UIImage.bf_imageNamed(name: "receiver_voice_play_2")!,UIImage.bf_imageNamed(name: "receiver_voice_play_3")!]
        }else {
            voiceImage = UIImage.bf_imageNamed(name: "sender_voice")
            voiceAnimationImages = [UIImage.bf_imageNamed(name: "sender_voice_play_1")!,UIImage.bf_imageNamed(name: "sender_voice_play_2")!,UIImage.bf_imageNamed(name: "sender_voice_play_3")!]
        }
    }
    
    public override func contentSize() -> CGSize {
        var bubbleWidth = MSMcros.TVoiceMessageCell_Back_Width_Min + CGFloat(message.voiceElem!.duration) / MSMcros.TVoiceMessageCell_Max_Duration * UIScreen.width
        if bubbleWidth > MSMcros.TVoiceMessageCell_Back_Width_Max {
            bubbleWidth = MSMcros.TVoiceMessageCell_Back_Width_Max
        }
        
        var bubbleHeight = MSMcros.TVoiceMessageCell_Duration_Size.height
        if direction == .inComing {
            bubbleWidth = max(bubbleWidth, incommingBubble.size.width)
            bubbleHeight = 40
        }else {
            bubbleWidth = max(bubbleWidth, outgoingBubble.size.width)
            bubbleHeight = 40
        }
        return CGSize(width: bubbleWidth + MSMcros.TVoiceMessageCell_Duration_Size.width, height: bubbleHeight)
    }
    
    public override var reUseId: String {
        return MSMcros.TVoiceMessageCell_ReuseId
    }
}

private extension MSVoiceMessageCellData {
    
    func playInternal(path: String) {
        
        if !isPlaying {return}
        
        try? AVAudioSession.sharedInstance().setCategory(.playback, options: [])
        let url = URL(fileURLWithPath: path)
        audioPlayer?.stop()
        do {
            audioPlayer = try AVAudioPlayer(data: Data(contentsOf: url))
            audioPlayer?.delegate = self
            if audioPlayer?.play() == false {
                isPlaying = false
                MSHelper.showToastFailWithText(text: "音频文件不存在或已损坏")
            }
        }catch {
            print(error)
            isPlaying = false
        }
    }
}

extension MSVoiceMessageCellData: AVAudioPlayerDelegate {
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }
    
    public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        isPlaying = false
        print("音频播放失败：%@",error!)
        MSHelper.showToastFailWithText(text: "音频文件解码失败")
    }
}
