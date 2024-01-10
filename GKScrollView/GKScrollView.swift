//
//  GKScrollView.swift
//  GKScrollView
//
//  Created by QuintGao on 2023/8/17.
//

import UIKit

private enum GKScrollViewCellUpdateType {
    case top
    case center
    case bottom
}

@objc public protocol GKScrollViewDataSource: NSObjectProtocol {
    
    func numberOfRows(in scrollView: GKScrollView) -> Int
    
    func scrollView(_ scrollView: GKScrollView, cellForRowAt indexPath: IndexPath) -> GKScrollViewCell
}

@objc public protocol GKScrollViewDelegate: UIScrollViewDelegate {
    
    @objc optional func scrollView(_ scrollView: GKScrollView, willDisplay cell: GKScrollViewCell, forRowAt indexPath: IndexPath)
    
    @objc optional func scrollView(_ scrollView: GKScrollView, didEndDisplaying cell: GKScrollViewCell, forRowAt indexPath: IndexPath)
    
    @objc optional func scrollView(_ scrollView: GKScrollView, didEndScrolling cell: GKScrollViewCell, forRowAt indexPath: IndexPath)
    
    @objc optional func scrollView(_ scrollView: GKScrollView, didRemoveCell cell: GKScrollViewCell, forRowAt indexPath: IndexPath)
}

open class GKScrollView: UIScrollView {
    
    open weak var gk_dataSource: GKScrollViewDataSource?
    
    open weak var gk_delegate: GKScrollViewDelegate?
    
    // 默认索引
    public var defaultIndex: Int = 0
    
    // 当前索引
    public private(set) var currentIndex: Int = 0
    
    // 当前显示的cell
    public private(set) var currentCell: GKScrollViewCell?
    
    private var topCell: GKScrollViewCell?
    private var ctrCell: GKScrollViewCell?
    private var btmCell: GKScrollViewCell?
    
    // 控制播放的索引，不完全等于当前播放内容的索引
    private var index: Int = 0
    
    // 将要改变的索引
    private var changeIndex: Int = 0
    
    // 内容总数
    private var totalCount: Int = 0
    
    // 记录是否刷新过
    private var isLoaded: Bool = false
    
    // 处理上拉加载回弹问题
    private var lastCount: Int = 0
    private var isDelay: Bool = false
    
    // 当前正在更新的cell
    private var updateCell: GKScrollViewCell?
    
    // 处理cell即将显示
    private var lastOffsetY: CGFloat = 0
    private var lastWillDisplayCell: GKScrollViewCell?
    private var lastEndDisplayCell: GKScrollViewCell?
    
    // 记录是否正在切换页面
    private var isChanging: Bool = false
    
    // 记录是否正在切换下一个
    private var isChangeToNext: Bool = false
    
    // 记录是否正在改变位置
    private var isChangeOffset: Bool = false
    
    // 移除cell
    private var willRemoveCell: GKScrollViewCell?
    private var willRemoveIndex: Int = 0
    
    // 存放cell标识和对于的nib
    private var cellNibs: [String: UINib] = [:]
    
    // 存放cell标识和对于的类（包括nib对于的类）
    private var cellClasses: [String: AnyClass] = [:]
    
    // 存放cell标识和对于的可重用cell列表
    private var reusableCells: [String: NSMutableSet] = [:]
    
    // 可视cells
    public var visibleCells: [GKScrollViewCell]? {
        if currentCell == nil { return nil }
        return [currentCell!]
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initialize()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let scrollW = CGRectGetWidth(frame)
        let scrollH = CGRectGetHeight(frame)
        
        topCell?.frame = CGRectMake(0, 0, scrollW, scrollH)
        ctrCell?.frame = CGRectMake(0, scrollH, scrollW, scrollH)
        btmCell?.frame = CGRectMake(0, scrollH * 2, scrollW, scrollH)
        
        if contentSize == .zero || contentSize.width != scrollW {
            updateContentSize()
            updateContentOffset()
        }
    }
    
    private func initialize() {
        delegate = self
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        backgroundColor = .clear
        isPagingEnabled = true
        scrollsToTop = false
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
        initValue()
    }
    
    private func initValue() {
        saveReusable(cell: topCell)
        saveReusable(cell: ctrCell)
        saveReusable(cell: btmCell)
        saveReusable(cell: willRemoveCell)
        topCell = nil
        ctrCell = nil
        btmCell = nil
        updateCell = nil
        lastWillDisplayCell = nil
        lastEndDisplayCell = nil
        updateContentSize(size: .zero)
        updateContentOffset(offset: .zero)
        defaultIndex = 0
        isLoaded = false
        currentIndex = 0
        changeIndex = 0
        lastCount = 0
        index = 0
        isChanging = false
        isChangeOffset = false
        isChangeToNext = false
        willRemoveCell = nil
        willRemoveIndex = 0
    }
    
