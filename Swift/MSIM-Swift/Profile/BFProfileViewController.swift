//
//  BFProfileViewController.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/7/29.
//

import UIKit
import MSIMSDK



class BFProfileViewController: BFBaseViewController {
    
    lazy private var myScrollView: UIScrollView = {
        let myScrollView = UIScrollView()
        myScrollView.showsVerticalScrollIndicator = false
        myScrollView.showsHorizontalScrollIndicator = false
//        myScrollView.delegate = self
        return myScrollView
    }()
    
    lazy private  var avatarIcon: UIImageView = {
       let avatarIcon = UIImageView()
        avatarIcon.contentMode = .scaleAspectFill
        avatarIcon.layer.cornerRadius = 30
        return avatarIcon
    }()
    
    var nickNameL: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

       
    }

    
}


