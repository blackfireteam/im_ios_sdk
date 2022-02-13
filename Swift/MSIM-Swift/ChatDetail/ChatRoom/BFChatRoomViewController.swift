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
    
    private var roomInfo: MSGroupInfo? {
        return MSChatRoomManager.sharedInstance().chatroomInfo
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.d_color(light: MSMcros.TController_Background_Color, dark: MSMcros.TController_Background_Color_Dark)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editClick))
        chatController.delegate = self
        chatController.roomInfo = self.roomInfo
        addChild(chatController)
        view.addSubview(chatController.view)
        
        self.title = self.roomInfo?.room_name
        addNotifications()
    }

    private func addNotifications() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init(MSUIKitNotification_EnterChatroom_success), object: nil, queue: OperationQueue.main) {[weak self] note in
            self?.enterChatRoom()
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init(MSUIKitNotification_ChatRoom_Event), object: nil, queue: OperationQueue.main) {[weak self] note in
            self?.chatRoomEvent(note: note)
        }
    }
    
    /// 加入聊天室成功
    private func enterChatRoom() {
        self.chatController.roomInfo = self.roomInfo
        self.title = self.roomInfo?.room_name
    }
    
    /// 聊天室设置界面
    @objc private func editClick() {
        
        if self.roomInfo != nil {
            self.view.endEditing(true)
            let vc = BFChatRoomEditController()
            vc.roomInfo = self.roomInfo
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    /// 接收到聊天室事件通知处理
    @objc func chatRoomEvent(note: Notification) {
        
        //事件类型：
          //1：聊天室已被解散
          //2：聊天室属性已修改
          //3：管理员 %s 将本聊天室设为听众模式
          //4: 管理员 %s 恢复聊天室发言功能
          //5：管理员 %s 上线
          //6：管理员 %s 下线
          //7: 管理员 %s 将用户 %s 禁言
          //8: 管理员 %s 将用户 %s、%s 等人禁言
          //9: %s 成为本聊天室管理员
          //10: 管理员 %s 指派 %s 为临时管理员
          //11：管理员 %s 指派 %s、%s 等人为临时管理员
        guard let event = note.object as? MSGroupEvent,let tips = event.tips,let tipEvent = event.tips?.event else {return}
        
        switch tipEvent {
        case 1:
            MSHelper.showToastWithText(text: "This chatroom is dismissed.")
            navigationController?.popViewController(animated: true)
        case 2:
            chatController.messageController.addSystemTips(text: "Chatroom info has been changed.")
        case 3:
            if let uid = tips.uids.first as? Int,
               let info = MSProfileProvider.shared().providerProfile(fromLocal: String(uid)) {
                chatController.messageController.addSystemTips(text: "\(info.nick_name) disabled sending message for this chatroom.")
            }
        case 4:
            if let uid = tips.uids.first as? Int,
               let info = MSProfileProvider.shared().providerProfile(fromLocal: String(uid)) {
                chatController.messageController.addSystemTips(text: "\(info.nick_name) enabled sending message for this chatroom.")
            }
        case 5:
            if let uid = tips.uids.first as? Int,
               String(uid) != MSIMTools.sharedInstance().user_id,
               let info = MSProfileProvider.shared().providerProfile(fromLocal: String(uid)) {
                chatController.messageController.addSystemTips(text: "Admin: \(info.nick_name) entered this room.")
            }
        case 6:
            if let uid = tips.uids.first as? Int,
               String(uid) != MSIMTools.sharedInstance().user_id,
               let info = MSProfileProvider.shared().providerProfile(fromLocal: String(uid)) {
                chatController.messageController.addSystemTips(text: "Admin: \(info.nick_name) leaved this room.")
            }
        case 7:
            if let uid1 = tips.uids.first as? Int,
               let uid2 = tips.uids.last as? Int,
               let info1 = MSProfileProvider.shared().providerProfile(fromLocal: String(uid1)),
               let info2 = MSProfileProvider.shared().providerProfile(fromLocal: String(uid2)) {
                chatController.messageController.addSystemTips(text: "\(info1.nick_name) muted \(info2.nick_name). Reason: \(event.reason ?? "nothing").")
            }
        case 8:
            if tips.uids.count <= 2 {return}
            var managerName: String = ""
            var membersStr: String = ""
            for (index,uid) in tips.uids.enumerated() {
                if index == 0 {
                    managerName = MSProfileProvider.shared().providerProfile(fromLocal: String(uid as! Int))?.nick_name ?? ""
                }else {
                    let name = MSProfileProvider.shared().providerProfile(fromLocal: String(uid as! Int))?.nick_name ?? ""
                    if membersStr == "" {
                        membersStr = name
                    }else {
                        membersStr = "\(membersStr)、\(name)"
                    }
                }
            }
            chatController.messageController.addSystemTips(text: "\(managerName) muted \(membersStr). Reason: \(event.reason ?? "nothing").")
        case 9:
            if tips.uids.count < 1 {return}
            if let uid = event.tips?.uids.first as? Int,
               let name = MSProfileProvider.shared().providerProfile(fromLocal: String(uid))?.nick_name {
                chatController.messageController.addSystemTips(text: "\(name) becomes the admin of this room.")
            }
        case 10:
            if tips.uids.count < 2 {return}
            if let adminUid = event.tips?.uids.first as? Int,
               let userUid = event.tips?.uids.last as? Int,
               let adminName = MSProfileProvider.shared().providerProfile(fromLocal: String(adminUid))?.nick_name,
               let userName = MSProfileProvider.shared().providerProfile(fromLocal: String(userUid))?.nick_name {
                chatController.messageController.addSystemTips(text: "\(adminName) assigned \(userName) as a temporary admin of the room.")
            }
        case 11:
            if tips.uids.count <= 2 {return}
            var managerName: String = ""
            var membersStr: String = ""
            for (index,uid) in tips.uids.enumerated() {
                if index == 0 {
                    managerName = MSProfileProvider.shared().providerProfile(fromLocal: String(uid as! Int))?.nick_name ?? ""
                }else {
                    let name = MSProfileProvider.shared().providerProfile(fromLocal: String(uid as! Int))?.nick_name ?? ""
                    if membersStr == "" {
                        membersStr = name
                    }else {
                        membersStr = "\(membersStr)、\(name)"
                    }
                }
            }
            chatController.messageController.addSystemTips(text: "\(managerName) assigned \(membersStr) as temporary admins of the room.")
        default:
            break
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension BFChatRoomViewController: MSChatRoomControllerDelegate {
    public func didSendMessage(controller: MSChatRoomController, message: MSIMMessage) {
        
    }
    
    public func prepareForMessage(controller: MSChatRoomController, message: MSIMMessage) -> MSMessageCellData? {
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
        if cell.messageData?.message.type == .MSG_TYPE_IMAGE || cell.messageData?.message.type == .MSG_TYPE_VIDEO {
            //将消息列表中的图片和视频都筛出来
            let tempArr = controller.messageController.uiMsgs.filter { $0.message.type == .MSG_TYPE_IMAGE || $0.message.type == .MSG_TYPE_VIDEO}
            let defaultIndex = tempArr.firstIndex(of: cell.messageData!)
            let lantern = Lantern()
            lantern.pageIndicator = LanternNumberPageIndicator()
            lantern.numberOfItems = {
                tempArr.count
            }
            lantern.cellClassAtIndex = { index in
                let data =  tempArr[index]
                return data.message.type ==  .MSG_TYPE_VIDEO ? VideoZoomCell.self : LanternImageCell.self
            }
            lantern.reloadCellAtIndex = { context in
                let data =  tempArr[context.index]
                if let imageCell = context.cell as? LanternImageCell,let imageElem = data.message.imageElem {
                    
                    if let path = imageElem.path, FileManager.default.fileExists(atPath: path) {
                        imageCell.imageView.kf.setImage(with: URL(fileURLWithPath: path))
                    }else {
                        imageCell.imageView.kf.setImage(with: URL(string: imageElem.url ?? ""))
                    }
                    // 添加长按事件,保存到相册
                    imageCell.longPressedAction = {[weak self] (cell, _) in
                        self?.longPress(elem: imageElem,lantern: cell.lantern)
                    }
                } else if let videoCell = context.cell as? VideoZoomCell,let videoElem = data.message.videoElem {
                    
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
                
                let imagePath = FileManager.pathForIMImage() + NSString.uuid() + ".jpg"
                let imageData = image.pngData()
                try? imageData?.write(to: URL(fileURLWithPath: imagePath))
                let message = MSIMManager.sharedInstance().createImageMessage(imagePath, identifierID: assets[index].localIdentifier)
                self.chatController.sendMessage(message: message)
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
                            let coverPath = FileManager.pathForIMVideo() + NSString.uuid() + ".jpg"
                            let coverData = images[index].pngData()
                            try? coverData?.write(to: URL(fileURLWithPath: coverPath))
                            let message = MSIMManager.sharedInstance().createVideoMessage(localPath, type: "mp4", duration: Int(video.duration), snapshotPath: coverPath, identifierID: nil)
                            self.chatController.sendMessage(message: message)
                            
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
