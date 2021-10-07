//
//  MSFaceView.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/8/3.
//

import UIKit

public protocol MSFaceViewDelegate: NSObjectProtocol {
    
    /**
     *  滑动到指定表情分组后的回调。
     *  您可以通过该回调响应使用者的滑动操作，进而更新表情视图的信息，展示出新表情组内的表情。
     *
     *  @param faceView 委托者，表情视图。通常情况下表情视图只有且只有一个。
     *  @param index 滑动的目的组号索引。
     */
    func scrollToFaceGroup(faceVeiw: MSFaceView, index: Int)
    
    /**
     *  选择某一具体表情后的回调（索引定位）。
     *  您可以通过该回调实现：当点击字符串类型的表情（如[微笑]）时，将表情添加到输入条。当点击其他类型的表情时，直接发送该表情。
     *
     *  @param faceView 委托者，表情视图。通常情况下表情视图只有且只有一个。
     *  @param indexPath 索引路径，定位表情。index.section：表情所在分组；index.row：表情所在行。
     */
    func didSelectItem(faceView: MSFaceView, indexPath: IndexPath)
    
    /**
     *  点击表情视图中 删除 按钮后的操作回调。
     *  您可以通过该回调实现：在 inputBar 中删除整个表情字符串，比如，对于“[微笑]”，直接删除中括号以及括号中间的内容，而不是仅删除最右侧”]“。
     *
     *  @param faceView 委托者，表情视图，通常情况下表情视图只有且只有一个。
     */
    func faceViewDidBackDelete(faceView: MSFaceView)
}

open class MSFaceView: UIView {

    
    public var lineView: UIView!
    
    public var faceCollectionView: UICollectionView!
    
    public var faceFlowLayout: UICollectionViewFlowLayout!
    
    public var pageControl: UIPageControl!
    
    public weak var delegate: MSFaceViewDelegate?
    
    private var faceGroups: [BFFaceGroup] = []
    
    private var sectionIndexInGroup: [Int] = []
    
    private var pageCountInGroup: [Int] = []
    
    private var groupIndexInSection: [Int] = []
    
    private var itemIndexs: [IndexPath: Int] = [:]
    
    private var sectionCount: Int = 0
    
    private var curGroupIndex: Int = 0
    
    /**
     *  滑动到指定表情分组。
     *  根据用户点击的表情分组的下标，切换到对应的表情分组下。
     *
     *  @param index 目的分组的组号索引，从0开始。
     */
    public func scrollToFaceGroup(index: Int) {
        
        if index > sectionIndexInGroup.count {return}
        let start = sectionIndexInGroup[index]
        let count = pageCountInGroup[index]
        let curSection = ceilf(Float(faceCollectionView.contentOffset.x / faceCollectionView.width))
        if Int(curSection) > start && Int(curSection) < start + count {
            return
        }
        let rect = CGRect(x: CGFloat(start) * faceCollectionView.width, y: 0, width: faceCollectionView.width, height: faceCollectionView.height)
        faceCollectionView.scrollRectToVisible(rect, animated: false)
        scrollViewDidScroll(faceCollectionView)
    }
    
