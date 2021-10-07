//
//  UIImage+Ezt.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/7/28.
//

import UIKit

public extension UIImage {
    
    class func bf_imageNamed(name: String) -> UIImage? {
        
        let path = Bundle.bf_resourceBundle.bundlePath
        return UIImage(named: "\(path)/\(name)")
    }
    
    class func bf_emoji(name: String) -> UIImage? {
        
        let path = Bundle.bf_emojiBundle.bundlePath
        return UIImage(named: "\(path)/\(name)")
    }
    
    class func bf_image(light: String, dark: String) -> UIImage? {
        
        if UITraitCollection.current.userInterfaceStyle == .light {
            return UIImage.bf_imageNamed(name: light)
        }else {
            return UIImage.bf_imageNamed(name: dark)
        }
    }
}