    public func numberOfRows() -> Int {
        totalCount
    }
    
    public func indexPath(for cell: GKScrollViewCell) -> IndexPath? {
        var index: Int = NSNotFound
        var diff: Int = NSNotFound
        if cell == topCell {
            diff = -1
        }else if cell == ctrCell {
            diff = 0
        }else if cell == btmCell {
            diff = 1
        }
        if diff != NSNotFound {
            if currentCell == topCell {
                index = currentIndex + 1 + diff
            }else if currentCell == ctrCell {
                index = currentIndex + diff
            }else if currentCell == btmCell {
                index = currentIndex - 1 + diff
            }
        }
        if index != NSNotFound {
            return IndexPath(row: index, section: 0)
        }
        return nil
    }
    
    public func cell(forRowAt indexPath: IndexPath) -> GKScrollViewCell? {
        let index = indexPath.row
        if index < 0 || index > totalCount - 1 { return nil }
        var diff = currentIndex - index
        if currentIndex == 0 {
            diff += 1
        }else if currentIndex == totalCount - 1 {
            diff -= 1
        }
        
        var cell: GKScrollViewCell? = nil
        if diff == 1 {
            cell = topCell
        }else if diff == 0 {
            cell = ctrCell
        }else if diff == -1 {
            cell = btmCell
        }
        return cell
    }
    
    public func register(nib: UINib, forCellReuseIdentifier identifier: String) {
        if identifier.isEmpty {
            fatalError("must pass a valid reuse identifier to - \(#function)")
        }
        clear(with: identifier)
        cellNibs[identifier] = nib
        reusableCells[identifier] = NSMutableSet()
    }
    
    public func register(cellClass: AnyClass?, forCellReuseIdentifier identifier: String) {
        guard let cellClass = cellClass else {
            fatalError("unable to dequeue a cell with identifier \(identifier) - must register a nib or a class for the identifier or connect a prototype cell in a storyboard")
        }
        if !cellClass.isSubclass(of: GKScrollViewCell.self) {
            fatalError("must pass a class of kind GKScrollViewCell")
        }
        if identifier.isEmpty {
            fatalError("must pass a valid reuse identifier to - \(#function)")
        }
        clear(with: identifier)
        cellClasses[identifier] = cellClass
        reusableCells[identifier] = NSMutableSet()
    }

    public func dequeueReusableCell(withIdentifier identifier: String, for indexPath: IndexPath) -> GKScrollViewCell {
        let cellClass: AnyClass = cellClass(with: identifier)
        var cell: GKScrollViewCell? = nil
        if updateCell == nil || updateCell?.classForCoder != cellClass {
            cell = dequeueReusableCell(with: identifier)
            if updateCell != nil {
                saveReusable(cell: updateCell)
                updateCell = nil
            }
        }else {
            cell = updateCell
            updateCell = nil
        }
        return cell!
    }
    
    public func reloadData() {
        // 总数
        let totalCount = gk_dataSource?.numberOfRows(in: self) ?? 0
        
        // 修复自动刷新时的bug
        let offsetY = contentOffset.y
        if totalCount > self.totalCount && lastCount > 0 && (offsetY == 0 || offsetY == viewHeight || offsetY == 2 * viewHeight) {
            lastCount = 0
        }
        self.totalCount = totalCount
        
        // 特殊场景处理：开始有数据刷新后无数据
        if totalCount <= 0 {
            didEndDisplaying(cell: currentCell, for: currentIndex)
            initValue()
            return
        }
        
        // 索引
        if defaultIndex < 0 || defaultIndex >= totalCount {
            fatalError("please set defaultIndex correctly")
        }
        
        let index = defaultIndex
        defaultIndex = 0
        
        // 加载cell
        if isLoaded {
            createCellIfNeeded()
            updateContentSize()
            updateDisplayCell(false)
        }else {
            isLoaded = true
            self.index = index
            self.currentIndex = index
            self.changeIndex = index
            createCellIfNeeded()
            updateContentSize()
            updateContentOffset()
            updateDisplayCell(true)
        }
    }
    
