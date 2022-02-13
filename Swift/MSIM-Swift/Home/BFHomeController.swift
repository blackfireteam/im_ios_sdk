//
//  BFHomeController.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/2.
//

import UIKit
import MSIMSDK



class BFHomeController: BFBaseViewController, BFSparkCardCellDelegate {
    

    lazy var container: BFSparkCardView = {
        
        let maxH = UIScreen.height - UIScreen.statusbarHeight - 10 - UIScreen.tabBarHeight - 10;
        let cardW = UIScreen.width - 30;
        let cardH = min(cardW / 0.6, maxH)
        let container = BFSparkCardView(frame: CGRect(x: 15, y: UIScreen.statusbarHeight + 10 + (maxH - cardH) * 0.5, width: cardW, height: cardH))
        container.delegate = self
        container.dataSource = self
        container.visibleCount = 3
        container.lineSpacing = 10
        container.interitemSpacing = 10
        container.maxAngle = 15
        container.maxRemoveDistance = 100
        container.registerClass(cellClass: BFSparkCardCell.self, forCellReuseIdentifier: "cardCell")
        return container
    }()
    
    lazy var loadingView: BFSparkLoadingView = {
        let loadingView = BFSparkLoadingView(frame: CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height))
        return loadingView
    }()
    
    lazy var emptyView: BFSparkEmptyView = {
        let emptyView = BFSparkEmptyView(frame: CGRect(x: 0, y: UIScreen.height * 0.35, width: UIScreen.width, height: 235))
        emptyView.isHidden = true
        emptyView.retryBtn.addTarget(self, action: #selector(retryButtonClick), for: .touchUpInside)
        return emptyView
    }()
    
    var dataList: [MSProfileInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(loadingView)
        loadingView.beginAnimating()
        
        view.addSubview(container)
        view.addSubview(emptyView)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.loadParksData()
        }
    }

    func loadParksData() {
        MSIMManager.sharedInstance().getSparks { sparks in
            
            self.dataList.removeAll()
            self.dataList += sparks
            self.bf_reloadData()
            
        } fail: { code, desc in
            
            MSHelper.showToastFailWithText(text: desc ?? "")
            self.loadingView.stopAnimating()
            self.emptyView.isHidden = false
        }
    }
    
    func bf_reloadData() {
        
        container.alpha = 0
        emptyView.isHidden = true
        UIView.animate(withDuration: 0.5) {
            self.container.alpha = 1
    
        } completion: { _ in
            self.loadingView.stopAnimating()
            self.emptyView.isHidden = self.dataList.count != 0
        }
        container.reloadData()
    }
    
    @objc func retryButtonClick() {
        loadParksData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

}

extension BFHomeController: BFSparkCardViewDelegate,BFSparkCardViewDataSource {
    func cardView(cardView: BFSparkCardView, didRemoveCell: BFCardViewCell, forRowAtIndex: Int, direction: CardCellSwipeDirection) {
        let cell = didRemoveCell as! BFSparkCardCell
        cell.like.alpha = 0
        cell.dislike.alpha = 0
    }
    
    func cardView(cardView: BFSparkCardView, didRemoveLastCell: BFCardViewCell, forRowAtIndex: Int) {
        emptyView.isHidden = false
    }
    
    func cardView(cardView: BFSparkCardView, didDisplayCell: BFCardViewCell, forRowAtIndex: Int) {
        
    }
    
    func cardView(cardView: BFSparkCardView, didMoveCell: BFCardViewCell, forMovePoint: CGPoint, direction: CardCellSwipeDirection) {
        let cell = didMoveCell as! BFSparkCardCell
        if direction == .left {
            cell.like.alpha = 0
            cell.dislike.alpha = 1
            cell.dislike.transform = CGAffineTransform(rotationAngle: CGFloat(45 * Double.pi) / 180)
        }else if direction == .right {
            cell.dislike.alpha = 0
            cell.like.alpha = 1
            cell.like.transform = CGAffineTransform(rotationAngle: CGFloat(-45 * Double.pi) / 180)
        }else {
            cell.like.alpha = 0
            cell.dislike.alpha = 0
        }
    }
    
    
    func numberOfCountInCardView(cardView: BFSparkCardView) -> Int {
        return dataList.count
    }
    
    func cellForRowAtIndex(cardView: BFSparkCardView, index: Int) -> BFCardViewCell {
        let cell = cardView.dequeueReusableCellWithIdentifier(identifier: "cardCell") as! BFSparkCardCell
        cell.configItem(item: dataList[index])
        cell.delegate = self
        return cell
    }
    
    func winkBtnDidClick(cell: BFSparkCardCell) {
        if cell.profile?.user_id != nil && cell.winkBtn.isSelected == false {
            let elem = MSIMEmotionElem()
            elem.emotionID = "008"
            elem.emotionName = "emotion_08"
            let message = MSIMManager.sharedInstance().createEmotionMessage(elem)
            MSIMManager.sharedInstance().sendC2CMessage(message, toReciever: cell.profile!.user_id) { msg_id in
                
                cell.winkBtn.isSelected = true
            } failed: { code, desc in
                MSHelper.showToastFailWithText(text: desc ?? "")
            }

        }
    }
    
    func chatBtnDidClick(cell: BFSparkCardCell) {
        if let uid = cell.profile?.user_id {
            let vc = BFChatViewController()
            vc.partner_id = uid
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
