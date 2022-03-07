//
//  MSEmotionMessageCell.swift
//  MSIM-Swift
//
//  Created by benny wang on 2022/2/13.
//

import UIKit
import MSIMSDK
import Lottie

open class MSEmotionMessageCell: MSMessageCell {

    public var animationView: AnimationView!
    
    public private(set) var emotionData: MSEmotionMessageCellData?

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        animationView = AnimationView()
        container.addSubview(animationView)
        animationView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func fillWithData(data: MSMessageCellData) {
        super.fillWithData(data: data)
        if let bundlePath = Bundle.main.path(forResource: "TUIKitFace", ofType: "bundle"), let resourceBundle = Bundle(path: bundlePath) {
            let emotionName = MSHelper.emotionName(emotion_id: data.message.emotionElem!.emotionID)
            self.animationView.animation = Animation.named("emotion/\(emotionName)", bundle: resourceBundle, subdirectory: nil, animationCache: LottieCacheProvider.provider)
            self.animationView.loopMode = .loop
            self.animationView.play(completion: nil)
        }
    }
}

class LottieCacheProvider: AnimationCacheProvider {
    
    static let provider = LottieCacheProvider()
    
    private init(){}
    
    var caches: [String: Animation] = [:]
    func animation(forKey: String) -> Animation? {
        return caches[forKey]
    }

    func setAnimation(_ animation: Animation, forKey: String) {
        caches[forKey] = animation
    }

    func clearCache() {
        caches.removeAll()
    }
}

