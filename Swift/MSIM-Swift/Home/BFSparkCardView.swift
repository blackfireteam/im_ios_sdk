//
//  BFCardViewCell.swift
//  MSIM-Swift
//
//  Created by benny wang on 2021/7/29.
//

import UIKit

protocol BFSparkCardViewDataSource: NSObjectProtocol {
    
    func numberOfCountInCardView(cardView: BFSparkCardView) -> Int
    
    func cellForRowAtIndex(cardView: BFSparkCardView, index: Int) -> BFCardViewCell
}

protocol BFSparkCardViewDelegate: NSObjectProtocol {
    
    func cardView(cardView: BFSparkCardView,didRemoveCell: BFCardViewCell,forRowAtIndex: Int,direction: CardCellSwipeDirection)
    
    func cardView(cardView: BFSparkCardView,didRemoveLastCell: BFCardViewCell,forRowAtIndex: Int)
    
    func cardView(cardView: BFSparkCardView,didDisplayCell: BFCardViewCell,forRowAtIndex: Int)
    
    func cardView(cardView: BFSparkCardView,didMoveCell: BFCardViewCell,forMovePoint: CGPoint,direction: CardCellSwipeDirection)
}

class BFSparkCardView: UIView {
    

    /** 卡片可见数量(默认3) */
    var visibleCount: Int = 3
    
    /** 行间距(默认10.0，可自行计算scale比例来做间距) */
    var lineSpacing: CGFloat = 10
    
    /** 列间距(默认10.0，可自行计算scale比例来做间距) */
    var interitemSpacing: CGFloat = 10
    
    /** 侧滑最大角度(默认15°) */
    var maxAngle: CGFloat = 15
    
    /** 最大移除距离(默认屏幕的1/4) */
    var maxRemoveDistance: CGFloat = UIScreen.width / 4
    
    /** 是否重复(默认NO) */
    var isRepeat: Bool = false
    
    /** 当前可视cells */
    var visibleCells: [BFCardViewCell] {
        return containerView.subviews as! [BFCardViewCell]
    }
    
    var cellClass: AnyClass!
    
    var identifier: String!
    
    weak var dataSource: BFSparkCardViewDataSource?
    
    weak var delegate: BFSparkCardViewDelegate?
    
    /** 重用卡片数组  */
    private var reusableCells: [BFCardViewCell] = []
    
    private var currentIndex: Int = 0
    
    private var containerView: UIView!
    
    var currentFirstIndex: Int {
        var index = currentIndex - visibleCells.count + 1
        if isRepeat {
            if index < 0 {
                index += dataSource!.numberOfCountInCardView(cardView: self)
            }
        }
        return index
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configCardView()
    }
    
    private func configCardView() {
        
        containerView = UIView(frame: bounds)
        containerView.autoresizingMask = [.flexibleWidth , .flexibleHeight]
        addSubview(containerView)
    }
    
    func reloadData() {
        reloadDataAnimated(animated: false)
    }
    
    private func reloadDataAnimated(animated: Bool) {
        currentIndex = 0
        reusableCells.removeAll()
        containerView.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
        var maxCount = dataSource?.numberOfCountInCardView(cardView: self) ?? 0
        maxCount = isRepeat ? (maxCount + visibleCount - 1) : maxCount
        let showNumber = min(maxCount, visibleCount)
        for i in 0..<showNumber {
            createCardViewCell(index: i)
        }
        updateLayoutVisibleCells(animated: animated)
    }
    
    private func reloadDataRepeat(animated: Bool) {
        currentIndex = 0
        reusableCells.removeAll()
        containerView.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
        var maxCount = dataSource?.numberOfCountInCardView(cardView: self) ?? 0
        maxCount = isRepeat ? (maxCount + visibleCount - 1) : maxCount
        let showNumber = min(maxCount, visibleCount)
        for i in 0..<showNumber {
            createRepeatCardViewCell(index: i)
        }
        updateLayoutVisibleCells(animated: animated)
    }
    
    func reloadMoreData() {
        reloadMoreDataAnimated(animated: false)
    }
    
    func reloadMoreDataAnimated(animated: Bool) {
        assert(!isRepeat, "isRepeat为YES不允许加载更多数据！")
        reusableCells.removeAll()
        let loadMoreCount = visibleCount - visibleCells.count
        let loadMaxLength = currentIndex + loadMoreCount
        for i in currentIndex+1..<loadMaxLength {
            createCardViewCell(index: i)
        }
        updateLayoutVisibleCells(animated: animated)
    }
    
