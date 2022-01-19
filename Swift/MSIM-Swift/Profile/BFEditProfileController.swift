//
//  BFEditProfileController.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/12/21.
//

import Foundation
import MSIMSDK
import Kingfisher
import Photos
import ZLPhotoBrowser


class BFEditProfileController: BFBaseViewController {
    
    var myTableView: UITableView!
    
    var headerView: BFProfileHeaderView!
    
    var goldSwitch: UISwitch!
    
    var verifySwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "编辑资料"
        
        setupUI()
    }
    
    private func setupUI() {
        
        myTableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height), style: .plain)
        myTableView.dataSource = self
        myTableView.delegate = self
        myTableView.separatorStyle = .none
        myTableView.rowHeight = 70
        myTableView.estimatedSectionHeaderHeight = 0
        myTableView.estimatedSectionFooterHeight = 0
        myTableView.estimatedRowHeight = 0
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(myTableView)
        
        headerView = BFProfileHeaderView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.statusbarHeight + 250))
        let avatarTap = UITapGestureRecognizer(target: self, action: #selector(avatarTap))
        headerView.avatarIcon.addGestureRecognizer(avatarTap)
        myTableView.tableHeaderView = headerView
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: 140))
        let logoutBtn = UIButton(type: .custom)
        logoutBtn.setTitle("退出登录", for: .normal)
        logoutBtn.setTitleColor(.red, for: .normal)
        logoutBtn.titleLabel?.font = .systemFont(ofSize: 15)
        logoutBtn.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        logoutBtn.layer.cornerRadius = 5
        logoutBtn.layer.masksToBounds = true
        logoutBtn.addTarget(self, action: #selector(logoutBtnClick), for: .touchUpInside)
        logoutBtn.frame = CGRect(x: UIScreen.width * 0.5 - 100, y: 50, width: 200, height: 40)
        footerView.addSubview(logoutBtn)
        myTableView.tableFooterView = footerView
        
        goldSwitch = UISwitch()
        goldSwitch.addTarget(self, action: #selector(goldSwitchChange), for: .valueChanged)
        verifySwitch = UISwitch()
        verifySwitch.addTarget(self, action: #selector(verifySwitchChange), for: .valueChanged)
        
    }
    
    @objc func avatarTap() {
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
    
    @objc func logoutBtnClick() {
        
        let alert = UIAlertController(title: "退出登录", message: "确定要退出吗？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { action in
            MSIMManager.sharedInstance().logout {
                
            } failed: { _, _ in
                
            }
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = BFNavigationController(rootViewController: BFLoginController())
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func reloadData() {
        MSProfileProvider.shared().providerProfile(MSIMTools.sharedInstance().user_id!) { profile in
            
            if (profile != nil) {
                self.headerView.avatarIcon.kf.setImage(with: URL(string: profile!.avatar))
                self.headerView.nickNameL.text = profile!.nick_name
                self.goldSwitch.isOn = profile!.gold
                self.verifySwitch.isOn = profile!.verified
            }
        }
    }
    
    private func editNickName(name: String) {
        
        let info = MSProfileProvider.shared().providerProfile(fromLocal: MSIMTools.sharedInstance().user_id!)
        info?.nick_name = name
        NetWorkManager.netWorkRequest(.profileEdit(info: info!)) { result in
            MSProfileProvider.shared().updateProfiles([info!])
            self.headerView.nickNameL.text = name
            MSHelper.showToastSuccWithText(text: "修改成功")
        } fail: { error in
            MSHelper.showToastFailWithText(text: error?.localizedDescription ?? "")
        }
    }
    
    private func editAvatar(url: String) {
        
        let info = MSProfileProvider.shared().providerProfile(fromLocal: MSIMTools.sharedInstance().user_id!)
        info?.avatar = url
        NetWorkManager.netWorkRequest(.profileEdit(info: info!)) { result in
            MSProfileProvider.shared().updateProfiles([info!])
            self.headerView.avatarIcon.kf.setImage(with: URL(string: url)!)
            MSHelper.showToastSuccWithText(text: "修改成功")
        } fail: { error in
            MSHelper.showToastFailWithText(text: error?.localizedDescription ?? "")
        }
    }
    
    @objc private func goldSwitchChange(sw: UISwitch) {
        
        if let info = MSProfileProvider.shared().providerProfile(fromLocal: MSIMTools.sharedInstance().user_id!) {
            info.gold = sw.isOn
            info.gold_exp = MSIMTools.sharedInstance().adjustLocalTimeInterval / 1000 / 1000 + 7 * 24 * 60 * 60
            NetWorkManager.netWorkRequest(.profileEdit(info: info)) { result in
                MSProfileProvider.shared().updateProfiles([info])
                MSHelper.showToastSuccWithText(text: "修改成功")
            } fail: { error in
                MSHelper.showToastFailWithText(text: error?.localizedDescription ?? "")
                sw.isOn = !sw.isOn
            }
        }
    }
    
    @objc private func verifySwitchChange(sw: UISwitch) {
        
        if let info = MSProfileProvider.shared().providerProfile(fromLocal: MSIMTools.sharedInstance().user_id!) {
            info.verified = sw.isOn
            NetWorkManager.netWorkRequest(.profileEdit(info: info)) { result in
                MSProfileProvider.shared().updateProfiles([info])
                MSHelper.showToastSuccWithText(text: "修改成功")
            } fail: { error in
                MSHelper.showToastFailWithText(text: error?.localizedDescription ?? "")
                sw.isOn = !sw.isOn
            }
        }
    }
}

extension BFEditProfileController: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cell.textLabel?.textColor = UIColor.d_color(light: MSMcros.TText_Color, dark: MSMcros.TText_Color_Dark)
        if indexPath.row == 0 {
            cell.textLabel?.text = "CHANGE NICKE NAME"
            cell.accessoryType = .disclosureIndicator
        }else if indexPath.row == 1 {
            cell.textLabel?.text = "GOLD"
            cell.accessoryView = goldSwitch
        }else if indexPath.row == 2 {
            cell.textLabel?.text = "VERIFIED"
            cell.accessoryView = verifySwitch
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row != 0 {return}
        let alert = UIAlertController(title: "修改昵称", message: nil, preferredStyle: .alert)
        alert.addTextField {[weak self] textField in
            textField.text = self?.headerView.nickNameL.text
        }
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: {[weak self] action in
            
            let tf = alert.textFields?.first
            let nickName = tf?.text?.trimmingCharacters(in: .whitespaces)
            if nickName == nil || nickName!.count < 3 {
                MSHelper.showToastFailWithText(text: "Nickname must contain at least 3 characters.")
                return
            }
            self?.editNickName(name: nickName!)
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

extension BFEditProfileController {
    
    private func didPickerAsset(image: UIImage,asset: PHAsset) {
        let imageElem = MSIMImageElem()
        imageElem.type = .MSG_TYPE_IMAGE
        imageElem.image = image
        imageElem.width = Int(image.size.width)
        imageElem.height = Int(image.size.height)
        imageElem.uuid = asset.localIdentifier
        MSIMManager.sharedInstance().uploadMediator?.ms_upload?(with: imageElem.image!, fileType: .avatar, progress: { progress in
            
        }, succ: {[weak self] url in
            
            self?.editAvatar(url: url)
            
        }, fail: { code, desc in
            MSHelper.showToastFailWithText(text: desc)
        })
    }
}
