//
//  BFEditTodInfoController.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/11/9.
//

import UIKit
import MSIMSDK


public class BFEditTodInfoController: BFBaseViewController {

    public var roomInfo: MSGroupInfo!
    
    private lazy var textView: UITextView = {
     
        let textView = UITextView(frame: CGRect(x: 20, y: UIScreen.status_navi_height + 20, width: UIScreen.width - 40, height: 150))
        textView.textColor = UIColor.d_color(light: MSMcros.TText_Color, dark: MSMcros.TText_Color_Dark)
        textView.font = .systemFont(ofSize: 15)
        return textView
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "发布群公告"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(submit))
        
        view.addSubview(self.textView)
        self.textView.becomeFirstResponder()
    }
    

    @objc private func submit() {
        if self.textView.text.count == 0 {return}
            self.view.endEditing(true)
        
        MSIMManager.sharedInstance().editChatRoomTOD(self.textView.text!, toRoom_id: self.roomInfo.room_id) {[weak self] in
            
            MSHelper.showToastSuccWithText(text: "Success")
            ///公告发布成功，模拟发一条公告文本消息
            let textElem = MSIMManager.sharedInstance().createTextMessage("[Tip of Day]\n\(self?.textView.text ?? "")")
            MSIMManager.sharedInstance().sendChatRoomMessage(textElem, toRoomID: self?.roomInfo.room_id ?? "") { _ in
                
            } failed: { _, _ in
                
            }
            
            self?.navigationController?.popViewController(animated: true)
            
        } failed: { _, desc in
            MSHelper.showToastFailWithText(text: desc ?? "")
        }
    }
}
