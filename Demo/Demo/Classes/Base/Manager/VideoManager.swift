//
//  VideoManager.swift
//  Example
//
//  Created by QuintGao on 2023/9/25.
//  Copyright © 2023 QuintGao. All rights reserved.
//

import UIKit
import GKScrollView

class VideoManager: NSObject {
    lazy var portraitScrollView: GKScrollView = {
        let scrollView = GKScrollView()
        scrollView.gk_dataSource = self
        scrollView.gk_delegate = self
        scrollView.register(cellClass: VideoPortraitCell.self, forCellReuseIdentifier: "GKVideoPortraitCell")
        return scrollView
    }()
    
    var landscapeScrollView: GKScrollView?
    
    var dataSource: [VideoInfo] = []
    
    var currentCell: VideoCell?
    var currentIndex: Int = 0
    var landscapeCell: VideoLandscapeCell?
    var isFullScreen: Bool = false
    var viewController: VideoPlayerViewController?
    
    override init() {
        super.init()
        
        initPlayer()
    }
    
    // MARK: - Public
    public func initPlayer() {
        
    }
    
    public func initLandscapeView() {
        landscapeScrollView = GKScrollView()
        landscapeScrollView?.backgroundColor = .black
        landscapeScrollView?.gk_dataSource = self
        landscapeScrollView?.gk_delegate = self
        landscapeScrollView?.register(cellClass: VideoLandscapeCell.self, forCellReuseIdentifier: "GKVideoLandscapeCell")
    }
    
    public func destoryPlayer() {
        
    }
    
    public func prepare(cell: VideoCell, forIndex index: Int) {
        
    }
    
    public func preloadVideo(cell: VideoCell, forIndex index: Int) {
        
    }
    
    public func playVideo(cell: VideoCell, forIndex index: Int) {
        
    }
    
    public func stopVideo(cell: VideoCell, forIndex index: Int) {
        
    }
    
    public func enterFullScreen() {
        
    }
    
    public func back() {
        
    }
    
    public func reloadData() {
        portraitScrollView.reloadData()
        landscapeScrollView?.reloadData()
    }
    
    public func reloadData(with index: Int) {
        portraitScrollView.reloadData(with: index)
        landscapeScrollView?.reloadData(with: index)
    }
    
    public func likeVideo(model: VideoInfo?) {
        var model = model
        if model == nil {
            model = dataSource[portraitScrollView.currentIndex]
            model?.isLike = true
        }
        portraitScrollView.reloadData()
        landscapeScrollView?.reloadData()
    }
    
    public func removeCurrent() {
        portraitScrollView.removeCurrentCell(animated: true)
    }
}

extension VideoManager: GKScrollViewDataSource, GKScrollViewDelegate {
    // MARK: - GKScrollViewDataSource
    func numberOfRows(in scrollView: GKScrollView) -> Int {
        dataSource.count
    }
    
    func scrollView(_ scrollView: GKScrollView, cellForRowAt indexPath: IndexPath) -> GKScrollViewCell {
        let identifier = scrollView == portraitScrollView ? "GKVideoPortraitCell" : "GKVideoLandscapeCell"
        let cell = scrollView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! VideoCell
        cell.loadData(model: dataSource[indexPath.row])
        cell.delegate = self
        prepare(cell: cell, forIndex: indexPath.row)
        return cell
    }
    
    // MARK: - GKScrollViewDelegate
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        currentCell?.scrollViewBeginDragging()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        currentCell?.scrollViewDidEndDragging()
    }
    
    // 即将显示
    func scrollView(_ scrollView: GKScrollView, willDisplay cell: GKScrollViewCell, forRowAt indexPath: IndexPath) {
        preloadVideo(cell: cell as! VideoCell, forIndex: indexPath.row)
    }
    
    // 结束显示
    func scrollView(_ scrollView: GKScrollView, didEndDisplaying cell: GKScrollViewCell, forRowAt indexPath: IndexPath) {
        stopVideo(cell: cell as! VideoCell, forIndex: indexPath.row)
    }
    
    // 滑动结束显示
    func scrollView(_ scrollView: GKScrollView, didEndScrolling cell: GKScrollViewCell, forRowAt indexPath: IndexPath) {
        if scrollView == portraitScrollView {
            currentCell = cell as? VideoCell
            currentIndex = indexPath.row
        }else if scrollView == landscapeScrollView {
            landscapeCell = cell as? VideoLandscapeCell
        }
        playVideo(cell: cell as! VideoCell, forIndex: indexPath.row)
    }
    
    func scrollView(_ scrollView: GKScrollView, didRemoveCell cell: GKScrollViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= 0 && indexPath.row < dataSource.count {
            dataSource.remove(at: indexPath.row)
        }
    }
}

extension VideoManager: VideoCellDelegate {
    func cellClickBackBtn() {
        back()
    }
    
    func cellClickLikeBtn(cell: VideoCell) {
        
    }
    
    func cellClickFullscreenBtn(cell: VideoCell) {
        enterFullScreen()
    }
}
