//
//  MSResponderTextView.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/4.
//

import UIKit

open class MSResponderTextView: UITextView {

    weak var overrideNextResponder: UIResponder?
    
    func nextResponder() -> UIResponder? {
        
        if overrideNextResponder == nil {
            return super.next
        }else {
            return overrideNextResponder
        }
    }

    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if overrideNextResponder != nil {
            return false
        }else {
            return super.canPerformAction(action, withSender: sender)
        }
    }
}
