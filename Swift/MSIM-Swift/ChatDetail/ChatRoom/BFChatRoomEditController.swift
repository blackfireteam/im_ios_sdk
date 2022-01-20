//
//  BFChatRoomEditController.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/11/9.
//

import UIKit
import MSIMSDK


public class BFChatRoomEditController: BFBaseViewController {

    public var roomInfo: MSGroupInfo!
    
    private lazy var myTableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height), style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 60
        tableView.contentInset = UIEdgeInsets(top: UIScreen.status_navi_height, left: 0, bottom: UIScreen.safeAreaBottomHeight, right: 0)
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Chat Room Setting"
        view.addSubview(myTableView)
        
        let quitBtn = UIButton(type: .custom)
        quitBtn.setTitle("退出群聊", for: .normal)
        quitBtn.setTitleColor(.white, for: .normal)
        quitBtn.titleLabel?.font = .systemFont(ofSize: 16)
        quitBtn.backgroundColor = .red
        quitBtn.frame = CGRect(x: 0, y: 0, width: UIScreen.width, height: 60)
        quitBtn.addTarget(self, action: #selector(quitBtnClick), for: .touchUpInside)
        self.myTableView.tableFooterView = quitBtn
    }
    
    @objc func quitBtnClick() {
        navigationController?.popToRootViewController(animated: true)
    }
}

extension BFChatRoomEditController: UITableViewDataSource,UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.roomInfo.action_tod {
            return 4
        }
        return 3
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        if indexPath.row == 0 {
            cell.textLabel?.text = "Member List"
            cell.detailTextLabel?.text = "\(self.roomInfo.onlineCount) 人"
        }else if indexPath.row == 1 {
            cell.textLabel?.text = "Chat room name"
            cell.detailTextLabel?.text = self.roomInfo.room_name
        }else if indexPath.row == 2 {
            cell.textLabel?.text = "Tips of day"
        }else if indexPath.row == 3 {
            cell.textLabel?.text = self.roomInfo.is_mute ? "Cancel Mute" : "Mute"
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let vc = BFChatRoomMemberListController()
            vc.roomInfo = self.roomInfo
            navigationController?.pushViewController(vc, animated: true)
        }else if indexPath.row == 1 {//修改聊天室名称
            MSHelper.showToastWithText(text: "聊天室名称只支持后台修改")
        }else if indexPath.row == 2 {//修改公告

            let vc = BFEditTodInfoController()
            vc.roomInfo = self.roomInfo
            self.navigationController?.pushViewController(vc, animated: true)
            vc.editComplete = {[weak self] in
                self?.myTableView.reloadData()
            }
        }else if indexPath.row == 3 {
            editChatRoomMuteStatus()
        }
    }
    
    private func editChatRoomMuteStatus() {
        MSIMManager.sharedInstance().muteChatRoom(!self.roomInfo.is_mute, toRoom_id: self.roomInfo.room_id, duration: 1) {[weak self] in
            
            MSHelper.showToastSuccWithText(text: "Success")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.myTableView.reloadData()
            }
        } failed: { _, desc in
            MSHelper.showToastFailWithText(text: desc ?? "")
        }
    }
}
