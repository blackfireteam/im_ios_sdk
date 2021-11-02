//
//  BFChatRoomMemberListController.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/11/2.
//

import UIKit
import MSIMSDK


public class BFChatRoomMemberListController: BFBaseViewController {

    public var roomInfo: MSChatRoomInfo?
    
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
        myCollectionView.register(BFUserListCell.self, forCellWithReuseIdentifier: "userCell")
        return myCollectionView
    }()
    
    var dataArray: [MSProfileInfo] = []
    
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
        
        guard let uids = self.roomInfo?.uids as? [Int] else {return}
        guard let profiles = note.object as? [MSProfileInfo] else {return}
        for info in profiles {
            if let user_id = Int(info.user_id),uids.contains(user_id) {
                self.dataArray.append(info)
            }
        }
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
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userCell", for: indexPath) as! BFUserListCell
        cell.config(info: self.dataArray[indexPath.row])
        return cell
    }
}
