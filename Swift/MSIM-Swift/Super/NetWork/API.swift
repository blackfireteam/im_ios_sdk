//
//  API.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/12/21.
//

import Foundation
import Moya
import Alamofire
import MSIMSDK

enum API {
    case test
    case getIMToken(uid: String)
    case register(phone: String,nickName: String,avatar: String)
    case profileEdit(info: MSProfileInfo)
    case download(url: String,destination: String)
}

extension API: TargetType {
    var baseURL: URL {
        switch self {
        case .download(let url, _):
            return URL(string: url)!
        default:
            let serverType = UserDefaults.standard.bool(forKey: "ms_Test")
            let serverUrl = serverType ? "https://im.ekfree.com:18789" : "https://msim1.ekfree.com:18789"
            return URL(string: serverUrl)!
        }
    }
    
    var path: String {
        switch self {
        case .getIMToken:
            return "/user/iminit"
        case .register:
            return "/user/reg"
        case .profileEdit:
            return "/user/update"
        default:
            return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .download:
            return .get
        default:
            return .post
        }
    }
    
    var task: Task {
        var params: [String: Any] = [:]
        switch self {
        case .getIMToken(let uid):
            params = ["uid": uid,"ctype": 0] as [String: Any]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .register(let phone, let nickName, let avatar):
            params = ["uid": phone,"nick_name": nickName,"avatar": avatar,"gender": 1] as [String: Any]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .profileEdit(let info):
            params = ["uid": info.user_id,"nick_name": info.nick_name,"avatar": info.avatar,"gender": info.gender] as [String: Any]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .download(_,let savePath):
            let destination: DownloadRequest.Destination = {_,_ in
                return (URL(fileURLWithPath: savePath),[.removePreviousFile,.createIntermediateDirectories])
            }
            return .downloadDestination(destination)
        default:
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .download:
            return nil
        default:
            let secret = "asfasdasd123";
            let radom = String(format: "%u", arc4random_uniform(1000000));
            let time = String(format: "%zd", MSIMTools.sharedInstance().adjustLocalTimeInterval/1000/1000);
            let sign = String(format: "%@%@%@",secret,radom,time).sha1;
            return ["nonce":radom,"timestamp":time,"sig":sign!,"appid":MSMcros.kAppID]
        }
    }
    
    var sampleData: Data {
        return "".data(using: .utf8)!
    }
    
}