    /**
     *  设置数据。
     *  用来进行 TUIFaceView 的初始化或在需要时更新 faceView 中的数据。
     *
     *  @param data 需要设置的数据（BFFaceGroup）。在此 NSMutableArray 中存放的对象为 BFFaceGroup，即表情组。
     */
    public func setData(data: [BFFaceGroup]) {
        
        faceGroups = data
        defaultLayout()
        
        var sectionIndex: Int = 0
        for groupIndex in 0..<faceGroups.count {
            
            let group = faceGroups[groupIndex]
            sectionIndexInGroup.append(sectionIndex)
            let itemCount = group.rowCount * group.itemCountPerRow
            let sectionCount = ceilf(Float(group.faces.count / (itemCount - (group.needBackDelete ? 1 : 0))))
            pageCountInGroup.append(Int(sectionCount))
            for _ in 0..<Int(sectionCount) {
                groupIndexInSection.append(groupIndex)
            }
            sectionIndex += Int(sectionCount)
        }
        sectionCount = sectionIndex
        
        for curSection in 0..<sectionCount {
            let groupIndex = groupIndexInSection[curSection]
            let groupSectionIndex = sectionIndexInGroup[groupIndex]
            let face = faceGroups[groupIndex]
            let itemCount = face.rowCount * face.itemCountPerRow - (face.needBackDelete ? 1 : 0)
            let groupSection = curSection - groupSectionIndex
            for itemIndex in 0..<itemCount {
                let row = itemIndex % face.rowCount
                let column = itemIndex / face.rowCount
                let reIndex = face.itemCountPerRow * row + column + groupSection * itemCount
                itemIndexs[IndexPath(row: itemIndex, section: curSection)] = reIndex
            }
        }
        curGroupIndex = 0
        if pageCountInGroup.count != 0 {
            pageControl.numberOfPages = pageCountInGroup.first!
        }
        faceCollectionView.reloadData()
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

private extension MSFaceView {
    
    func setupViews() {
        backgroundColor = UIColor.d_color(light: MSMcros.TInput_Background_Color, dark: MSMcros.TInput_Background_Color_Dark)
        
        faceFlowLayout = UICollectionViewFlowLayout()
        faceFlowLayout.scrollDirection = .horizontal
        faceFlowLayout.minimumLineSpacing = 8
        faceFlowLayout.minimumInteritemSpacing = 8
        faceFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        faceCollectionView = UICollectionView(frame: .zero,collectionViewLayout: faceFlowLayout)
        faceCollectionView.register(MSFaceCollectionCell.self, forCellWithReuseIdentifier: "MSFaceCollectionCell")
        faceCollectionView.collectionViewLayout = faceFlowLayout
        faceCollectionView.isPagingEnabled = true
        faceCollectionView.delegate = self
        faceCollectionView.dataSource = self
        faceCollectionView.showsHorizontalScrollIndicator = false
        faceCollectionView.showsVerticalScrollIndicator = false
        faceCollectionView.backgroundColor = backgroundColor
        faceCollectionView.alwaysBounceHorizontal = true
        addSubview(faceCollectionView)
        
        lineView = UIView()
        lineView.backgroundColor = UIColor.d_color(light: MSMcros.TLine_Color, dark: MSMcros.TLine_Color_Dark)
        addSubview(lineView)
        
        pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor.d_color(light: MSMcros.TPage_Current_Color, dark: MSMcros.TPage_Current_Color_Dark)
        pageControl.pageIndicatorTintColor = UIColor.d_color(light: MSMcros.TPage_Color, dark: MSMcros.TPage_Color_Dark)
        addSubview(pageControl)
    }
    
    func defaultLayout() {
        lineView.frame = CGRect(x: 0, y: 0, width: frame.width, height: MSMcros.TLine_Heigh)
        pageControl.frame = CGRect(x: 0, y: frame.height - 30, width: frame.width, height: 30)
        faceCollectionView.frame = CGRect(x: 0, y: lineView.top + lineView.height + 12, width: frame.width, height: frame.height - pageControl.height - lineView.height - 2 * 12)
    }
}

extension MSFaceView: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let groupIndex = groupIndexInSection[section]
        let group = faceGroups[groupIndex]
        return group.rowCount * group.itemCountPerRow
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MSFaceCollectionCell", for: indexPath) as! MSFaceCollectionCell
        let groupIndex = groupIndexInSection[indexPath.section]
        let group = faceGroups[groupIndex]
        let itemCount = group.rowCount * group.itemCountPerRow
        if indexPath.row == itemCount - 1 && group.needBackDelete {
            let data = BFFaceCellData()
            data.name = "del_normal"
            cell.setData(data: data)
        }else {
            let index = itemIndexs[indexPath]!
            if index < group.faces.count {
                let data = group.faces[index]
                cell.setData(data: data)
            }else {
                cell.setData(data: nil)
            }
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let groupIndex = groupIndexInSection[indexPath.section]
        let faces = faceGroups[groupIndex]
        let itemCount = faces.rowCount * faces.itemCountPerRow
        if indexPath.row == itemCount - 1 && faces.needBackDelete {
            delegate?.faceViewDidBackDelete(faceView: self)
        }else {
            let index = itemIndexs[indexPath]!
            if index < faces.faces.count {
                delegate?.didSelectItem(faceView: self, indexPath: IndexPath(row: index, section: groupIndex))
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let groupIndex = groupIndexInSection[indexPath.section]
        let group = faceGroups[groupIndex]
        
        let width = (frame.width - 20.0 * 2.0 - 8.0 * CGFloat(group.itemCountPerRow - 1)) / CGFloat(group.itemCountPerRow)
        let height = (collectionView.height - 8.0 * CGFloat((group.rowCount - 1))) / CGFloat(group.rowCount)
        return CGSize(width: width, height: height)
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let curSection = lroundf(Float(scrollView.contentOffset.x / scrollView.width))
        let groupIndex = groupIndexInSection[curSection]
        let startSection = sectionIndexInGroup[groupIndex]
        let pageCount = pageCountInGroup[groupIndex]
        if curGroupIndex != groupIndex {
            curGroupIndex = groupIndex
            pageControl.numberOfPages = pageCount
            delegate?.scrollToFaceGroup(faceVeiw: self, index: curGroupIndex)
        }
        pageControl.currentPage = curSection - startSection
    }
    
    
}

open class BFFaceGroup: NSObject {
    
    var groupIndex: Int = 0
    
    var groupPath: String?
    
    var rowCount: Int = 0
    
    var itemCountPerRow: Int = 0
    
    var faces: [BFFaceCellData] = []
    
    var needBackDelete: Bool = true
    
    var menuPath: String?
}
