//
//  MSHelper.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/7/28.
//

import Foundation
import SVProgressHUD

class MSHelper {
    
    public class func showToast() {
        
        SVProgressHUD.show()
    }
    
    public class func showProgress(progress: Float,text: String?) {
        
        SVProgressHUD.showProgress(progress, status: text)
    }
    
    public class func showToastWithText(text: String) {
        
        SVProgressHUD.setMinimumDismissTimeInterval(3)
        SVProgressHUD.showInfo(withStatus: text)
    }
    
    public class func showToastSuccWithText(text: String) {
        
        SVProgressHUD.setMinimumDismissTimeInterval(3)
        SVProgressHUD.showSuccess(withStatus: text)
    }
    
    public class func showToastFailWithText(text: String) {
        
        SVProgressHUD.setMinimumDismissTimeInterval(3)
        SVProgressHUD.showError(withStatus: text)
    }
    
    public class func dismissToast() {
        
        SVProgressHUD.dismiss()
    }
}