    func reloadDataFormIndex(index: Int) {
        reloadDataFormIndex(index: index,animated: false)
    }
    
    func reloadDataFormIndex(index: Int,animated: Bool) {
        assert(!isRepeat, "isRepeat为YES不允许从索引处加载！")
        let maxCount = dataSource?.numberOfCountInCardView(cardView: self) ?? 0
        assert(index < maxCount, "index不能大于等于cell的数量！")
        
        reusableCells.removeAll()
        containerView.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
        var loadMaxLength = index + visibleCount
        loadMaxLength = min(loadMaxLength, maxCount)
        for i in index..<loadMaxLength {
            createCardViewCell(index: i)
        }
        updateLayoutVisibleCells(animated: animated)
    }
    
    func createCardViewCell(index: Int) {
        let cell = dataSource!.cellForRowAtIndex(cardView: self, index: index)
        cell.index = index
        cell.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        cell.maxRemoveDistance = maxRemoveDistance
        cell.maxAngle = maxAngle
        cell.cell_delegate = self
        cell.isUserInteractionEnabled = false
        let showCount = visibleCount - 1
        let width = frame.size.width
        let height = frame.size.height - (CGFloat(showCount) * interitemSpacing)
        cell.frame = CGRect(x: 0, y: 0, width: width, height: height)
        containerView.insertSubview(cell, at: 0)
        containerView.layoutIfNeeded()
        currentIndex = index
        
        let minWidth = frame.size.width - 2 * lineSpacing * CGFloat(showCount)
        let minHeight = frame.size.height - 2 * interitemSpacing * CGFloat(showCount)
        let minWScale = minWidth / frame.size.width
        let minHScale = minHeight / frame.size.height
        let yOffset = (interitemSpacing / minHScale) * 2 * CGFloat(showCount)
        let scaleTransform = CGAffineTransform(scaleX: minWScale, y: minHScale)
        let transform = scaleTransform.translatedBy(x: 0, y: yOffset)
        cell.transform = transform
    }
    
    func createRepeatCardViewCell(index: Int) {
        let cell = dataSource!.cellForRowAtIndex(cardView: self, index: index)
        cell.index = index
        cell.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        cell.maxRemoveDistance = maxRemoveDistance
        cell.maxAngle = maxAngle
        cell.cell_delegate = self
        cell.isUserInteractionEnabled = false
        let showCount = visibleCount
        let width = frame.size.width
        let height = frame.size.height - (CGFloat(showCount) * interitemSpacing)
        cell.frame = CGRect(x: 0, y: 0, width: width, height: height)
        containerView.insertSubview(cell, at: 0)
        containerView.layoutIfNeeded()
        currentIndex = index
        
        let minWidth = frame.size.width - 2 * lineSpacing * CGFloat(showCount)
        let minHeight = frame.size.height - 2 * interitemSpacing * CGFloat(showCount)
        let minWScale = minWidth / frame.size.width
        let minHScale = minHeight / frame.size.height
        let yOffset = (interitemSpacing / minHScale) * 2 * CGFloat(showCount)
        let scaleTransform = CGAffineTransform(scaleX: minWScale, y: minHScale)
        let transform = scaleTransform.translatedBy(x: 0, y: yOffset)
        cell.transform = transform
    }
    
    func updateLayoutVisibleCells(animated: Bool) {
        let showCount = visibleCount - 1
        let minWidth = frame.size.width - 2 * lineSpacing * CGFloat(showCount)
        let minHeight = frame.size.height - 2 * interitemSpacing * CGFloat(showCount)
        let minWScale = minWidth / frame.size.width
        let minHScale = minHeight / frame.size.height
        let itemWScale = (1.0 - minWScale) / CGFloat(showCount)
        let itemHScale = (1.0 - minHScale) / CGFloat(showCount)
        let count = visibleCells.count
        for i in 0..<count {
            
            let showIndex = count - i - 1;
            let wScale = 1.0 - CGFloat(showIndex) * itemWScale;
            let hScale = 1.0 - CGFloat(showIndex) * itemHScale;
            let y = (self.interitemSpacing / hScale) * 2 * CGFloat(showIndex);
            let scaleTransform = CGAffineTransform(scaleX: wScale, y: hScale)
            let transform = scaleTransform.translatedBy(x: 0, y: y)
            // 获取当前要显示的的cells
            let cell = self.visibleCells[i];
            // 判断是不是当前显示的最后一个(最上层显示)
            let isLast = (i == (count - 1));
            if (isLast) {
                cell.isUserInteractionEnabled = true
                delegate?.cardView(cardView: self, didDisplayCell: cell, forRowAtIndex: cell.index)
            }
            if (animated) {
                updateConstraintsCell(cell: cell, transform: transform)
            } else {
                cell.transform = transform
            }
        }
    }
    
