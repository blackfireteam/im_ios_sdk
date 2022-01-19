//
//  BFLoginController.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/7/29.
//

import UIKit
import MSIMSDK


class BFLoginController: BFBaseViewController {

    var phoneTF: UITextField!
    
    var loginBtn: UIButton!
    
    var registerInfo: BFRegisterInfo = BFRegisterInfo()
    
    var serverSwitch: UISwitch!
    
    var serverL: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = Bundle.bf_localizedString(key: "WelcomeBack")
        
        phoneTF = UITextField(frame: CGRect(x: 35, y: UIScreen.status_navi_height + 80, width: UIScreen.width - 70, height: 50))
        phoneTF.placeholder = Bundle.bf_localizedString(key: "You-phone-number")
        phoneTF.font = .systemFont(ofSize: 16)
        phoneTF.textColor = UIColor.d_color(light: .black, dark: .white)
        phoneTF.keyboardType = .numberPad
        phoneTF.clearButtonMode = .always
        phoneTF.becomeFirstResponder()
        view.addSubview(phoneTF)
        
        let lineView = UIView(frame: CGRect(x: 35, y: phoneTF.bottom, width: UIScreen.width - 30, height: 0.5))
        lineView.backgroundColor = UIColor.d_color(light: MSMcros.TCell_separatorColor, dark: MSMcros.TCell_separatorColor_Dark)
        view.addSubview(lineView)
        
        loginBtn = UIButton(type: .custom)
        loginBtn.setTitle(Bundle.bf_localizedString(key: "LOGIN"), for: .normal)
        loginBtn.setTitleColor(.white, for: .normal)
        loginBtn.titleLabel?.font = .systemFont(ofSize: 16)
        loginBtn.backgroundColor = UIColor(r: 45, g: 45, b: 45)
        loginBtn.layer.cornerRadius = 2
        loginBtn.layer.masksToBounds = true
        loginBtn.addTarget(self, action: #selector(loginBtnDidClick), for: .touchUpInside)
        loginBtn.frame = CGRect(x: 35, y: lineView.bottom + 60, width: UIScreen.width - 70, height: 50)
        view.addSubview(loginBtn)
        
        serverSwitch = UISwitch()
        serverSwitch.frame = CGRect(x: loginBtn.left, y: loginBtn.bottom + 30, width: 60, height: 30)
        serverSwitch.addTarget(self, action: #selector(serverSwitchChanged), for: .valueChanged)
        view.addSubview(serverSwitch)
        
        serverL = UILabel()
        serverL.font = .systemFont(ofSize: 16)
        serverL.textColor = UIColor.d_color(light: .black, dark: .white)
        serverL.frame = CGRect(x: serverSwitch.right + 10, y: serverSwitch.top, width: loginBtn.width, height: serverSwitch.height)
        view.addSubview(serverL)
        
        serverSwitch.isOn = !UserDefaults.standard.bool(forKey: "ms_Test")
        serverL.text = API.test.baseURL.absoluteString
    }
    
    @objc func loginBtnDidClick() {
        
        view.endEditing(true)
        let phone = phoneTF.text?.trimmingCharacters(in: .whitespaces)
        if phone == nil || phone!.count == 0 {
            MSHelper.showToastFailWithText(text: "输入内容不能为空")
            return
        }
        registerInfo.phone = phone
        MSHelper.showToast()
        NetWorkManager.netWorkRequest(.getIMToken(uid: phone!)) { result in
            let dic = result as! [String: Any]
            let userToken = dic["token"] as! String
            let im_url = dic["url"] as! String
            print("im_token: \(userToken),im_Url: \(im_url)")
            self.registerInfo.userToken = userToken
            self.registerInfo.imUrl = im_url
            MSIMManager.sharedInstance().login(userToken, imUrl: im_url, subAppID: 1) {
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = BFTabBarController()
                
            } failed: { code, desc in
                MSHelper.showToastFailWithText(text: desc ?? "")
            }
        } fail: { error in
            MSHelper.dismissToast()
            if error?.code == 9 {//未注册，起注册流程
                let alert = UIAlertController(title: nil, message: "手机号未注册，现在注册吗?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: {[weak self] action in
                    self?.needToSignIn()
                }))
                alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }else {
                MSHelper.showToastFailWithText(text: error?.localizedDescription ?? "")
            }
        }
    }

    @objc func serverSwitchChanged(sw: UISwitch) {

        UserDefaults.standard.setValue(!sw.isOn, forKey: "ms_Test")
        
        serverL.text = API.test.baseURL.absoluteString
        MSDBManager.sharedInstance().accountChanged()
    }
    
    private func needToSignIn() {
        
        let vc = BFSignInStepOneController()
        vc.info = registerInfo
        navigationController?.pushViewController(vc, animated: true)
    }
}

