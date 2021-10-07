//
//  BFSignInStepTwoController.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/7/28.
//

import UIKit
import Photos
import ZLPhotoBrowser
import MSIMSDK


class BFSignInStepTwoController: BFBaseViewController {
    
    var info: BFRegisterInfo!
    
    private var avatarIcon: UIImageView!
    
    private var nextBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let titleL = UILabel(frame: CGRect(x: 35, y: UIScreen.status_navi_height + 35, width: UIScreen.width - 70, height: 30))
        titleL.text = "MY PROFILE IS"
        titleL.font = .boldSystemFont(ofSize: 21)
        titleL.textColor = UIColor.d_color(light: .black, dark: .white)
        view.addSubview(titleL)
        
        avatarIcon = UIImageView(frame: CGRect(x: UIScreen.width * 0.5 - 112, y: titleL.bottom + 40, width: 224, height: 218))
        avatarIcon.contentMode = .scaleAspectFill
        avatarIcon.layer.cornerRadius = 8
        avatarIcon.layer.masksToBounds = true
        avatarIcon.isUserInteractionEnabled = true
        avatarIcon.image = info.avatarImage ?? UIImage(named: "register_add")
        let tap = UITapGestureRecognizer(target: self, action: #selector(avatarDidTap))
        avatarIcon.addGestureRecognizer(tap)
        view.addSubview(avatarIcon)
        
        nextBtn = UIButton(type: .custom)
        nextBtn.setTitle(Bundle.bf_localizedString(key: "Next-button"), for: .normal)
        nextBtn.setTitleColor(.white, for: .normal)
        nextBtn.titleLabel?.font = .systemFont(ofSize: 16)
        nextBtn.backgroundColor = UIColor(r: 45, g: 45, b: 45)
        nextBtn.layer.cornerRadius = 2
        nextBtn.layer.masksToBounds = true
        nextBtn.addTarget(self, action: #selector(nextBtnDidClick), for: .touchUpInside)
        nextBtn.frame = CGRect(x: 35, y: avatarIcon.bottom + 60, width: UIScreen.width - 70, height: 50)
        view.addSubview(nextBtn)
        
    }
    

    @objc func avatarDidTap() {
        
        let config = ZLPhotoConfiguration.default()
        config.allowSelectVideo = false
        config.allowSelectImage = true
        config.maxSelectCount = 1
        config.allowEditImage = true
        config.allowEditVideo = false
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
            self?.didPickerAsset(image: images.first!,asset: assets.first!)
        }
        picker.cancelBlock = {
            
        }
        picker.selectImageRequestErrorBlock = { (errorAssets, errorIndexs) in
            debugPrint("fetch error assets: \(errorAssets), error indexs: \(errorIndexs)")
        }
        picker.showPhotoLibrary(sender: self)
    }
    
    @objc func nextBtnDidClick() {
        
        if info.avatarImage == nil {
            MSHelper.showToastWithText(text: "请上传头像")
            return
        }
        MSHelper.showToast()
        let elem = MSIMImageElem()
        elem.image = info.avatarImage!
        MSIMManager.sharedInstance().uploadMediator?.ms_upload?(with: elem.image!, fileType: .avatar, progress: { progress in
            
        }, succ: { url in
            
            self.info.avatarUrl = url
            self.requestToSignUp()
            
        }, fail: { code, desc in
            
            MSHelper.showToastFailWithText(text: desc)
        })
    }
    
    private func requestToSignUp() {
        ProfileService.userRegistAPI(phone: info.phone!, nickName: info.nickName!, avatar: info.avatarUrl!) { _ in
            
            ProfileService.iMTokenAPI(uid: self.info.phone!) { result in
                
                let dic = result as! [String: Any]
                let userToken = dic["token"] as! String
                let im_Url = dic["url"] as! String
                self.info.userToken = userToken
                self.info.imUrl = im_Url
                MSIMManager.sharedInstance().login(userToken, imUrl: im_Url, subAppID: 1) {
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = BFTabBarController()
                    
                } failed: { code, desc in
                    MSHelper.showToastFailWithText(text: desc ?? "")
                }
            } fail: { error in
                MSHelper.showToastFailWithText(text: error?.localizedDescription ?? "")
            }
        } fail: { error in
            MSHelper.showToastFailWithText(text: error?.localizedDescription ?? "")
        }
    }
}

extension BFSignInStepTwoController {
    
    private func didPickerAsset(image: UIImage,asset: PHAsset) {
        
        self.avatarIcon.image = image
        self.info.avatarImage = image
    }
}