    func updateConstraintsCell(cell: BFCardViewCell,transform: CGAffineTransform) {
        UIView.animate(withDuration: 0.25) {
            cell.transform = transform
        }
    }
    
    func visibleIndex(index: Int) -> Int {
        if isRepeat {
            if index < currentFirstIndex {
                return index + dataSource!.numberOfCountInCardView(cardView: self) - currentFirstIndex
            }
        }
        return index - currentFirstIndex
    }
    
    func registerClass(cellClass: AnyClass,forCellReuseIdentifier: String) {
        self.cellClass = cellClass
        self.identifier = forCellReuseIdentifier
    }
    
    func dequeueReusableCellWithIdentifier(identifier: String) -> BFCardViewCell {
        
        for (index,cell) in reusableCells.enumerated() {
            if cell.reuseIdentifier == identifier {
                reusableCells.remove(at: index)
                return cell
            }
        }
        let cell = BFSparkCardCell(reuseIdentifier: identifier)
        cell.reuseIdentifier = identifier
        return cell
    }
    
    func cellForRowAtIndex(index: Int) -> BFCardViewCell? {
        
        let visibleIndex = visibleIndex(index: index)
        if visibleIndex >= 0 && visibleIndex < visibleCells.count {
            let cell = visibleCells[visibleIndex]
            return cell
        }
        return nil
    }
    
    func indexForCell(cell: BFCardViewCell) -> Int {
        return cell.index
    }
    
    func removeTopCardViewFromSwipe(direction: CardCellSwipeDirection) {
        
        if visibleCells.count == 0 {return}
        let topCell = visibleCells.last
        topCell?.removeFromSuperviewSwipe(direction: direction)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension BFSparkCardView: BFCardViewCellDelagate {
    
    func cardViewCellDidRemoveFromSuperView(cell: BFCardViewCell, direction: CardCellSwipeDirection) {
        reusableCells.append(cell)
        delegate?.cardView(cardView: self, didRemoveCell: cell, forRowAtIndex: cell.index, direction: direction)
        let count = dataSource?.numberOfCountInCardView(cardView: self) ?? 0
        if visibleCells.count == 0 {
            delegate?.cardView(cardView: self, didRemoveLastCell: cell, forRowAtIndex: cell.index)
            return
        }
        if isRepeat {
            let reCount = isRepeat ? (count + visibleCount - 1) : count
            if currentIndex < reCount - 1 {
                createCardViewCell(index: (currentIndex+1)%count)
            }else {
                reloadDataAnimated(animated: true)
            }
        }else {
            if currentIndex < count - 1 {
                createCardViewCell(index: currentIndex + 1)
            }
        }
        updateLayoutVisibleCells(animated: true)
    }
    
    func cardViewCellDidMoveFromSuperView(cell: BFCardViewCell, point: CGPoint) {
        
        if cell.currentPoint.x > cell.maxRemoveDistance {
            delegate?.cardView(cardView: self, didMoveCell: cell, forMovePoint: point, direction: .right)
        }else if cell.currentPoint.x < -cell.maxRemoveDistance {
            delegate?.cardView(cardView: self, didMoveCell: cell, forMovePoint: point, direction: .left)
        }else {
            delegate?.cardView(cardView: self, didMoveCell: cell, forMovePoint: point, direction: .none)
        }
    }
}

enum CardCellSwipeDirection {
    case none
    case left
    case right
}

protocol BFCardViewCellDelagate: NSObjectProtocol {
    
    func cardViewCellDidRemoveFromSuperView(cell: BFCardViewCell,direction: CardCellSwipeDirection)
    
    func cardViewCellDidMoveFromSuperView(cell: BFCardViewCell,point: CGPoint)
}
class BFCardViewCell: UIView {
    
    var reuseIdentifier: String
    
    var currentPoint: CGPoint = .zero
    
    var maxRemoveDistance: CGFloat = 0
    
    var maxAngle: CGFloat = 0
    
    var index: Int = 0
    
    weak var cell_delegate: BFCardViewCellDelagate?
    
    init(reuseIdentifier: String) {
        
        self.reuseIdentifier = reuseIdentifier
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func removeFromSuperviewSwipe(direction: CardCellSwipeDirection) {
        
        switch direction {
        case .left:
            removeFromSuperviewLeft()
        case .right:
            removeFromSuperviewRight()
        default:
            break
        }
    }
    
    private func removeFromSuperviewLeft() {
        let snapshotView = snapshotView(afterScreenUpdates: false)
        superview?.superview?.addSubview(snapshotView!)
        didCellRemoveFromSuperviewWithDirection(direction: .left)
        
        let transRotation = CGAffineTransform(rotationAngle: maxAngle / 180.0 * CGFloat(Double.pi))
        let transform = transRotation.translatedBy(x: 0, y: frame.size.height / 4.0)
        let endCenterX = -(UIScreen.width * 0.5 + frame.size.width)
        UIView.animate(withDuration: 0.25) {
            var center = self.center
            center.x = endCenterX
            snapshotView?.center = center
            snapshotView?.transform = transform
        } completion: { _ in
            snapshotView?.removeFromSuperview()
        }
    }
    
    private func removeFromSuperviewRight() {
        let snapshotView = snapshotView(afterScreenUpdates: false)
        snapshotView?.frame = frame
        superview?.superview?.addSubview(snapshotView!)
        didCellRemoveFromSuperviewWithDirection(direction: .right)
        
        let transRotation = CGAffineTransform(rotationAngle: maxAngle / 180.0 * CGFloat(Double.pi))
        let transform = transRotation.translatedBy(x: 0, y: frame.size.height / 4.0)
        let endCenterX = UIScreen.width * 0.5 + frame.size.width * 1.5
        UIView.animate(withDuration: 0.25) {
            var center = self.center
            center.x = endCenterX
            snapshotView?.center = center
            snapshotView?.transform = transform
        } completion: { _ in
            snapshotView?.removeFromSuperview()
        }
    }
    
    private func setupView() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizer))
        addGestureRecognizer(pan)
    }
    
