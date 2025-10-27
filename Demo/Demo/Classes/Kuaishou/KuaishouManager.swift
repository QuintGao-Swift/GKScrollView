//
//  KuaishouManager.swift
//  Example
//
//  Created by QuintGao on 2023/10/12.
//  Copyright © 2023 QuintGao. All rights reserved.
//

import UIKit
import ZFPlayer
import Kingfisher

class KuaishouManager: VideoManager {
    var player: ZFPlayerController?
    
    lazy var portraitView: KuaishouPortraitView = {
        let portraitView = KuaishouPortraitView(frame: UIScreen.main.bounds)
        portraitView.likeBlock = { [weak self] in
            guard let self = self else { return }
            self.likeVideo(model: nil)
        }
        return portraitView
    }()
    lazy var landscapeView: KuaishouLandscapeView = {
        let landscapelView = KuaishouLandscapeView(frame: UIScreen.main.bounds)
        landscapelView.likeBlock = { [weak self] model in
            guard let self = self else { return }
            self.likeVideo(model: model)
        }
        landscapelView.singleTapBlock = { [weak self] in
            guard let self = self else { return }
            guard let landscapeCell = self.landscapeCell else { return }
            if landscapeCell.isShowTop {
                landscapeCell.hideTopView()
                self.landscapeView.hideContainerView(animated: false)
            }else {
                self.landscapeView.autoHide()
            }
        }
        return landscapelView
    }()
    
    var rotationManager: GKRotationManager?
    
    override func initPlayer() {
        let manager = ZFAVPlayerManager()
        manager.shouldAutoPlay = true
        
        let player = ZFPlayerController()
        player.currentPlayerManager = manager
        player.disableGestureTypes = [.pan, .pinch]
        player.allowOrentitaionRotation = false
        self.player = player
        
        player.controlView = portraitView
        
        player.playerDidToEnd = { [weak self] asset in
            guard let self = self else { return }
            self.player?.currentPlayerManager.replay()
        }
        
        player.playerLoadStateChanged = { [weak self] asset, loadState in
            guard let self = self else { return }
            if (loadState == .prepare || loadState == .stalled) && self.player?.currentPlayerManager.isPlaying == true {
                self.currentCell?.showLoading()
            }else {
                self.currentCell?.hideLoading()
            }
        }
        
        player.playerPlayTimeChanged = { [weak self] asset, currentTime, duration in
            guard let self = self else { return }
            self.currentCell?.setProgress(self.player?.progress ?? 0)
        }
        
        self.rotationManager = GKRotationManager.manager
        self.rotationManager?.contentView = self.player?.currentPlayerManager.view
        self.landscapeView.rotationManager = self.rotationManager
        
        self.rotationManager?.orientationWillChange = { [weak self] isFullScreen in
            guard let self = self else { return }
            if isFullScreen {
                self.landscapeView.statusBar.startTimer()
            }else {
                self.landscapeView.statusBar.destoryTimer()
                self.landscapeView.isHidden = true
                if let landscapeScrollView = self.landscapeScrollView {
                    let superview = landscapeScrollView.superview
                    superview?.addSubview((self.rotationManager?.contentView)!)
                    landscapeScrollView.removeFromSuperview()
                    self.landscapeScrollView = nil
                    self.landscapeCell = nil
                }
            }
        }
        
        self.rotationManager?.orientationDidChanged = { [weak self] isFullScreen in
            guard let self = self else { return }
            if isFullScreen {
                self.portraitView.isHidden = true
                self.landscapeView.isHidden = false
                self.landscapeView.hideContainerView(animated: false)
                if self.landscapeScrollView == nil {
                    self.initLandscapeView()
                    let superview = self.rotationManager?.contentView?.superview
                    self.landscapeScrollView?.frame = superview?.bounds ?? .zero
                    superview?.addSubview(self.landscapeScrollView!)
                    self.landscapeScrollView?.defaultIndex = self.portraitScrollView.currentIndex
                    self.landscapeScrollView?.reloadData()
                }
            }else {
                self.portraitView.isHidden = false
                self.landscapeView.isHidden = true
                self.player?.controlView = self.portraitView
                if self.player?.containerView != self.currentCell?.coverImgView {
                    self.player?.containerView = self.currentCell?.coverImgView
                }
            }
        }
    }
    
    override func destoryPlayer() {
        self.player?.stop()
        self.player = nil
    }
    
    override func prepare(cell: VideoCell, forIndex index: Int) {
        if let cell = cell as? VideoLandscapeCell {
            cell.showTopView()
        }
    }
    
    override func playVideo(cell: VideoCell, forIndex index: Int) {
        let model = dataSource[index]
        landscapeView.loadData(model: model)
        
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
        if player?.containerView != cell.coverImgView {
            player?.containerView = cell.coverImgView
        }
        
        // 设置视频封面图
        if let manager = player?.currentPlayerManager {
            manager.view.coverImageView.kf.setImage(with: URL(string: model.poster_small))
        }
        
        // 播放内容一致，不做处理
        if let url = player?.currentPlayerManager.assetURL?.absoluteString, !url.isEmpty, url == model.play_url {
            return
        }
        
        // 播放
        player?.assetURL = URL(string: model.play_url)
        portraitView.playBtn.isHidden = true
    }
    
    override func stopVideo(cell: VideoCell, forIndex index: Int) {
        let model = dataSource[index]
        
        if let url = player?.currentPlayerManager.assetURL?.absoluteString, !url.isEmpty, url != model.play_url {
            return
        }
        
        player?.stop()
        cell.resetView()
    }
    
    override func enterFullScreen() {
        rotationManager?.rotate()
    }
    
    override func back() {
        rotationManager?.rotate()
    }
    
    
}
