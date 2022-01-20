//
//  BFChatViewController.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/9/1.
//

import UIKit
import MSIMSDK
import ZLPhotoBrowser
import Photos
import Kingfisher


public class BFChatViewController: BFBaseViewController {

    public var partner_id: String!
    
    public let chatController: MSChatViewController = MSChatViewController()
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.d_color(light: MSMcros.TController_Background_Color, dark: MSMcros.TController_Background_Color_Dark)
        
        chatController.delegate = self
        chatController.partner_id = self.partner_id
        addChild(chatController)
        view.addSubview(chatController.view)
        
        MSProfileProvider.shared().providerProfile(self.partner_id) { profile in
            self.navigationItem.title = profile?.nick_name
        }
        if let conv = MSConversationProvider.shared().providerConversation(self.partner_id),conv.ext.i_block_u > 0 {
            MSHelper.showToastWithText(text: "对方被我Block")
        }
    }
}

// MARK: - MSChatViewControllerDelegate
extension BFChatViewController: MSChatViewControllerDelegate {
    public func didSendMessage(controller: MSChatViewController, elem: MSIMElem) {
        //主动发送的每一条消息都会进入这个回调，你可以在此做一些统计埋点等工作。。。
    }
    
    //将要展示在列表中的每和条消息都会先进入这个回调，你可以在此针对自定义消息构建数据模型
    public func prepareForMessage(controller: MSChatViewController, elem: MSIMElem) -> MSMessageCellData? {
        
        if let customElem = elem as? MSIMCustomElem {
            guard let dic = (customElem.jsonStr as NSString).el_convertToDictionary() as? [String: Any] else {return nil}
            if customElem.type == .MSG_TYPE_CUSTOM_UNREADCOUNT_RECAL {
                if let type = dic["type"] as? Int,type == MSIMCustomSubType.Like.rawValue {
                    let winkData = BFWinkMessageCellData(direction: elem.isSelf ? .outGoing : .inComing)
                    winkData.showName = true
                    winkData.elem = customElem
                    return winkData
                }
            }else if customElem.type == .MSG_TYPE_CUSTOM_UNREADCOUNT_NO_RECALL {
                if let type = dic["type"] as? Int,let subType = MSIMCustomSubType(rawValue: type) {
                    if subType == .VoiceCall || subType == .VideoCall {
                        let callData = BFCallMessageCellData(direction: elem.isSelf ? .outGoing : .inComing)
                        callData.callType = (subType == .VideoCall ? .video : .voice)
                        callData.notice = MSCallManager.parseToMessageShow(customParams: dic, callType: (subType == .VoiceCall ? .voice : .video), isSelf: customElem.isSelf) ?? ""
                        callData.showName = true
                        callData.elem = customElem
                        return callData
                    }
                }
            }
        }
        return nil
    }
    
    public func onShowMessageData(controller: MSChatViewController, cellData: MSMessageCellData) -> MSMessageCell.Type? {
        
        if cellData is BFWinkMessageCellData {
            return BFWinkMessageCell.self
        }else if cellData is BFCallMessageCellData {
            return BFCallMessageCell.self
        }
        return nil
    }
    
    public func onSelectMoreCell(controller: MSChatViewController, cell: MSInputMoreCell) {
        if cell.data?.type == MSIMMoreType.photo {
            selectAsset(isPhoto: true)
            
        }else if cell.data?.type == MSIMMoreType.video {
            selectAsset(isPhoto: false)
        }else if cell.data?.type == .voiceCall {//语音通话
            MSCallManager.shared.callToPartner(partner_id: self.partner_id, creator: MSIMTools.sharedInstance().user_id!, callType: .voice, action: .call, room_id: nil)
        }else if cell.data?.type == .videoCall {//视频通话
            MSCallManager.shared.callToPartner(partner_id: self.partner_id, creator: MSIMTools.sharedInstance().user_id!, callType: .video, action: .call, room_id: nil)
        }else if cell.data?.type == .location {//地理位置
            let vc = MSLocationController()
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
            vc.didSendLocation = {[weak self] info in
                self?.sendLocationMessage(info: info)
            }
        }
    }
    
