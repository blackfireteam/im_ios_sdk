//
//  MSCallModel.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/9/28.
//

import Foundation
import MSIMSDK

struct MSCallModel {
    
    var callType: MSCallType?    //call 类型
    
    var callID: String?        //call 唯一 ID
    
    var hoster: MSProfileInfo? //邀请者
    
}
