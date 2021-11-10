//
//  BFChatRoomMemberListController.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/11/2.
//

import UIKit
import MSIMSDK
import SwiftUI


public class BFChatRoomMemberListController: BFBaseViewController {

    public var roomInfo: MSGroupInfo!
    
    lazy var myCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (UIScreen.width - 15 * 3) * 0.5, height: (UIScreen.width - 15 * 3) * 0.5 * 1.3)
        layout.sectionInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 15
        layout.scrollDirection = .vertical
        let myCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height), collectionViewLayout: layout)
        myCollectionView.dataSource = self
        myCollectionView.delegate = self
        myCollectionView.alwaysBounceVertical = true
        myCollectionView.backgroundColor = UIColor.d_color(light: MSMcros.TController_Background_Color, dark: MSMcros.TController_Background_Color_Dark)
        myCollectionView.register(BFGroupMemberCell.self, forCellWithReuseIdentifier: "userCell")
        return myCollectionView
    }()
    
    var dataArray: [MSGroupMemberItem] = []
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Member List"
        view.addSubview(myCollectionView)
        
        loadData()
        addNotifications()
    }
    
    private func loadData() {
        if let roomID = self.roomInfo?.room_id,let room_id = Int(roomID) {
            MSIMManager.sharedInstance().chatRoomMembers(room_id) { users in
                
                self.dataArray.removeAll()
                self.dataArray += users
                self.myCollectionView.reloadData()
                
            } failed: { _, desc in
                MSHelper.showToastFailWithText(text: desc ?? "")
            }
        }
    }
    
    private func addNotifications() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init(rawValue: MSUIKitNotification_ProfileUpdate), object: nil, queue: OperationQueue.main) {[weak self] note in
            self?.profileUpdate(note: note)
        }
    }
    
    @objc func profileUpdate(note: Notification) {
        
        self.myCollectionView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension BFChatRoomMemberListController: UICollectionViewDelegate,UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userCell", for: indexPath) as! BFGroupMemberCell
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(userLongPress))
        cell.addGestureRecognizer(longPress)
        cell.info = self.dataArray[indexPath.row]
        return cell
    }
    
    @objc private func userLongPress(ges: UILongPressGestureRecognizer) {
        
        switch ges.state {
        case .began:
            if let cell = ges.view as? BFGroupMemberCell,let item = cell.info {
                showMoreAction(item: item)
            }
        default:
            break
        }
    }
    
    private func showMoreAction(item: MSGroupMemberItem) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let showTitle1: String = item.role == 0 ? "设置Ta为临时管理员" : "取消Ta的管理员身份"
        alert.addAction(UIAlertAction(title: showTitle1, style: .default, handler: {[weak self] _ in
            self?.changeUserRole(item: item)
        }))
        let showTitle2: String = item.is_mute == false ? "禁言" : "取消禁言"
        alert.addAction(UIAlertAction(title: showTitle2, style: .default, handler: {[weak self] _ in
            self?.changeUserMute(item: item)
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func changeUserRole(item: MSGroupMemberItem) {
        
        if self.roomInfo.action_assign == false {
            MSHelper.showToastWithText(text: "exceed your authority")
            return
        }
        //当uid是正值时 是任命， 当为负值时是 取消任命
        let uid: Int = Int(item.uid)!
        MSIMManager.sharedInstance().editChatroomManagerAccess(self.roomInfo.room_id, uids: [item.role == 0 ? NSNumber(value: uid) : NSNumber(value: -uid)], duration: 1, reason: "good job!") {[weak self] in
            
            MSHelper.showToastSuccWithText(text: "Success")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.myCollectionView.reloadData()
            }
        } failed: { _, desc in
            MSHelper.showToastFailWithText(text: desc ?? "")
        }
    }
    
    private func changeUserMute(item: MSGroupMemberItem) {
        
        if self.roomInfo.action_mute == false {
            MSHelper.showToastWithText(text: "exceed your authority")
            return
        }
        //当uid是正值是禁言，当uid为负值时是取消禁言
        let uid: Int = Int(item.uid)!
        MSIMManager.sharedInstance().muteMembers(self.roomInfo.room_id, uids: [item.is_mute ? NSNumber(value: -uid) : NSNumber(value: uid)], duration: 1, reason: "Don`t like a good guy") {[weak self] in
            
            MSHelper.showToastSuccWithText(text: "Success")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.myCollectionView.reloadData()
            }
        } failed: { _, desc in
            MSHelper.showToastFailWithText(text: desc ?? "")
        }
    }
}