    public func onSelectMessageAvatar(controller: MSChatViewController, cell: MSMessageCell) {
        
        print("点击头像...")
    }
    
    public func onSelectMessageContent(controller: MSChatViewController, cell: MSMessageCell) {
        
        if cell.messageData?.elem?.type == .MSG_TYPE_IMAGE || cell.messageData?.elem?.type == .MSG_TYPE_VIDEO {
            //将消息列表中的图片和视频都筛出来
            let tempArr = controller.messageController.uiMsgs.filter { $0.elem?.type == .MSG_TYPE_IMAGE || $0.elem?.type == .MSG_TYPE_VIDEO}
            let defaultIndex = tempArr.firstIndex(of: cell.messageData!)
            let lantern = Lantern()
            lantern.pageIndicator = LanternNumberPageIndicator()
            lantern.numberOfItems = {
                tempArr.count
            }
            lantern.cellClassAtIndex = { index in
                let data =  tempArr[index]
                return data.elem?.type ==  .MSG_TYPE_VIDEO ? VideoZoomCell.self : LanternImageCell.self
            }
            lantern.reloadCellAtIndex = { context in
                let data =  tempArr[context.index]
                if let imageCell = context.cell as? LanternImageCell,let imageElem = data.elem as? MSIMImageElem {
                    
                    if let path = imageElem.path, FileManager.default.fileExists(atPath: path) {
                        imageCell.imageView.kf.setImage(with: URL(fileURLWithPath: path))
                    }else {
                        imageCell.imageView.kf.setImage(with: URL(string: imageElem.url ?? ""))
                    }
                    // 添加长按事件,保存到相册
                    imageCell.longPressedAction = {[weak self] (cell, _) in
                        self?.longPress(elem: imageElem,lantern: cell.lantern)
                    }
                } else if let videoCell = context.cell as? VideoZoomCell,let videoElem = data.elem as? MSIMVideoElem {
                    
                    if videoElem.coverImage != nil {
                        videoCell.imageView.image = videoElem.coverImage
                    }else if let coverPath = videoElem.coverPath, FileManager.default.fileExists(atPath: coverPath) {
                        videoCell.imageView.kf.setImage(with: URL(fileURLWithPath: coverPath))
                    }else {
                        videoCell.imageView.kf.setImage(with: URL(string: videoElem.coverUrl ?? "")!)
                    }
                    if let videoPath = videoElem.videoPath, FileManager.default.fileExists(atPath: videoPath) {
                        videoCell.player.replaceCurrentItem(with: AVPlayerItem(url: URL(fileURLWithPath: videoPath)))
                    }else {
                        videoCell.player.replaceCurrentItem(with: AVPlayerItem(url: URL(string: videoElem.videoUrl ?? "")!))
                    }
                    // 添加长按事件,保存到相册
                    videoCell.longPressedAction = {[weak self] (cell, _) in
                        self?.longPress(elem: videoElem,lantern: cell.lantern)
                    }
                }
            }
            
            lantern.cellWillAppear = { cell, index in
                if let videoCell = cell as? VideoZoomCell {
                    videoCell.player.play()
                }
            }
            lantern.cellWillDisappear = { cell, index in
                if let videoCell = cell as? VideoZoomCell {
                    videoCell.player.pause()
                }
            }
            lantern.transitionAnimator = LanternZoomAnimator(previousView: {[weak self] index -> UIView? in
                
                let data = tempArr[index]
                if let atIndex = self?.chatController.messageController.uiMsgs.firstIndex(of: data) {
                    let indexPath = IndexPath(row: atIndex, section: 0)
                    let cell = controller.messageController.tableView.cellForRow(at: indexPath) as? MSMessageCell
                    return cell?.container.subviews.first
                }
                return nil
            })
            lantern.pageIndex = defaultIndex ?? 0
            lantern.show()
        }else if cell is BFCallMessageCell {
            guard let customElem = cell.messageData?.elem as? MSIMCustomElem, let dic = (customElem.jsonStr as NSString).el_convertToDictionary() as? [String: Any] else { return }
            if let typeInt = dic["type"] as? Int,let type = MSIMCustomSubType(rawValue: typeInt) {
                MSCallManager.shared.callToPartner(partner_id: self.partner_id, creator: MSIMTools.sharedInstance().user_id!, callType: (type == .VideoCall ? .video : .voice), action: .call, room_id: nil)
            }
        }else if cell.messageData?.elem?.type == .MSG_TYPE_LOCATION {
            
            if let locationData = cell.messageData as? MSLocationMessageCellData {
                let locationInfo = MSLocationInfo(locationMsg: locationData.locationElem)
                let n_coor = MSLocationManager.shared.gPSCoordinateConvertToAMap(coordinate: CLLocationCoordinate2D(latitude: locationInfo.latitude, longitude: locationInfo.longitude))
                locationInfo.latitude = n_coor.latitude
                locationInfo.longitude = n_coor.longitude
                let vc = MSLocationDetailController(location: locationInfo)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    public func onRecieveTextingMessage(controller: MSChatViewController, elem: MSIMElem) {
        
        self.navigationItem.title = Bundle.bf_localizedString(key: "TUIkitMessageTipsTextingMessage")
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            MSProfileProvider.shared().providerProfile(self.partner_id) { profile in
                self.navigationItem.title = profile?.nick_name
            }
        }
    }
}

extension BFChatViewController {
    
    private func selectAsset(isPhoto: Bool) {
        let config = ZLPhotoConfiguration.default()
        config.allowSelectVideo = !isPhoto
        config.allowSelectImage = isPhoto
        config.maxSelectCount = 1
        config.allowEditImage = isPhoto
        config.allowEditVideo = !isPhoto
        let editConfig = ZLEditImageConfiguration()
        editConfig.imageStickerContainerView = ImageStickerContainerView()
        config.editImageConfiguration = editConfig
        config.canSelectAsset = { (asset) -> Bool in
            return true
        }
        
        config.noAuthorityCallback = { (type) in
            switch type {
            case .library:
                debugPrint("No library authority")
            case .camera:
                debugPrint("No camera authority")
            case .microphone:
                debugPrint("No microphone authority")
            }
        }
        
        let picker = ZLPhotoPreviewSheet(selectedAssets: nil)
        picker.selectImageBlock = {[weak self] (images,assets,isOriginal) in
            self?.didPickerAsset(images: images,assets: assets,isPhoto: isPhoto)
        }
        picker.cancelBlock = {
            
        }
        picker.selectImageRequestErrorBlock = { (errorAssets, errorIndexs) in
            debugPrint("fetch error assets: \(errorAssets), error indexs: \(errorIndexs)")
        }
        picker.showPhotoLibrary(sender: self)
    }
    
    private func didPickerAsset(images: [UIImage],assets: [PHAsset],isPhoto: Bool) {
        if isPhoto {
            for (index,image) in images.enumerated() {
                var imageElem = MSIMImageElem()
                imageElem.type = .MSG_TYPE_IMAGE
                imageElem.image = image
                imageElem.width = Int(image.size.width)
                imageElem.height = Int(image.size.height)
                imageElem.uuid = assets[index].localIdentifier
                imageElem = MSIMManager.sharedInstance().createImageMessage(imageElem)
                self.chatController.sendMessage(message: imageElem)
            }
        }else {
            MSHelper.showToast()
            var count: Int = 0
            for (index,video) in assets.enumerated() {
                
                _ = ZLPhotoManager.fetchAVAsset(forVideo: video) { avasset, info in
                    
                    let localPath = FileManager.pathForIMVideo() + "\(NSString.uuid()).mp4"
                    let exportSession = AVAssetExportSession(asset: avasset!, presetName: AVAssetExportPresetPassthrough)
                    exportSession?.outputURL = URL(fileURLWithPath: localPath)
                    exportSession?.outputFileType = .mp4
                    exportSession?.exportAsynchronously {
                        switch exportSession?.status {
                        case .completed:
                            count += 1
                            var videoElem = MSIMVideoElem()
                            videoElem.type = .MSG_TYPE_VIDEO
                            videoElem.coverImage = images[index]
                            videoElem.width = video.pixelWidth
                            videoElem.height = video.pixelHeight
                            videoElem.videoPath = localPath
                            videoElem.duration = Int(video.duration)
                            videoElem = MSIMManager.sharedInstance().createVideoMessage(videoElem)
                            self.chatController.sendMessage(message: videoElem)
                            
                        case .failed, .cancelled:
                            count += 1
                        default:
                            print(exportSession?.error ?? "")
                        }
                        if count == assets.count {
                            MSHelper.dismissToast()
                        }
                    }
                }
            }
        }
    }
    
    /// 长按图片或视频，保存到相册
    private func longPress(elem: MSIMElem,lantern: Lantern?) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Save to album", style: .default, handler: {[weak self] _ in
            if let imageElem = elem as? MSIMImageElem {
                self?.savePhotoToAlbum(elem: imageElem)
            }else if let videoElem = elem as? MSIMVideoElem {
                self?.saveVideoToAlbum(elem: videoElem)
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        lantern?.present(alert, animated: true, completion: nil)
    }
    
    private func savePhotoToAlbum(elem: MSIMImageElem) {
        var saveImage: UIImage?
        if let image = elem.image {
            saveImage = image
        }else if let path = elem.path,FileManager.default.fileExists(atPath: path) {
            saveImage = UIImage.init(contentsOfFile: path)
        }else if let url = elem.url,let data = try? Data.init(contentsOf: URL(string: url)!) {
            saveImage = UIImage.init(data: data)
        }
        if saveImage != nil {
            ZLPhotoManager.saveImageToAlbum(image: saveImage!) { isOK, _ in
                if isOK {
                    MSHelper.showToastSuccWithText(text: "Done")
                }else {
                    MSHelper.showToastFailWithText(text: "Error")
                }
            }
        }
    }
    
    private func saveVideoToAlbum(elem: MSIMVideoElem) {
        
        //1.如果视频本地文件存在，直接保存到相册
        if let path = elem.videoPath,FileManager.default.fileExists(atPath: path) {
            ZLPhotoManager.saveVideoToAlbum(url: URL(fileURLWithPath: path)) { isOK, _ in
                if isOK {
                    MSHelper.showToastSuccWithText(text: "Done")
                }else {
                    MSHelper.showToastFailWithText(text: "Error")
                }
            }
        }else if let url = elem.videoUrl {
            //2.如果视频本地文件不存在，需要先下载，再保存到相册
            MSHelper.showToast()
            let tempUrl = "\(FileManager.pathForIMVideo())" + NSString.uuid() + ".mp4"
            MSIMManager.sharedInstance().uploadMediator?.ms_download?(fromUrl: url, toSavePath: tempUrl, progress: { progress in
                MSHelper.showProgress(progress: Float(progress), text: "Video is downloading...")
            }, succ: { _ in
                
                ZLPhotoManager.saveVideoToAlbum(url: URL(fileURLWithPath: tempUrl)) { isOK, _ in
                    if isOK {
                        MSHelper.showToastSuccWithText(text: "Done")
                    }else {
                        MSHelper.showToastFailWithText(text: "Error")
                    }
                    try? FileManager.default.removeItem(atPath: tempUrl)
                }
                
            }, fail: { code, errorString in
                
                MSHelper.showToastFailWithText(text: errorString)
            })
        }
    }
    
    private func sendLocationMessage(info: MSLocationInfo) {
        // 为了兼容，先将高德地图坐标转换成gps坐标
        let n_coor = MSLocationManager.shared.AMapCoordinateConvertToGPS(coordinate: CLLocationCoordinate2D(latitude: info.latitude, longitude: info.longitude))
        var elem = MSIMLocationElem()
        elem.title = info.name
        elem.detail = info.detail
        elem.longitude = n_coor.longitude
        elem.latitude = n_coor.latitude
        elem.zoom = info.zoom
        elem = MSIMManager.sharedInstance().createLocationMessage(elem)
        MSIMManager.sharedInstance().sendC2CMessage(elem, toReciever: self.partner_id) { _ in
            
        } failed: { _, _ in
            
        }
    }
}
