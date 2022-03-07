//
//  MSMenuCollectionViewCell.swift
//  MSIM-Swift
//
//  Created by benny wang on 2022/3/7.
//

import UIKit

class MSMenuCollectionViewCell: UICollectionViewCell {
    
    var menu: UIImageView!
    
    var data: MSMenuCellData? {
        didSet {
            if data?.isSelected == true {
                backgroundColor = UIColor.d_color(light: MSMcros.TMenuCell_Selected_Background_Color, dark: MSMcros.TMenuCell_Selected_Background_Color_Dark)
                menu.image = UIImage(named: data?.selectPath ?? "")
            }else {
                backgroundColor = UIColor.d_color(light: MSMcros.TMenuCell_Background_Color, dark: MSMcros.TMenuCell_Background_Color_Dark)
                menu.image = UIImage(named: data?.normalPath ?? "")
            }
            menu.frame = CGRect(x: MSMcros.TMenuCell_Margin, y: MSMcros.TMenuCell_Margin, width: self.width - 2 * MSMcros.TMenuCell_Margin, height: self.height - 2 * MSMcros.TMenuCell_Margin)
            menu.contentMode = .scaleAspectFit
        }
    }
    
    override init(frame: CGRect) {

        super.init(frame: frame)
        
        backgroundColor = UIColor.d_color(light: MSMcros.TMenuCell_Background_Color, dark: MSMcros.TMenuCell_Background_Color_Dark)
        
        menu = UIImageView()
        menu.backgroundColor = .clear
        addSubview(menu)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MSMenuCellData: NSObject {
    
    var normalPath: String?
    
    var selectPath: String?
    
    var isSelected: Bool = false
}
