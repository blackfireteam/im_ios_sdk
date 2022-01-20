//
//  BFEditTodInfoController.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/11/9.
//

import UIKit
import MSIMSDK


public class BFEditTodInfoController: BFBaseViewController {

    public var editComplete: (() -> Void)?
    
    public var roomInfo: MSGroupInfo!
    
    private lazy var textView: UITextView = {
     
        let textView = UITextView(frame: CGRect(x: 20, y: UIScreen.status_navi_height + 20, width: UIScreen.width - 40, height: 150))
        textView.textColor = UIColor.d_color(light: MSMcros.TText_Color, dark: MSMcros.TText_Color_Dark)
        textView.font = .systemFont(ofSize: 15)
        return textView
    }()
    
    private lazy var noticeL: UILabel = {
        let noticeL = UILabel(frame: CGRect(x: 0, y: UIScreen.height - UIScreen.safeAreaBottomHeight - 100, width: UIScreen.width, height: 20))
        noticeL.text = "----  管理员才能编辑和发布聊天室公告  ----"
        noticeL.font = .systemFont(ofSize: 14)
        noticeL.textColor = .lightGray
        noticeL.textAlignment = .center
        return noticeL
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "编辑群公告"
        
        view.addSubview(self.textView)
        self.textView.text = self.roomInfo.intro
        self.textView.isEditable = self.roomInfo.action_tod
        if self.roomInfo.action_tod {
            self.textView.becomeFirstResponder()
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(submit))
        }else {
            view.addSubview(self.noticeL)
        }
    }
    

    @objc private func submit() {
        if self.textView.text.count == 0 {return}
            self.view.endEditing(true)
        
        MSIMManager.sharedInstance().editChatRoomTOD(self.textView.text!, toRoom_id: self.roomInfo.room_id) {[weak self] in
            
            MSHelper.showToastSuccWithText(text: "发布公告成功")
            self?.roomInfo.intro = self?.textView.text
            self?.editComplete?()
            
            self?.navigationController?.popViewController(animated: true)
            
        } failed: { _, desc in
            MSHelper.showToastFailWithText(text: desc ?? "")
        }
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