    public func reloadData(with index: Int) {
        // 总数
        self.totalCount = gk_dataSource?.numberOfRows(in: self) ?? 0
        
        // 特殊场景处理：开始有数据刷新后无数据
        if totalCount <= 0 {
            didEndDisplaying(cell: currentCell, for: currentIndex)
            initValue()
            return
        }
        
        self.index = index
        self.currentIndex = index
        self.changeIndex = index
        createCellIfNeeded()
        updateContentSize()
        updateContentOffset()
        updateDisplayCell(true)
    }
    
    public func scrollToCell(with index: Int) {
        if index < 0 || index > totalCount - 1 { return }
        if currentIndex == index { return }
        if isChanging { return }
        isChanging = true
        self.index = index
        self.changeIndex = index
        
        // 更新cell
        var type: GKScrollViewCellUpdateType = .top
        if totalCount >= 3 {
            if index == 0 {
                type = .top
            }else if index == totalCount - 1 {
                type = .bottom
            }else {
                type = .center
            }
            createCell(type: type, index: index)
        }
        
        // 显示cell
        updateDisplayCell(index: index)
        isChanging = false
    }
    
    public func scrollToLastCell() {
        // 当前是第一个，不做处理
        if currentIndex == 0 { return }
        if isChangeToNext { return }
        changeIndex = currentIndex - 1
        // 即将显示
        var cell: GKScrollViewCell? = nil
        var offsetY: CGFloat = 0
        if currentCell == ctrCell {
            cell = topCell
            offsetY = 0
        }else if currentCell == btmCell {
            cell = ctrCell
            offsetY = viewHeight
        }
        if cell != nil && willRemoveCell == nil {
            willDisplay(cell: cell, for: changeIndex)
            lastWillDisplayCell = nil
        }
        isChangeToNext = true
        setContentOffset(CGPointMake(0, offsetY), animated: true)
    }
    
    public func scrollToNextCell() {
        // 当前是最后一个，不做处理
        if currentIndex == totalCount - 1 { return }
        if isChangeToNext { return }
        changeIndex = currentIndex + 1
        // 即将显示
        var cell: GKScrollViewCell? = nil
        var offsetY: CGFloat = 0
        if currentCell == topCell {
            cell = ctrCell
            offsetY = viewHeight
        }else if currentCell == ctrCell {
            cell = btmCell
            offsetY = 2 * viewHeight
        }
        if cell != nil && willRemoveCell == nil {
            willDisplay(cell: cell, for: changeIndex)
            lastWillDisplayCell = nil
        }
        isChangeToNext = true
        setContentOffset(CGPointMake(0, offsetY), animated: true)
    }
    
    public func removeCurrentCell(animated: Bool) {
        // 记录即将移除的cell和index
        willRemoveCell = currentCell
        willRemoveIndex = currentIndex
        // 结束显示
        didEndDisplaying(cell: willRemoveCell, for: willRemoveIndex)
        if animated {
            if totalCount == 1 {
                removeCurrentCell()
            }else {
                if currentIndex == totalCount - 1 {
                    scrollToLastCell()
                }else {
                    scrollToNextCell()
                }
            }
        }else {
            removeCurrentCell()
        }
    }
    
    private func removeCurrentCell() {
        // 移除
        let selector = NSSelectorFromString("scrollView:didRemoveCell:forRowAt:")
        if let delegate = gk_delegate, delegate.responds(to: selector) {
            let indexPath = IndexPath(row: willRemoveIndex, section: 0)
            delegate.scrollView?(self, didRemoveCell: willRemoveCell!, forRowAt: indexPath)
        }else {
            fatalError("when using the `removeCurrentCell` method, you must implement the `scrollView:didRemoveCell:forRowAt` protocol and remove the data for index")
        }
        if topCell == willRemoveCell { topCell = nil }
        if ctrCell == willRemoveCell { ctrCell = nil }
        if btmCell == willRemoveCell { btmCell = nil }
        
        // 刷新
        totalCount = gk_dataSource?.numberOfRows(in: self) ?? 0
        if totalCount <= 0 {
            didEndDisplaying(cell: currentCell, for: currentIndex)
            initValue()
            return
        }
        
        if currentIndex >= totalCount {
            currentIndex = totalCount - 1
        }
        changeIndex = currentIndex
        reloadData()
        updateContentOffset()
    }
    
    // MARK - Private
    private func clear(with identifier: String) {
        if cellNibs.keys.contains(identifier) {
            cellNibs.removeValue(forKey: identifier)
        }
        if cellClasses.keys.contains(identifier) {
            cellClasses.removeValue(forKey: identifier)
        }
        if reusableCells.keys.contains(identifier) {
            reusableCells.removeValue(forKey: identifier)
        }
    }
    
