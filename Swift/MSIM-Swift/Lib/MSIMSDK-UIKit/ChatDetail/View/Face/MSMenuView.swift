//
//  MSMenuView.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/3.
//

import UIKit

protocol MSMenuViewDelegate: NSObjectProtocol {
    
    func menuViewDidSendMessage(menuView: MSMenuView)
    
    func menuViewDidSelectItemAtIndex(index: Int)
}

class MSMenuView: UIView {

    weak var delegate: MSMenuViewDelegate?
    
    var data: [MSMenuCellData] = [] {
        didSet {
            menuCollectionView.reloadData()
            defaultLayout()
            menuCollectionView.layoutIfNeeded()
            menuCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .bottom)
        }
    }
    
    private var sendButton: UIButton!
    
    private var menuFlowLayout: UICollectionViewFlowLayout!
    
    private var menuCollectionView: UICollectionView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.d_color(light: MSMcros.TInput_Background_Color, dark: MSMcros.TInput_Background_Color_Dark)
        
        sendButton = UIButton()
        sendButton.titleLabel?.font = .systemFont(ofSize: 15)
        sendButton.setTitle(Bundle.bf_localizedString(key: "Send"), for: .normal)
        sendButton.backgroundColor = UIColor(r: 87, g: 190, b: 105)
        sendButton.addTarget(self, action: #selector(sendUpInside), for: .touchUpInside)
        addSubview(sendButton)
        
        menuFlowLayout = UICollectionViewFlowLayout()
        menuFlowLayout.scrollDirection = .horizontal
        menuFlowLayout.minimumLineSpacing = 0
        menuFlowLayout.minimumInteritemSpacing = 0
        
        menuCollectionView = UICollectionView(frame: .zero, collectionViewLayout: menuFlowLayout)
        menuCollectionView.register(MSMenuCollectionViewCell.self, forCellWithReuseIdentifier: MSMcros.TMenuCell_ReuseId)
        menuCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: MSMcros.TMenuCell_Line_ReuseId)
        menuCollectionView.collectionViewLayout = menuFlowLayout
        menuCollectionView.delegate = self
        menuCollectionView.dataSource = self
        menuCollectionView.showsHorizontalScrollIndicator = false
        menuCollectionView.showsVerticalScrollIndicator = false
        menuCollectionView.backgroundColor = backgroundColor
        menuCollectionView.alwaysBounceHorizontal = true
        addSubview(menuCollectionView)

        defaultLayout()
    }
    
    private func defaultLayout() {
        let buttonWidth = frame.height * 1.3
        sendButton.frame = CGRect(x: self.frame.size.width - buttonWidth, y: 0, width: buttonWidth, height: self.frame.size.height)
        menuCollectionView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width - 2 * buttonWidth, height: self.frame.size.height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func sendUpInside() {
        
        delegate?.menuViewDidSendMessage(menuView: self)
    }
    
    func scrollToMenu(at index: Int, in group: MSFaceGroup) {
        for(i,d) in self.data.enumerated() {
            d.isSelected = (i == index)
        }
        sendButton.isHidden = !group.needSendBtn
        menuCollectionView.reloadData()
    }
}

extension MSMenuView: UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count * 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row % 2 == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MSMcros.TMenuCell_ReuseId, for: indexPath) as! MSMenuCollectionViewCell
            cell.data = self.data[indexPath.row / 2]
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MSMcros.TMenuCell_Line_ReuseId, for: indexPath)
            cell.backgroundColor = .clear
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row % 2 != 0 {return}
        
        for (index,d) in self.data.enumerated() {
            d.isSelected = (index == indexPath.row / 2)
        }
        menuCollectionView.reloadData()
        self.delegate?.menuViewDidSelectItemAtIndex(index: indexPath.row / 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.row % 2 == 0 {
            return CGSize(width: collectionView.height, height: collectionView.height)
        }else {
            return CGSize(width: MSMcros.TLine_Heigh, height: collectionView.height)
        }
    }
}
