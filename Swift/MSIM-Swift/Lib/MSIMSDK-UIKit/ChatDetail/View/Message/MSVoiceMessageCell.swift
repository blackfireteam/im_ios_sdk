//
//  MSVoiceMessageCell.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/10.
//

import UIKit

open class MSVoiceMessageCell: MSBubbleMessageCell {

    public var voice: UIImageView!
    
    public var durationL: UILabel!
    
    public var voiceData: MSVoiceMessageCellData?
    
    var kvoToken: NSKeyValueObservation?
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        voice = UIImageView()
        voice.animationDuration = 1
        bubbleView.addSubview(voice)
        
        durationL = UILabel()
        durationL.textColor = .gray
        durationL.font = .systemFont(ofSize: 12)
        bubbleView.addSubview(durationL)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        voiceData?.removeObserver(self, forKeyPath: "isPlaying")
    }
    
    public override func fillWithData(data: MSMessageCellData) {
        super.fillWithData(data: data)
        if let voiceData = data as? MSVoiceMessageCellData {
            self.voiceData = voiceData
            if voiceData.message.voiceElem!.duration > 0 {
                durationL.text = String(format: "%ld\"", voiceData.message.voiceElem!.duration)
            }else {
                durationL.text = "1\""
            }
            voice.image = voiceData.voiceImage
            voice.animationImages = voiceData.voiceAnimationImages
            
            self.observe(data: self.voiceData!)
            self.voiceData!.isPlaying = self.voiceData!.isPlaying
            
            if voiceData.direction == .inComing {
                durationL.textAlignment = .left
                durationL.textColor = .gray
            }else {
                durationL.textAlignment = .right
                durationL.textColor = .white
            }
        }
    }
    
    func observe(data: MSVoiceMessageCellData) {
        kvoToken = data.observe(\.isPlaying, options: .new, changeHandler: { voiceData, change in
            if let isPlaying = change.newValue {
                if isPlaying {
                    self.voice.startAnimating()
                }else {
                    self.voice.stopAnimating()
                }
            }
        })
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if voiceData?.direction == .inComing {
            voice.frame = CGRect(x: 16, y: 20 - voiceData!.voiceImage.size.height * 0.5, width: voiceData!.voiceImage.size.width, height: voiceData!.voiceImage.size.height)
            durationL.frame = CGRect(x: voice.right + 10, y: 0, width: 40, height: 20)
            durationL.centerY = voice.centerY
        }else {
            voice.frame = CGRect(x: 0, y: 20 - voiceData!.voiceImage.size.height * 0.5, width: voiceData!.voiceImage.size.width, height: voiceData!.voiceImage.size.height)
            voice.right = container.width - 16
            durationL.frame = CGRect(x: 0, y: 0, width: 40, height: 20)
            durationL.centerY = voice.centerY
            durationL.right = voice.left - 10
        }
    }
}