    private func cellClass(with identifier: String) -> AnyClass {
        // 标识未注册
        if !cellNibs.keys.contains(identifier) && !cellClasses.keys.contains(identifier) {
            fatalError("unable to dequeue a cell with identifier \(identifier) - must register a nib or a class for the identifier or connect a prototype cell in a storyboard")
        }
        // 如果获取过class，直接返回
        if cellClasses.keys.contains(identifier) {
            return cellClasses[identifier]!
        }
        // 通过nib获取cell
        let nib = cellNibs[identifier]!
        let nibCell = cell(with: nib, identifier: identifier)
        // 放入重用池
        saveReusable(cell: nibCell)
        // 存储class
        let cls: AnyClass = nibCell.classForCoder
        cellClasses[identifier] = cls
        return cls
    }
    
    private func cell(with nib: UINib, identifier: String) -> GKScrollViewCell {
        let views = nib.instantiate(withOwner: self, options: nil)
        // 只能存放一个cell且必须是GKScrollViewCell或其子类
        if let nibCell = views.first as? GKScrollViewCell, views.count == 1 {
            if let reuseIdentifier = nibCell.reuseIdentifier, reuseIdentifier != identifier {
                // 重用标识不一致
                fatalError("cell reuse identifier in nib (\(reuseIdentifier) does not match the identifier used to register the nib (\(identifier)")
            }else {
                if nibCell.reuseIdentifier == "" || nibCell.reuseIdentifier == nil {
                    nibCell.setValue(identifier, forKey: "reuseIdentifier")
                }
                return nibCell
            }
        }else {
            fatalError("invalid nib registered for identifier (\(identifier) - nib must contain exactly one top level object which must be a GKScrollViewCell instance")
        }
    }
    
    private func dequeueReusableCell(with identifier: String) -> GKScrollViewCell? {
        guard let cells = reusableCells[identifier] else { return nil }
        var cell = cells.anyObject() as? GKScrollViewCell
        if cell != nil {
            UIView.performWithoutAnimation {
                cell?.prepareForReuse()
            }
            cells.remove(cell as Any)
        }else {
            if cellNibs.keys.contains(identifier) {
                if let nib = cellNibs[identifier] {
                    cell = self.cell(with: nib, identifier: identifier)
                }
            }else {
                let cls: AnyClass? = cellClasses[identifier]
                guard let typeCls = cls as? GKScrollViewCell.Type else { return nil }
                cell = typeCls.init(reuseIdentifier: identifier)
            }
        }
        return cell
    }
    
    private func saveReusable(cell: GKScrollViewCell?) {
        guard let cell = cell else { return }
        guard let identifier = cell.reuseIdentifier else { return }
        guard let cells = reusableCells[identifier] else { return }
        var exist: Bool = false
        cells.forEach {
            if cell == $0 as? GKScrollViewCell {
                exist = true
            }
        }
        if !exist {
            cells.add(cell)
        }
        cell.removeFromSuperview()
        reusableCells[identifier] = cells
    }
    
    // MARK - create and update cell
    private func createCellIfNeeded() {
        var type: GKScrollViewCellUpdateType = .top
        let index: Int = changeIndex
        if totalCount >= 3 {
            if index == 0 {
                type = .top
            }else if index == totalCount - 1 {
                type = .bottom
            }else {
                type = .center
                if currentCell != nil && currentCell == btmCell {
                    if contentOffset.y > 2 * viewHeight { return }
                    updateContentOffset()
                    updateUpScrollCell(index: index)
                }
            }
        }
        createCell(type: type, index: index)
    }
    
    private func createCell(type: GKScrollViewCellUpdateType, index: Int) {
        if type == .top {
            createTopCell(index: 0)
            if totalCount > 1 {
                createCtrCell(index: 1)
            }
            if btmCell != nil && changeIndex == currentIndex {
                saveReusable(cell: btmCell)
                btmCell = nil
            }
        }else if type == .center {
            if contentOffset.y > 2 * viewHeight {
                createTopCell(index: index - 2)
                createCtrCell(index: index - 1)
                createBtmCell(index: index)
            }else {
                createTopCell(index: index - 1)
                createCtrCell(index: index)
                createBtmCell(index: index + 1)
            }
        }else if type == .bottom {
            if topCell != nil {
                saveReusable(cell: topCell)
                topCell = nil
            }
            createCtrCell(index: index - 1)
            createBtmCell(index: index)
        }
        updateLayout()
    }
    
