//
//  BFProfileService.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/7/28.
//

import Foundation
import Moya
import Alamofire
import HandyJSON
import MSIMSDK


public enum ProfileService {
    
    case getIMToken(uid: String)
    case register(phone: String,nickName: String,avatar: String)
    case profileEdit(info: MSProfileInfo)
    case download(url: String,destination: String)
}

extension ProfileService: TargetType {
    public var baseURL: URL {
        switch self {
        case .download(let url,_):
            return URL(string: url)!
        default:
            let serverType = UserDefaults.standard.bool(forKey: "ms_Test")
            let host = serverType ? URL(string: "https://im.ekfree.com:18789")! : URL(string: "https://msim.ekfree.com:18789")!
            return host
        }
    }
    
    public var path: String {
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
    
    public var method: Moya.Method {
        
        switch self {
        case .download:
            return .get
        default:
            return .post
        }
    }
    
    public var sampleData: Data {
        return "{}".data(using: .utf8)!
    }

    public var task: Task {
        
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
        }
    }
    
    public var headers: [String : String]? {
        switch self {
        case .download:
            return nil
        default:
            let secret = "asfasdasd123";
            let radom = String(format: "%u", arc4random_uniform(1000000));
            let time = String(format: "%zd", MSIMTools.sharedInstance().adjustLocalTimeInterval/1000/1000);
            let sign = String(format: "%@%@%@",secret,radom,time).sha1;
            return ["nonce":radom,"timestamp":time,"sig":sign!,"app_id":"2"]
        }
    }
}


//struct Certificates {
//    static let certificate: SecCertificate = Certificates.certificate(filename: "certificateFileName")
//
//    private static func certificate(filename: String) -> SecCertificate {
//        let filePath = Bundle.main.path(forResource: filename, ofType: "cer") ?? ""
//        let data = try! Data(contentsOf: URL(fileURLWithPath: filePath))
//        let certificate = SecCertificateCreateWithData(nil, data as CFData)!
//        return certificate
//  }
//}

let manager = ServerTrustManager(allHostsMustBeEvaluated: false,evaluators: [:])
let session = Session(serverTrustManager: manager)

let provider = MoyaProvider<ProfileService>(session: session,plugins: [NetworkLoggerPlugin(configuration: NetworkLoggerPlugin.Configuration(logOptions: .verbose))])

extension ProfileService {
    
    
    static func iMTokenAPI(uid: String, success:@escaping (_ result: Any?) -> Void, fail:@escaping (_ error: NSError?) -> Void) {
        
        provider.request(ProfileService.getIMToken(uid: uid)) { result in
            
            switch result {
                case let .success(response):
                    let jsonDic = try! response.mapJSON() as! NSDictionary
                    guard let code = jsonDic["code"] as? Int,let msg = jsonDic["msg"] as? String else {
                        fail(nil)
                        return
                    }
                    if code == 0 {
                        success(jsonDic["data"])
                    }else {
                        let err = NSError(domain: msg, code: code, userInfo: nil)
                        fail(err)
                    }
                case let .failure(error):
                    let err = NSError(domain: error.errorDescription ?? "", code: error.errorCode, userInfo: error.errorUserInfo)
                    fail(err)
            }
        }
    }
    
    static func userRegistAPI(phone: String,nickName: String,avatar: String, success:@escaping (_ result: Any?) -> Void, fail:@escaping (_ error: NSError?) -> Void) {
        
        provider.request(ProfileService.register(phone: phone, nickName: nickName, avatar: avatar)) { result in
            switch result {
                case let .success(response):
                    let jsonDic = try! response.mapJSON() as! NSDictionary
                    guard let code = jsonDic["code"] as? Int,let msg = jsonDic["msg"] as? String else {
                        fail(nil)
                        return
                    }
                    if code == 0 {
                        success(jsonDic["data"])
                    }else {
                        let err = NSError(domain: msg, code: code, userInfo: nil)
                        fail(err)
                    }
                case let .failure(error):
                    let err = NSError(domain: error.errorDescription ?? "", code: error.errorCode, userInfo: error.errorUserInfo)
                    fail(err)
            }
        }
    }
    
    static func userEditAPI(info: MSProfileInfo, success:@escaping (_ result: Any?) -> Void, fail:@escaping (_ error: NSError?) -> Void) {
        
        provider.request(ProfileService.profileEdit(info: info)) { result in
            switch result {
                case let .success(response):
                    let jsonDic = try! response.mapJSON() as! NSDictionary
                    guard let code = jsonDic["code"] as? Int,let msg = jsonDic["msg"] as? String else {
                        fail(nil)
                        return
                    }
                    if code == 0 {
                        success(jsonDic["data"])
                    }else {
                        let err = NSError(domain: msg, code: code, userInfo: nil)
                        fail(err)
                    }
                case let .failure(error):
                    let err = NSError(domain: error.errorDescription ?? "", code: error.errorCode, userInfo: error.errorUserInfo)
                    fail(err)
            }
        }
    }
    
    static func download(sourceUrl: String,savePath: String,progress: ProgressBlock?,success:@escaping (_ result: Any?) -> Void, fail:@escaping (_ error: NSError?) -> Void) {
        
        provider.request(ProfileService.download(url: sourceUrl, destination: savePath),progress: progress) { result in
            
            switch result {
            case .success(_):
                    success(nil)
            case let .failure(error):
                    let err = NSError(domain: error.errorDescription ?? "", code: error.errorCode, userInfo: error.errorUserInfo)
                    fail(err)
            }
        }
    }
}
