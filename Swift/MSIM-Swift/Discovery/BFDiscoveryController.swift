//
//  BFDiscoveryController.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/10.
//

import UIKit
import MSIMSDK


class BFDiscoveryController: BFBaseViewController {

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
    
    var dataArray: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "在线用户"
        view.addSubview(myCollectionView)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        NotificationCenter.default.addObserver(self, selector: #selector(userOnline), name: NSNotification.Name.init(rawValue: "MSUIKitNotification_Profile_online"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userOffline), name: NSNotification.Name.init(rawValue: "MSUIKitNotification_Profile_offline"), object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func userOnline(note: Notification) {
        
        if let uids = note.object as? [Int] {
            for uid in uids {
                if dataArray.contains(uid) == false {
                    dataArray.append(uid)
                }
            }
            DispatchQueue.main.async {
                self.myCollectionView.reloadData()
            }
        }
    }
    
    @objc func userOffline(note: Notification) {
        if let uids = note.object as? [Int] {
            for uid in uids {
                if let index = dataArray.firstIndex(of: uid) {
                    dataArray.remove(at: index)
                }
            }
            DispatchQueue.main.async {
                self.myCollectionView.reloadData()
            }
        }
    }
}

extension BFDiscoveryController: UICollectionViewDataSource,UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userCell", for: indexPath) as! BFUserListCell
        let info = MSProfileProvider.shared().providerProfile(fromLocal: "\(dataArray[indexPath.row])")
        cell.config(info: info)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = BFChatViewController()
        vc.partner_id = String(dataArray[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