    private func updateDisplayCell(_ isFirstLoad: Bool) {
        var cell: GKScrollViewCell? = nil
        if totalCount == 1 {
            cell = topCell
        }else if totalCount == 2 {
            cell = currentIndex == 0 ? topCell : ctrCell
        }else {
            if currentIndex == 0 {
                cell = topCell
            }else if currentIndex == totalCount - 1 {
                cell = btmCell
            }else {
                cell = ctrCell
            }
        }
        if isFirstLoad || willRemoveCell != nil {
            saveReusable(cell: willRemoveCell)
            willRemoveCell = nil
            willRemoveIndex = 0
            
            willDisplay(cell: cell, for: currentIndex)
            lastWillDisplayCell = nil
            
            didEndScrolling(cell: cell)
        }else {
            if isDecelerating { return }
            if contentOffset.y > 0 && contentOffset.y != 2 * viewHeight { return }
            didEndScrolling(cell: cell)
        }
    }
    
    private func updateDisplayCell(index: Int) {
        let viewH = viewHeight
        var cell: GKScrollViewCell? = nil
        var offsetY: CGFloat = 0
        if totalCount == 1 {
            cell = topCell
            offsetY = 0
        }else if totalCount == 2 {
            cell = index == 0 ? topCell : ctrCell
            offsetY = index == 0 ? 0 : viewH
        }else {
            if index == 0 {
                cell = topCell
                offsetY = 0
            }else if index == totalCount - 1 {
                cell = btmCell
                offsetY = 2 * viewH
            }else {
                cell = ctrCell
                offsetY = viewH
            }
        }
        // 即将显示cell
        willDisplay(cell: cell, for: index)
        lastWillDisplayCell = nil
        
        // 切换位置
        updateContentOffset(offset: CGPointMake(0, offsetY))
        
        // 滑动结束显示
        didEndScrolling(cell: cell)
    }
    
    private func updateContentSize() {
        if totalCount == 0 { return }
        let height = viewHeight * CGFloat(totalCount >= 3 ? 3 : totalCount)
        updateContentSize(size: CGSizeMake(viewWidth, height))
    }
    
    private func updateContentOffset() {
        let viewH = viewHeight
        var offsetY: CGFloat = 0
        if totalCount == 0 {
            offsetY = 0
        }else if totalCount == 1 || totalCount == 2 {
            offsetY = currentIndex == 0 ? 0 : viewH
        }else {
            if currentIndex == 0 {
                offsetY = 0
            }else if currentIndex == totalCount - 1 {
                offsetY = 2 * viewH
            }else {
                offsetY = viewH
            }
        }
        updateContentOffset(offset: CGPointMake(0, offsetY))
    }
    
    private func createTopCell(index: Int) {
        if index < 0 || index >= totalCount { return }
        updateCell = topCell
        topCell = cell(for: index)
        addSubview(topCell!)
    }
    
    private func createCtrCell(index: Int) {
        if index < 0 || index >= totalCount { return }
        updateCell = ctrCell
        ctrCell = cell(for: index)
        addSubview(ctrCell!)
    }
    
    private func createBtmCell(index: Int) {
        if index < 0 || index >= totalCount { return }
        updateCell = btmCell
        btmCell = cell(for: index)
        addSubview(btmCell!)
    }
    
    private func createTopCellIfNeeded(index: Int) {
        if index < 0 || index >= totalCount { return }
        if topCell != nil { return }
        createTopCell(index: index)
        updateLayout()
    }
    
    private func createBtmCellIfNeeded(index: Int) {
        if index < 0 || index >= totalCount { return }
        if btmCell != nil { return }
        createBtmCell(index: index)
        updateLayout()
    }
    
    // 上滑cell
    private func updateUpScrollCell(index: Int) {
        if index < 1 || index > totalCount - 2 { return }
        // 上视图放入重用池
        saveReusable(cell: topCell)
        // 中视图切换为上视图
        topCell = ctrCell
        // 下视图切换为中视图
        ctrCell = btmCell
        // 更新下视图
        btmCell = cell(for: index + 1)
        addSubview(btmCell!)
        updateLayout()
    }
    
    // 下滑cell
    private func updateDownScrollCell(index: Int) {
        if index < 1 || index > totalCount - 2 { return }
        // 下视图放入重用池
        saveReusable(cell: btmCell)
        // 中视图切换为下视图
        btmCell = ctrCell
        // 上视图切换为中视图
        ctrCell = topCell
        // 更新上视图
        topCell = cell(for: index - 1)
        addSubview(topCell!)
        updateLayout()
    }
    