    @objc private func panGestureRecognizer(pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            currentPoint = .zero
        case .changed:
            let movePoint = pan.translation(in: pan.view)
            currentPoint = CGPoint(x: currentPoint.x + movePoint.x, y: currentPoint.y + movePoint.y)
            
            var moveScale = currentPoint.x / maxRemoveDistance
            if abs(moveScale) > 1.0 {
                moveScale = moveScale > 0 ? 1.0 : -1.0
            }
            let angle = maxAngle / 180.0 * CGFloat(Double.pi) * moveScale
            let transRotation = CGAffineTransform(rotationAngle: angle)
            transform = transRotation.translatedBy(x: currentPoint.x, y: currentPoint.y)
            
            cell_delegate?.cardViewCellDidMoveFromSuperView(cell: self, point: currentPoint)
            pan.setTranslation(.zero, in: pan.view)
        case .ended:
            didPanStateEnded()
        default:
            restoreCellLocation()
        }
    }
    
    private func didPanStateEnded() {
        if currentPoint.x > maxRemoveDistance {
            let snapshotView = snapshotView(afterScreenUpdates: false)
            snapshotView?.transform = transform
            superview?.superview?.addSubview(snapshotView!)
            didCellRemoveFromSuperviewWithDirection(direction: .right)
            
            let endCenterX = UIScreen.width * 0.5 + frame.size.width * 1.5
            UIView.animate(withDuration: 0.25) {
                var center = self.center
                center.x = endCenterX
                snapshotView?.center = center
            } completion: { _ in
                snapshotView?.removeFromSuperview()
            }
        }else if currentPoint.x < -maxRemoveDistance {
            let snapshotView = snapshotView(afterScreenUpdates: false)
            snapshotView?.transform = transform
            superview?.superview?.addSubview(snapshotView!)
            didCellRemoveFromSuperviewWithDirection(direction: .left)
            
            let endCenterX = -(UIScreen.width * 0.5 + frame.size.width)
            UIView.animate(withDuration: 0.25) {
                var center = self.center
                center.x = endCenterX
                snapshotView?.center = center
            } completion: { _ in
                snapshotView?.removeFromSuperview()
            }
        }else {
            restoreCellLocation()
        }
    }
    
    private func restoreCellLocation() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: .curveEaseOut) {
            self.transform = .identity
        } completion: { _ in
            
        }
    }
    
    private func didCellRemoveFromSuperviewWithDirection(direction: CardCellSwipeDirection) {
        
        transform = .identity
        removeFromSuperview()
        cell_delegate?.cardViewCellDidRemoveFromSuperView(cell: self, direction: direction)
    }
    
}

