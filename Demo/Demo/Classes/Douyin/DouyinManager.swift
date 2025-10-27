//
//  DouyinManager.swift
//  Example
//
//  Created by QuintGao on 2023/10/11.
//  Copyright © 2023 QuintGao. All rights reserved.
//

import UIKit
import SJVideoPlayer

let DouyinPortraitIdentifier: SJControlLayerIdentifier = 101
let DouyinLandscapeIdentifier: SJControlLayerIdentifier = 102

class DouyinManager: VideoManager {
    var player: SJVideoPlayer?
    
    var portraitView: DouyinPortraitView?
    var landscapeView: DouyinLandscapeView?
    
    var rotationManager: GKRotationManager?
    
    override func initPlayer() {
        let player = SJVideoPlayer()
        self.player = player
        
        player.view.backgroundColor = .black
        player.presentView.backgroundColor = .black
        player.controlLayerAppearManager.isDisabled = true
        player.presentView.placeholderImageViewContentMode = .scaleAspectFit
        player.videoGravity = .resizeAspect
        player.autoplayWhenSetNewAsset = false
        player.rotationManager?.isDisabledAutorotation = true
        player.isPausedInBackground = true
        player.resumePlaybackWhenScrollAppeared = false
        player.resumePlaybackWhenAppDidEnterForeground = false
        player.automaticallyHidesPlaceholderImageView = true
        player.gestureController.supportedGestureTypes = [.singleTap, .doubleTap]
        player.switcher.addControlLayer(forIdentifier: DouyinPortraitIdentifier) { identifier in
            return DouyinPortraitView(frame: UIScreen.main.bounds)
        }
        player.switcher.addControlLayer(forIdentifier: DouyinLandscapeIdentifier) { identifier in
            return DouyinLandscapeView(frame: UIScreen.main.bounds)
        }
        portraitView = player.switcher.controlLayer(forIdentifier: DouyinPortraitIdentifier) as? DouyinPortraitView
        landscapeView = player.switcher.controlLayer(forIdentifier: DouyinLandscapeIdentifier) as? DouyinLandscapeView
        player.switcher.switchControlLayer(forIdentifier: DouyinPortraitIdentifier)
        
        portraitView?.likeBlock = { [weak self] in
            guard let self = self else { return }
            self.likeVideo(model: nil)
        }
        
        landscapeView?.likeBlock = { [weak self] model in
            guard let self = self else { return }
            self.likeVideo(model: model)
        }
        
        landscapeView?.singleTapBlock = { [weak self] in
            guard let self = self else { return }
            guard let landscapeCell = self.landscapeCell else { return }
            if landscapeCell.isShowTop {
                landscapeCell.hideTopView()
                self.landscapeView?.hideContainerView(animated: false)
            }else {
                self.landscapeView?.autoHide()
            }
        }
        
        // 播放结束回调
        player.playbackObserver.playbackDidFinishExeBlock = { [weak self] player in
            guard let self = self else { return }
            self.player?.replay()
        }
        
        // 加载状态改变回调
        player.playbackObserver.timeControlStatusDidChangeExeBlock = { [weak self] player in
            guard let self = self else { return }
            if player.timeControlStatus == .waitingToPlay {
                self.currentCell?.showLoading()
            }else {
                self.currentCell?.hideLoading()
            }
        }
        
        // 播放进度回调
        player.playbackObserver.currentTimeDidChangeExeBlock = { [weak self] player in
            guard let self = self else { return }
            let progress = player.duration == 0 ? 0 : player.currentTime / player.duration
            self.currentCell?.setProgress(Float(progress))
        }
        
        // 旋转
        self.rotationManager = GKRotationManager.manager
        rotationManager?.contentView = player.view
        landscapeView?.rotationManager = rotationManager
        
        rotationManager?.orientationWillChange = { [weak self] isFullScreen in
            guard let self = self else { return }
            if isFullScreen {
                self.landscapeView?.statusBar.startTimer()
            }else {
                self.landscapeView?.statusBar.destoryTimer()
                self.landscapeView?.isHidden = true
                if let landscapeScrollView = self.landscapeScrollView {
                    let superview = landscapeScrollView.superview
                    superview?.addSubview((rotationManager?.contentView)!)
                    landscapeScrollView.removeFromSuperview()
                    self.landscapeScrollView = nil
                    self.landscapeCell = nil
                }
            }
        }
        
        rotationManager?.orientationDidChanged = { [weak self] isFullScreen in
            guard let self = self else { return }
            if isFullScreen {
                self.portraitView?.isHidden = true
                self.landscapeView?.isHidden = false
                self.landscapeView?.hideContainerView(animated: false)
                if self.landscapeScrollView == nil {
                    self.initLandscapeView()
                    let superview = self.rotationManager?.contentView?.superview
                    self.landscapeScrollView?.frame = superview?.bounds ?? .zero
                    superview?.addSubview(self.landscapeScrollView!)
                    self.landscapeScrollView?.defaultIndex = self.portraitScrollView.currentIndex
                    self.landscapeScrollView?.reloadData()
                }
                self.player?.switcher.switchControlLayer(forIdentifier: DouyinLandscapeIdentifier)
                self.landscapeCell?.hideTopView()
            }else {
                self.portraitView?.isHidden = false
                self.landscapeView?.isHidden = true
                self.player?.switcher.switchControlLayer(forIdentifier: DouyinPortraitIdentifier)
            }
        }
    }
    
    override func destoryPlayer() {
        player?.stop()
        player = nil
    }
    
    override func prepare(cell: VideoCell, forIndex index: Int) {
        if let videoCell = cell as? VideoLandscapeCell {
            videoCell.showTopView()
        }
    }
    
    override func playVideo(cell: VideoCell, forIndex index: Int) {
        let model = dataSource[index]
        
        landscapeView?.loadData(model: model)
        
        if let cell = cell as? VideoPortraitCell {
            rotationManager?.containerView = cell.coverImgView
            if rotationManager?.isFullScreen == true { return }
        }else {
            if let cell = cell as? VideoLandscapeCell {
                cell.autoHide()
            }
            portraitScrollView.scrollToCell(with: index)
        }
        
        // 设置播放内容视图
        if let view = player?.view, view.superview != cell.coverImgView {
            view.frame = cell.coverImgView.bounds
            cell.coverImgView.addSubview(view)
        }
        
        // 设置视频封面图
        player?.presentView.placeholderImageView.kf.setImage(with: URL(string: model.poster_small))
        player?.presentView.isHidden = false
        
        // 播放内容一致，不做处理
        if let url = player?.urlAsset?.mediaURL?.absoluteString, !url.isEmpty, url == model.play_url {
            return
        }
        
        // 设置播放地址
        let asset = SJVideoPlayerURLAsset(url: URL(string: model.play_url)!)
        player?.urlAsset = asset
        player?.play()
        portraitView?.playBtn.isHidden = true
    }
    
    override func stopVideo(cell: VideoCell, forIndex index: Int) {
        let model = dataSource[index]
        
        // 判断播放内容是否一致
        if let url = player?.urlAsset?.mediaURL?.absoluteString, !url.isEmpty, url != model.play_url {
            return
        }
        
        player?.stop()
        player?.presentView.isHidden = true
        cell.resetView()
        landscapeView?.hideContainerView(animated: false)
    }
    
    override func enterFullScreen() {
        rotationManager?.rotate()
    }
    
    override func back() {
        rotationManager?.rotate()
    }
}