    private func cell(for index: Int) -> GKScrollViewCell? {
        if index < 0 || index >= totalCount { return nil }
        let indexPath = IndexPath(row: index, section: 0)
        return gk_dataSource?.scrollView(self, cellForRowAt: indexPath)
    }
    
    // MARK - DisplayCell
    // 延迟更新cell，处理上拉加载更多后的回弹问题
    private func delayUpdateCell(index: Int) {
        if isDelay { return }
        isDelay = true
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.4) {
            self.isDelay = false
            self.lastCount = 0
            if index != NSNotFound {
                self.index = index
                self.updateContentOffset(offset: CGPointMake(0, self.viewHeight))
                self.updateUpScrollCell(index: self.index)
                self.didEndScrolling(cell: self.ctrCell)
            }else {
                self.didEndScrolling(cell: self.currentCell)
            }
        }
    }
    
    private func handleWillDisplayCell() {
        if !isDragging { return }
        if willRemoveCell != nil { return }
        let offsetY = contentOffset.y
        if offsetY < lastOffsetY { // 下拉
            if offsetY < 0 { return } // 第一个cell下拉
            if offsetY > 2 * viewHeight { return } // 显示footer时下拉
            let index = currentIndex - 1
            if currentCell == ctrCell && (offsetY > 0 && offsetY < viewHeight) {
                willDisplay(cell: topCell, for: index)
            }else if currentCell == btmCell && (offsetY > viewHeight) {
                willDisplay(cell: ctrCell, for: index)
                createTopCellIfNeeded(index: index - 1)
            }
        }else if offsetY > lastOffsetY { // 上拉
            if offsetY > 2 * viewHeight { return } // 最后一个cell上拉
            let index = currentIndex + 1
            if currentCell == topCell && (offsetY > 0 && offsetY < viewHeight) {
                willDisplay(cell: ctrCell, for: index)
                createBtmCellIfNeeded(index: index + 1)
            }else if currentCell == ctrCell && (offsetY > viewHeight) {
                willDisplay(cell: btmCell, for: index)
            }
        }
    }
    
    private func willDisplay(cell: GKScrollViewCell?, for index: Int) {
        if index < 0 || index >= totalCount { return }
        if cell == nil { return }
        if lastWillDisplayCell == cell { return }
        lastWillDisplayCell = cell
        let indexPath = IndexPath(row: index, section: 0)
        gk_delegate?.scrollView?(self, willDisplay: cell!, forRowAt: indexPath)
    }
    
    private func didEndDisplaying(cell: GKScrollViewCell?, for index: Int) {
        if index < 0 || index >= totalCount { return }
        if cell == nil { return }
        if lastEndDisplayCell == cell { return }
        lastEndDisplayCell = cell
        let indexPath = IndexPath(row: index, section: 0)
        gk_delegate?.scrollView?(self, didEndDisplaying: cell!, forRowAt: indexPath)
    }
    
    private func didEndScrolling(cell: GKScrollViewCell?, for index: Int) {
        if index < 0 || index >= totalCount { return }
        if cell == nil { return }
        let indexPath = IndexPath(row: index, section: 0)
        gk_delegate?.scrollView?(self, didEndScrolling: cell!, forRowAt: indexPath)
    }
    
    private func didEndScrolling(cell: GKScrollViewCell?) {
        if changeIndex < 0 {
            changeIndex = 0
        }else if changeIndex >= totalCount {
            changeIndex = totalCount - 1
        }
        
        // 快速滑动处理
        if cell != nil && lastWillDisplayCell != nil && willRemoveCell == nil {
            if cell != lastWillDisplayCell && currentIndex != changeIndex {
                willDisplay(cell: cell, for: changeIndex)
            }
        }
        // 清空上一次将要显示的cell，保证下一次正常显示
        lastWillDisplayCell = nil
        lastEndDisplayCell = nil
        
        // 隐藏cell
        if currentIndex != changeIndex && willRemoveCell == nil {
            if totalCount <= 3 || isChanging || currentIndex == 0 || currentIndex == totalCount - 1 {
                didEndDisplaying(cell: currentCell, for: currentIndex)
                lastEndDisplayCell = nil
            }
        }
        
        // 显示新的cell
        currentCell = cell
        currentIndex = changeIndex
        
        if willRemoveCell != nil {
            handleRemoveCell()
        }
        
        // 更新滑动结束时显示的cell
        didEndScrolling(cell: cell, for: currentIndex)
    }
    
    private func handleRemoveCell() {
        // 移除代理
        let selector = NSSelectorFromString("scrollView:didRemoveCell:forRowAt:")
        if let delegate = gk_delegate, delegate.responds(to: selector) {
            let indexPath = IndexPath(row: willRemoveIndex, section: 0)
            delegate.scrollView?(self, didRemoveCell: willRemoveCell!, forRowAt: indexPath)
        }else {
            fatalError("when using the `removeCurrentCell` method, you must implement the `scrollView:didRemoveCell:forRowAt` protocol and remove the data for index")
        }
        
        // 重新获取
        totalCount = gk_dataSource?.numberOfRows(in: self) ?? 0
        if totalCount <= 0 {
            didEndDisplaying(cell: currentCell, for: currentIndex)
            initValue()
            return
        }
        
        // 显示cell
        if currentIndex == totalCount {
            currentIndex = totalCount - 1
        }else {
            currentIndex = willRemoveIndex
        }
        changeIndex = currentIndex
        saveReusable(cell: willRemoveCell)
        willRemoveCell = nil
        willRemoveIndex = 0
        
        // 即将显示
        willDisplay(cell: currentCell, for: currentIndex)
        
        if topCell != currentCell {
            saveReusable(cell: topCell)
        }
        topCell = nil
        
        if ctrCell != currentCell {
            saveReusable(cell: ctrCell)
        }
        ctrCell = nil
        
        if btmCell != currentCell {
            saveReusable(cell: btmCell)
        }
        btmCell = nil
        
        if totalCount == 1 {
            topCell = currentCell
            index = 0
        }else if totalCount == 2 {
            if currentIndex == 0 {
                topCell = currentCell
                createCtrCell(index: currentIndex+1)
                index = 0
            }else {
                ctrCell = currentCell
                createTopCell(index: currentIndex-1)
            }
        }else {
            if currentIndex == 0 {
                topCell = currentCell
                createCtrCell(index: currentIndex+1)
                createBtmCell(index: currentIndex+2)
                index = 0
            }else if currentIndex == totalCount - 1 {
                btmCell = currentCell
                createTopCell(index: currentIndex-2)
                createCtrCell(index: currentIndex-1)
            }else {
                ctrCell = currentCell
                createTopCell(index: currentIndex-1)
                createBtmCell(index: currentIndex+1)
            }
        }
        updateLayout()
        updateContentSize()
        updateContentOffset()
    }
    
    
    // MARK - Update view
    private var viewWidth: CGFloat {
        bounds.size.width
    }
    
    private var viewHeight: CGFloat {
        bounds.size.height
    }
    
    private func updateContentSize(size: CGSize) {
        if contentSize == size { return }
        isChangeOffset = true
        contentSize = size
    }
    
    private func updateContentOffset(offset: CGPoint) {
        if contentOffset == offset { return }
        isChangeOffset = true
        contentOffset = offset
    }
    
    private func updateLayout() {
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func fixContentOffsetY(offsetY: CGFloat) -> CGFloat {
        var newOffsetY = offsetY
        let viewH = viewHeight
        
        var diff = fabs(offsetY - 0)
        if diff > 0 && diff < 1 {
            newOffsetY = 0
            updateContentOffset(offset: .zero)
        }
        
        diff = fabs(offsetY - viewH)
        if diff > 0 && diff < 1 {
            newOffsetY = viewH
            updateContentOffset(offset: CGPoint(x: 0, y: viewH))
        }
        
        diff = fabs(offsetY - 2 * viewH)
        if diff > 0 && diff < 1 {
            newOffsetY = 2 * viewH
            updateContentOffset(offset: CGPoint(x: 0, y: 2 * viewH))
        }
        return newOffsetY
    }
}

