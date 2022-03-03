//
//  MSInputMoreCell.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/3.
//

import UIKit

open class MSInputMoreCell: UICollectionViewCell {
    
    var image: UIImageView!
    
    var title: UILabel!
    
    var data: MSInputMoreCellData?
    
    func fillWithData(data: MSInputMoreCellData?) {
        self.data = data
        image.image = data?.image
        title.text = data?.title
        
        let menuSize = CGSize(width: 50, height: 50)
        image.frame = CGRect(x: 7.5, y: 7.5, width: menuSize.width, height: menuSize.height)
        title.frame = CGRect(x: 0, y: image.top + image.height + 10, width: image.width + 15, height: 20)
    }
    
    static func getSize() -> CGSize {
        let menuSize = CGSize(width: 50, height: 50)
        return CGSize(width: menuSize.width, height: menuSize.height + 40)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        image = UIImageView()
        image.contentMode = .scaleAspectFit
        addSubview(image)
        
        title = UILabel()
        title.font = .systemFont(ofSize: 14)
        title.textColor = .gray
        title.textAlignment = .center
        addSubview(title)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public enum MSIMMoreType {
    case photo
    case video
    case location
    case voiceCall
    case videoCall
}
public struct MSInputMoreCellData {
    
    var type: MSIMMoreType
    
    var image: UIImage?
    
    var title: String?
    
    init(type: MSIMMoreType) {
        self.type = type
    }
}
