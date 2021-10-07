//
//  BFSignInStepOneController.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/7/28.
//

import UIKit

class BFSignInStepOneController: BFBaseViewController {

    var info: BFRegisterInfo!
    
    private var nickNameTF: UITextField!
    
    private var nextBtn: UIButton!
    
    private var errL: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let titleL = UILabel(frame: CGRect(x: 35, y: UIScreen.status_navi_height, width: UIScreen.width - 70, height: 30))
        titleL.text = "MY NICKNAME IS"
        titleL.font = .boldSystemFont(ofSize: 21)
        titleL.textColor = UIColor.d_color(light: .black, dark: .white)
        view.addSubview(titleL)
        
        nickNameTF = UITextField(frame: CGRect(x: 35, y: titleL.bottom + 30, width: UIScreen.width - 70, height: 50))
        nickNameTF.placeholder = Bundle.bf_localizedString(key: "You-nickname")
        nickNameTF.font = .systemFont(ofSize: 16)
        nickNameTF.textColor = UIColor.d_color(light: .black, dark: .white)
        nickNameTF.clearButtonMode = .always
        nickNameTF.becomeFirstResponder()
        nickNameTF.text = info.nickName
        view.addSubview(nickNameTF)
        
        let lineView = UIView(frame: CGRect(x: 35, y: nickNameTF.bottom, width: UIScreen.width - 70, height: 0.5))
        lineView.backgroundColor = UIColor.d_color(light: MSMcros.TCell_separatorColor, dark: MSMcros.TCell_separatorColor_Dark)
        view.addSubview(lineView)
        
        errL = UILabel(frame: CGRect(x: nickNameTF.left, y: lineView.bottom + 8, width: nickNameTF.width, height: 20))
        errL.font = .systemFont(ofSize: 15)
        errL.textColor = .red
        view.addSubview(errL)
        
        nextBtn = UIButton(type: .custom)
        nextBtn.setTitle(Bundle.bf_localizedString(key: "Next-button"), for: .normal)
        nextBtn.setTitleColor(.white, for: .normal)
        nextBtn.titleLabel?.font = .systemFont(ofSize: 16)
        nextBtn.backgroundColor = UIColor(r: 45, g: 45, b: 45)
        nextBtn.layer.cornerRadius = 2
        nextBtn.layer.masksToBounds = true
        nextBtn.addTarget(self, action: #selector(nextBtnDidClick), for: .touchUpInside)
        nextBtn.frame = CGRect(x: 35, y: lineView.bottom + 60, width: UIScreen.width - 70, height: 50)
        view.addSubview(nextBtn)
    }
    
    @objc func nextBtnDidClick() {
        
        view.endEditing(true)
        let nickName = nickNameTF.text?.trimmingCharacters(in: .whitespaces)
        if nickName == nil || nickName!.count < 3 {
            errL.text = "Nickname must contain at least 3 characters."
            return
        }
        info.nickName = nickName
        
        let vc = BFSignInStepTwoController()
        vc.info = info
        navigationController?.pushViewController(vc, animated: true)
    }
}
