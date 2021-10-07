//
//  MSRecordView.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/4.
//

import UIKit

public enum RecordStatus {
    case tooShort,tooLong,recording,cancel
}
open class MSRecordView: UIView {

    public var recordImage: UIImageView!
    
    public var title: UILabel!
    
    public var backgroud: UIView!
    
    public func setPower(power: Int) {
        let imageName = getRecordImage(power: power)
        recordImage.image = UIImage.bf_imageNamed(name: imageName)
    }
    
    public func setStatus(status: RecordStatus) {
        switch status {
        case .recording:
            title.text = Bundle.bf_localizedString(key: "TUIKitInputRecordSlideToCancel")
            title.backgroundColor = .clear
        case .cancel:
            title.text = Bundle.bf_localizedString(key: "TUIKitInputRecordReleaseToCancel")
            title.backgroundColor = MSMcros.Record_Title_Background_Color
        case .tooShort:
            title.text = Bundle.bf_localizedString(key: "TUIKitInputRecordTimeshort")
            title.backgroundColor = .clear
        case .tooLong:
            title.text = Bundle.bf_localizedString(key: "TUIKitInputRecordTimeLong")
            title.backgroundColor = .clear
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        defaultLayout()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

private extension MSRecordView {
    
    func setupViews() {
        backgroundColor = .clear
        backgroud = UIView()
        backgroud.backgroundColor = MSMcros.Record_Background_Color
        backgroud.layer.cornerRadius = 5
        backgroud.layer.masksToBounds = true
        addSubview(backgroud)
        
        recordImage = UIImageView()
        recordImage.image = UIImage.bf_imageNamed(name: "record_1")
        recordImage.alpha = 0.8
        recordImage.contentMode = .center
        backgroud.addSubview(recordImage)
        
        title = UILabel()
        title.font = .systemFont(ofSize: 14)
        title.textColor = .white
        title.textAlignment = .center
        title.layer.cornerRadius = 5
        title.layer.masksToBounds = true
        backgroud.addSubview(title)
    }
    
    func defaultLayout() {
        var backSize = MSMcros.Record_Background_Size
        title.text = Bundle.bf_localizedString(key: "TUIKitInputRecordSlideToCancel")
        let titleSize = title.sizeThatFits(CGSize(width: UIScreen.width, height: UIScreen.height))
        if titleSize.width > backSize.width {
            backSize.width = titleSize.width + 2 * MSMcros.Record_Margin
        }
        backgroud.frame = CGRect(x: (UIScreen.width - backSize.width) * 0.5, y: (UIScreen.height - backSize.height) * 0.5, width: backSize.width, height: backSize.height)
        let imageHeight = backSize.height - titleSize.height - 2 * MSMcros.Record_Margin
        recordImage.frame = CGRect(x: 0, y: 0, width: backSize.width, height: imageHeight)
        let titley = recordImage.top + imageHeight
        title.frame = CGRect(x: 0, y: titley, width: backSize.width, height: backSize.height - titley)
    }
    
    func getRecordImage(power: Int) -> String {
        let power = power + 60
        var index = 0
        if power < 25 {
            index = 1
        }else {
            index = Int(ceilf(Float(power - 25) / 5.0)) + 1
        }
        return String(format: "record_%d", index)
    }
}
