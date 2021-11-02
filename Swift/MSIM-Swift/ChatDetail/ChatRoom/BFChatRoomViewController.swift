//
//  BFChatRoomViewController.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/11/2.
//

import UIKit
import MSIMSDK
import ZLPhotoBrowser
import Photos
import Kingfisher


public class BFChatRoomViewController: BFBaseViewController {

    public let chatController: MSChatRoomController = MSChatRoomController()
    
    private var roomInfo: MSChatRoomInfo?
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.d_color(light: MSMcros.TController_Background_Color, dark: MSMcros.TController_Background_Color_Dark)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(showChatRoomMembers))
        chatController.delegate = self
        addChild(chatController)
        view.addSubview(chatController.view)
        
        addNotifications()
        enterChatRoom()
    }

    private func addNotifications() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init(MSUIKitNotification_ChatRoom_Event), object: nil, queue: OperationQueue.main) {[weak self] note in
            self?.chatRoomEvent(note: note)
        }
    }
    
    /// 申请加入聊天室
    private func enterChatRoom() {
        MSIMManager.sharedInstance().join(inChatRoom: 2) { info in
            self.roomInfo = info
            self.chatController.room_id = self.roomInfo?.room_id
            self.navigationItem.title = self.roomInfo?.room_name
            
        } failed: { _, desc in
            MSHelper.showToastFailWithText(text: desc ?? "")
        }
    }
    
    /// 展示聊天室成员列表
    @objc private func showChatRoomMembers() {
        
        if self.roomInfo != nil {
            self.view.endEditing(true)
            let vc = BFChatRoomMemberListController()
            vc.roomInfo = self.roomInfo
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    /// 接收到聊天室事件通知处理
    @objc func chatRoomEvent(note: Notification) {
        
        //事件 0：聊天室被销毁（所有用户被迫离开聊天室）1：聊天室信息修改，
        //2：用户上线， 3：用户下线(自己被踢掉也会收到)
        //4：全体禁言 5：解除全体禁言
        if let event = note.object as? MSChatRoomEvent {
            if event.eventType == 0 {
                MSHelper.showToastWithText(text: "Chat room is dissolved.")
                navigationController?.popViewController(animated: true)
            }else if event.eventType == 1 {
                
            }else if event.eventType == 2 {
                
            }else if event.eventType == 3 {
                
                if event.uid == MSIMTools.sharedInstance().user_id {//自己被踢出了聊天室
                    MSHelper.showToastWithText(text: "You has been kicked out.")
                    navigationController?.popViewController(animated: true)
                }
            }else if event.eventType == 4 {
                
            }else if event.eventType == 5 {
                
            }
        }
    }
    
    deinit {
        if let room_idStr = self.roomInfo?.room_id,let room_id = Int(room_idStr) {
            MSIMManager.sharedInstance().quitChatRoom(room_id) {
                
                MSHelper.showToastSuccWithText(text: "quit chat room")
            } failed: { _, desc in
                MSHelper.showToastFailWithText(text: desc ?? "")
            }
        }
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension BFChatRoomViewController: MSChatRoomControllerDelegate {
    public func didSendMessage(controller: MSChatRoomController, elem: MSIMElem) {
        
    }
    
    public func prepareForMessage(controller: MSChatRoomController, elem: MSIMElem) -> MSMessageCellData? {
        return nil
    }
    
    public func onShowMessageData(controller: MSChatRoomController, cellData: MSMessageCellData) -> MSMessageCell.Type? {
        return nil
    }
    
    public func onSelectMoreCell(controller: MSChatRoomController, cell: MSInputMoreCell) {
        if cell.data?.type == MSIMMoreType.photo {
            selectAsset(isPhoto: true)
            
        }else if cell.data?.type == MSIMMoreType.video {
            selectAsset(isPhoto: false)
        }
    }
    
    public func onSelectMessageAvatar(controller: MSChatRoomController, cell: MSMessageCell) {
        
    }
    
    public func onSelectMessageContent(controller: MSChatRoomController, cell: MSMessageCell) {
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
        }
    }
}

extension BFChatRoomViewController {
    
    private func selectAsset(isPhoto: Bool) {
        let config = ZLPhotoConfiguration.default()
        config.allowSelectVideo = !isPhoto
        config.allowSelectImage = isPhoto
        config.maxSelectCount = 1
        config.allowEditImage = isPhoto
        config.allowEditVideo = !isPhoto
        config.imageStickerContainerView = ImageStickerContainerView()
        
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
}