extension GKScrollView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        gk_delegate?.scrollViewDidScroll?(scrollView)
        if isChanging { return }
        if isChangeOffset {
            isChangeOffset = false
            return
        }
        // 处理cell显示
        handleWillDisplayCell()
        
        let offsetY = scrollView.contentOffset.y
        let viewH = viewHeight
        // 小于等于3个，不用处理
        if totalCount <= 3 {
            if lastCount > 0 && lastCount < totalCount {
                delayUpdateCell(index: NSNotFound)
            }else {
                lastCount = totalCount
            }
            return
        }
        
        // 下滑到第一个
        if index == 0 && offsetY <= viewH {
            changeIndex = 0
            return
        }
        
        // 上滑到最后一个
        if index > 0 && index == totalCount - 1 && offsetY > viewH {
            if lastCount == 0 {
                lastCount = totalCount
            }
            return
        }
        
        // 判断是从中间视图上滑还是下滑
        if offsetY >= 2 * viewH { // 上滑
            if currentCell != btmCell && (isDragging || isDecelerating || isChangeToNext) {
                if isChangeToNext { isChangeToNext = false }
                didEndDisplaying(cell: currentCell, for: currentIndex)
            }
            if index == 0 {
                if lastCount > 0 {
                    delayUpdateCell(index: 2)
                }else {
                    index = 2
                    updateContentOffset(offset: CGPointMake(0, viewH))
                    changeIndex = index
                    updateUpScrollCell(index: index)
                }
            }else {
                if index < totalCount - 1 {
                    index += 1
                    if index == totalCount - 1 {
                        if lastCount > 0 && lastCount < totalCount {
                            delayUpdateCell(index: lastCount - 1)
                        }else {
                            changeIndex = index
                            lastCount = totalCount
                        }
                    }else {
                        if lastCount > 0 && lastCount < totalCount {
                            delayUpdateCell(index: (index == 2 ? 2 : lastCount - 1))
                        }else {
                            if isDelay { return }
                            updateContentOffset(offset: CGPointMake(0, viewH))
                            changeIndex = index
                            updateUpScrollCell(index: index)
                        }
                    }
                }
            }
        }else if offsetY <= 0 { // 下滑
            if currentCell != topCell && (isDragging || isDecelerating || isChangeToNext) {
                if isChangeToNext { isChangeToNext = false }
                didEndDisplaying(cell: currentCell, for: currentIndex)
            }
            lastCount = 0
            if index == 1 {
                index -= 1
                changeIndex = index
                updateDownScrollCell(index: index)
            }else {
                if index == totalCount - 1 {
                    index -= 2
                }else {
                    index -= 1
                }
                updateContentOffset(offset: CGPointMake(0, viewH))
                changeIndex = index
                updateDownScrollCell(index: index)
            }
        }else {
            if lastCount > 0 && lastCount < totalCount {
                delayUpdateCell(index: NSNotFound)
            }
        }
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        gk_delegate?.scrollViewDidZoom?(scrollView)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        gk_delegate?.scrollViewWillBeginDragging?(scrollView)
        lastOffsetY = scrollView.contentOffset.y
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        gk_delegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        gk_delegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        gk_delegate?.scrollViewWillBeginDecelerating?(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        gk_delegate?.scrollViewDidEndDecelerating?(scrollView)
        scrollViewDidEndScrollingAnimation(scrollView)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        gk_delegate?.scrollViewDidEndScrollingAnimation?(scrollView)
        
        if totalCount <= 0 { return }
        isChanging = false
        isChangeOffset = false
        isChangeToNext = false
        
        var offsetY = scrollView.contentOffset.y
        let viewH = viewHeight
        if offsetY > 0 && offsetY < viewH && currentCell != nil && currentCell == topCell && currentIndex == 0 {
            setContentOffset(.zero, animated: true)
            return
        }
        offsetY = fixContentOffsetY(offsetY: offsetY)
        
        if totalCount <= 3 {
            changeIndex = Int(offsetY / viewH + 0.5)
        }
        var cell: GKScrollViewCell? = nil
        if offsetY <= 0 {
            cell = topCell
        }else if offsetY >= viewH && offsetY < 2 * viewH {
            if totalCount > 3 {
                if index == 0 {
                    index += 1
                    changeIndex = index
                }else if index == totalCount - 1 {
                    index -= 1
                    changeIndex = index
                }
            }
            cell = ctrCell
            if offsetY != viewH {
                updateContentOffset(offset: CGPointMake(0, viewH))
            }
        }else if offsetY >= 2 * viewH {
            if !isDelay {
                cell = btmCell
            }
        }
        
        if cell == nil { return }
        didEndScrolling(cell: cell)
        
        if totalCount >= 3 && offsetY == viewH {
            createTopCellIfNeeded(index: currentIndex-1)
            createBtmCellIfNeeded(index: currentIndex+1)
        }
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return gk_delegate?.viewForZooming?(in: scrollView)
    }
    
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        gk_delegate?.scrollViewWillBeginZooming?(scrollView, with: view)
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        gk_delegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
    }
    
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return gk_delegate?.scrollViewShouldScrollToTop?(scrollView) ?? false
    }
    
    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        gk_delegate?.scrollViewDidScrollToTop?(scrollView)
    }
    
    @available(iOS 11.0, *)
    public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        gk_delegate?.scrollViewDidChangeAdjustedContentInset?(scrollView)
    }
}
