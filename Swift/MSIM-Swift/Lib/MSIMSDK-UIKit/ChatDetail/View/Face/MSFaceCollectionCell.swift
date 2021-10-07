//
//  MSFaceCollectionCell.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/3.
//

import UIKit

class MSFaceCollectionCell: UICollectionViewCell {
    
    var face: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        face = UIImageView()
        face.contentMode = .scaleAspectFit
        addSubview(face)
        defaultLayout()
    }
    
    private func defaultLayout() {
        face.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
    }
    
    func setData(data: BFFaceCellData?) {
        if data == nil {return}
        face.image = UIImage(named: MSMcros.TUIKitFace(name: data!.name!))
        defaultLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BFFaceCellData: NSObject {
    
    var name: String?
}
