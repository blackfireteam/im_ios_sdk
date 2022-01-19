//
//  MSUploadManager.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/2.
//

import UIKit
import MSIMSDK
import QCloudCOSXML


open class MSUploadManager:NSObject, MSUploadMediator {
    
    public static let shared: MSUploadManager = MSUploadManager()
    
    private var credentialFenceQueue = QCloudCredentailFenceQueue()
    
    private var cosInfo: MSCOSInfo?
    
    private override init() {}
    
    private func cosServiceConfig() {
        
        let configuration = QCloudServiceConfiguration()
        let endpoint = QCloudCOSXMLEndPoint()
        endpoint.regionName = self.cosInfo!.region
        endpoint.useHTTPS = true
        configuration.endpoint = endpoint
        configuration.signatureProvider = self
        QCloudCOSXMLService.registerDefaultCOSXML(with: configuration)
        QCloudCOSTransferMangerService.registerDefaultCOSTransferManger(with: configuration)
        self.credentialFenceQueue.delegate = self
    }
    
    
    public func ms_upload(with object: Any, fileType type: MSUploadFileType, progress: @escaping normalProgress, succ: @escaping normalSucc, fail: @escaping normalFail) {
        
        if self.cosInfo == nil {
            MSIMManager.sharedInstance().getCOSToken { cosInfo in
                self.cosInfo = cosInfo
                self.cosServiceConfig()
                self.ms_cosUpload(with: object, fileType: type, progress: progress, succ: succ, fail: fail)
            } failed: { code, desc in
                print("请求cos临时密钥错误。。\(code)--\(desc ?? "")")
                fail(code,desc ?? "")
            }
            return
        }
        self.ms_cosUpload(with: object, fileType: type, progress: progress, succ: succ, fail: fail)
    }
    
    private func ms_cosUpload(with object: Any, fileType type: MSUploadFileType, progress: @escaping normalProgress, succ: @escaping normalSucc, fail: @escaping normalFail) {
        
        let put = QCloudCOSXMLUploadObjectRequest<AnyObject>()
        if type == .image || type == .avatar {
            if let image = object as? UIImage {
                put.body = image.jpegData(compressionQuality: 0.75) as AnyObject
            }else if let path = object as? String {
                put.body = URL(fileURLWithPath: path) as AnyObject
            }
            if type == .avatar {
                put.object = String(format: "%@%@.jpg",self.cosInfo!.other_path!, NSString.uuid())
            }else {
                put.object = String(format: "%@im_image/%@.jpg",self.cosInfo!.im_path!, NSString.uuid())
            }
        }else if type == .video {
            put.body = URL(fileURLWithPath: object as! String) as AnyObject
            put.object = String(format: "%@im_video/%@.mp4",self.cosInfo!.im_path!, NSString.uuid())
        }else if type == .voice {
            let path = object as! NSString
            put.body = URL(fileURLWithPath: object as! String) as AnyObject
            put.object = String(format: "%@im_voice/%@",self.cosInfo!.im_path!, path.lastPathComponent)
        }
        put.bucket = self.cosInfo!.bucket
        //监听上传进度
        put.sendProcessBlock = { (bytesSent, totalBytesSent,totalBytesExpectedToSend) in
            DispatchQueue.main.async {
                progress(CGFloat(totalBytesSent) / CGFloat(totalBytesExpectedToSend))
            }
        }
        put.setFinish { result, error in
            DispatchQueue.main.async {
                if error == nil {
                    succ(result!.location)
                }else {
                    fail((error! as NSError).code,error!.localizedDescription)
                }
            }
        }
        QCloudCOSTransferMangerService.defaultCOSTransferManager().uploadObject(put)
    }
    
    public func ms_download(fromUrl url: String, toSavePath savePath: String, progress: @escaping normalProgress, succ: @escaping normalSucc, fail: @escaping normalFail) {
        
        if self.cosInfo == nil {
            MSIMManager.sharedInstance().getCOSToken { cosInfo in
                self.cosInfo = cosInfo
                self.cosServiceConfig()
                self.ms_cosDownload(fromUrl: url, toSavePath: savePath, progress: progress, succ: succ, fail: fail)
            } failed: { code, desc in
                print("请求cos临时密钥错误。。\(code)--\(desc ?? "")")
                fail(code,desc ?? "")
            }
            return
        }
        self.ms_cosDownload(fromUrl: url, toSavePath: savePath, progress: progress, succ: succ, fail: fail)
    }
    
    private func ms_cosDownload(fromUrl url: String, toSavePath savePath: String, progress: @escaping normalProgress, succ: @escaping normalSucc, fail: @escaping normalFail) {
        
        NetWorkManager.netWorkRequest(.download(url: url, destination: savePath)) { result in
            succ(savePath)
        } fail: { error in
            try? FileManager.default.removeItem(atPath: savePath)
            fail(error?.code ?? 0,error?.localizedDescription ?? "")
        }
    }
}

extension MSUploadManager: QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate {
    public func signature(with fileds: QCloudSignatureFields!, request: QCloudBizHTTPRequest!, urlRequest urlRequst: NSMutableURLRequest!, compelete continueBlock: QCloudHTTPAuthentationContinueBlock!) {
        
        self.credentialFenceQueue.performAction { creator, error in
            if error != nil {
                continueBlock(nil,error)
            }else {
                let signature = creator?.signature(forData: urlRequst)
                continueBlock(signature,nil)
            }
        }
    }
    
    public func fenceQueue(_ queue: QCloudCredentailFenceQueue!, requestCreatorWithContinue continueBlock: QCloudCredentailFenceQueueContinue!) {
        //这里同步从◊后台服务器获取临时密钥，强烈建议将获取临时密钥的逻辑放在这里，最大程度上保证密钥的可用性
        MSIMManager.sharedInstance().getCOSToken { cosInfo in
            self.cosInfo = cosInfo
            let credential = QCloudCredential()
            credential.secretID = cosInfo.secretID
            credential.secretKey = cosInfo.secretKey
            credential.token = cosInfo.token
            credential.startDate = Date(timeIntervalSince1970: TimeInterval(cosInfo.start_time))
            credential.expirationDate = Date(timeIntervalSince1970: TimeInterval(cosInfo.exp_time))
            let creator = QCloudAuthentationV5Creator(credential: credential)
            continueBlock(creator,nil)
            
        } failed: { code, desc in
            print("请求cos临时密钥错误。。\(code)--\(desc ?? "")")
            continueBlock(nil,NSError(domain: desc ?? "", code: code, userInfo: nil))
        }
    }
    
}
