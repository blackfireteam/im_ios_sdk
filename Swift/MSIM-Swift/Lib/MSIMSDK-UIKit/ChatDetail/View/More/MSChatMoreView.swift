//
//  MSChatMoreView.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/3.
//

import UIKit


public protocol MSChatMoreViewDelegate: NSObjectProtocol {
    
    func didSelectMoreCell(moreView: MSChatMoreView,cell: MSInputMoreCell)
}

open class MSChatMoreView: UIView {

    public weak var delegate: MSChatMoreViewDelegate?
    
    private var lineView: UIView!
    
    private var moreCollectionView: UICollectionView!
    
    private var moreFlowLayout: UICollectionViewFlowLayout!
    
    private var pageControl: UIPageControl!
    
    private var rowCount: Int = 0
    
    private var itemsInSection: Int = 0
    
    private var sectionCount: Int = 0
    
    private var data: [MSInputMoreCellData] = []
    
    private var itemIndexs: [IndexPath: Int] = [:]
    
    public func setData(data: [MSInputMoreCellData]) {
        
        self.data = data
        if data.count > 4 {
            rowCount = 2
        }else {
            rowCount = 1
        }
        itemsInSection = 4 * rowCount
        sectionCount = Int(ceilf(Float(data.count) / Float(itemsInSection)))
        pageControl.numberOfPages = sectionCount
        
        itemIndexs.removeAll()
        for curSection in 0..<sectionCount {
            for itemIndex in 0..<itemsInSection {
                let row = itemIndex % rowCount
                let column = itemIndex / rowCount
                let reIndex = 4 * row + column + curSection * itemsInSection
                itemIndexs[IndexPath(row: itemIndex, section: curSection)] = reIndex
            }
        }
        moreCollectionView.reloadData()
        defaultLayout()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        defaultLayout()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension MSChatMoreView {
    
    func setupViews() {
        backgroundColor = UIColor.d_color(light: MSMcros.TInput_Background_Color, dark: MSMcros.TInput_Background_Color_Dark)
        
        moreFlowLayout = UICollectionViewFlowLayout()
        moreFlowLayout.scrollDirection = .horizontal
        moreFlowLayout.minimumLineSpacing = 0
        moreFlowLayout.minimumInteritemSpacing = 0
        moreFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
        
        moreCollectionView = UICollectionView(frame: .zero, collectionViewLayout: moreFlowLayout)
        moreCollectionView.register(MSInputMoreCell.self, forCellWithReuseIdentifier: "moreCell")
        moreCollectionView.isPagingEnabled = true
        moreCollectionView.delegate = self
        moreCollectionView.dataSource = self
        moreCollectionView.showsHorizontalScrollIndicator = false
        moreCollectionView.showsVerticalScrollIndicator = false
        moreCollectionView.backgroundColor = backgroundColor
        moreCollectionView.alwaysBounceHorizontal = true
        addSubview(moreCollectionView)
        
        lineView = UIView()
        lineView.backgroundColor = UIColor.d_color(light: MSMcros.TLine_Color, dark: MSMcros.TLine_Color_Dark)
        addSubview(lineView)
        
        pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor.d_color(light: MSMcros.TPage_Current_Color, dark: MSMcros.TPage_Current_Color_Dark)
        pageControl.pageIndicatorTintColor = UIColor.d_color(light: MSMcros.TPage_Color, dark: MSMcros.TPage_Color_Dark)
        addSubview(pageControl)
    }
    
    func defaultLayout() {
        
        let cellSize = MSInputMoreCell.getSize()
        let collectionHeight = cellSize.height * CGFloat(rowCount) + CGFloat(10 * (rowCount - 1))
        
        lineView.frame = CGRect(x: 0, y: 0, width: frame.width, height: MSMcros.TLine_Heigh)
        moreCollectionView.frame = CGRect(x: 0, y: lineView.top + lineView.height + 25, width: frame.width, height: collectionHeight)
        
        if sectionCount > 1 {
            pageControl.frame = CGRect(x: 0, y: moreCollectionView.top + moreCollectionView.height, width: frame.width, height: 30)
            pageControl.isHidden = false
        }else {
            pageControl.isHidden = true
        }
        if rowCount > 1 {
            moreFlowLayout.minimumInteritemSpacing = moreCollectionView.height - cellSize.height * CGFloat(rowCount) / CGFloat(rowCount - 1)
        }
        moreFlowLayout.minimumLineSpacing = (moreCollectionView.width - cellSize.width * 4 - 2 * 30) / (4 - 1)
        
        var height = moreCollectionView.top + moreCollectionView.height + 25
        if sectionCount > 1 {
            height = pageControl.top + pageControl.height
        }
        var frame = self.frame
        frame.size.height = height
        self.frame = frame
    }
}

extension MSChatMoreView: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionCount
    }
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsInSection
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "moreCell", for: indexPath) as! MSInputMoreCell
        var data: MSInputMoreCellData?
        let index = itemIndexs[indexPath]!
        if index >= self.data.count {
            data = nil
        }else {
            data = self.data[index]
        }
        cell.fillWithData(data: data)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! MSInputMoreCell
        
        delegate?.didSelectMoreCell(moreView: self, cell: cell)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return MSInputMoreCell.getSize()
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let contentOffsetX = scrollView.contentOffset.x
        let page = contentOffsetX / scrollView.width
        if Int(page * CGFloat(10)) % 10 == 0 {
            pageControl.currentPage = Int(page)
        }
    }
}
