//
//  SJPlayerManager.swift
//  Example
//
//  Created by QuintGao on 2023/10/11.
//  Copyright © 2023 QuintGao. All rights reserved.
//

import UIKit
import SJVideoPlayer

let ControlLayerPortraitIdentifier: SJControlLayerIdentifier = 101
let ControlLayerLandscapeIdentifier: SJControlLayerIdentifier = 102

class SJPlayerManager: VideoManager {

    var player: SJVideoPlayer?
    
    var portraitView: SJPortraitView?
    var landscapeView: SJLandscapeView?
    
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
        player.switcher.addControlLayer(forIdentifier: ControlLayerPortraitIdentifier) { identifier in
            return SJPortraitView(frame: UIScreen.main.bounds)
        }
        player.switcher.addControlLayer(forIdentifier: ControlLayerLandscapeIdentifier) { identifier in
            return SJLandscapeView(frame: UIScreen.main.bounds)
        }
        // 默认显示竖屏
        player.switcher.switchControlLayer(forIdentifier: ControlLayerPortraitIdentifier)
        
        self.portraitView = player.switcher.controlLayer(forIdentifier: ControlLayerPortraitIdentifier) as? SJPortraitView
        self.portraitView?.likeBlock = { [weak self] in
            guard let self = self else { return }
            self.likeVideo(model: nil)
        }
        
        self.landscapeView = player.switcher.controlLayer(forIdentifier: ControlLayerLandscapeIdentifier) as? SJLandscapeView
        self.landscapeView?.likeBlock = { [weak self] model in
            guard let self = self else { return }
            self.likeVideo(model: model)
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
        
        // 方向改变回调
        player.rotationObserver.onRotatingChanged = { [weak self] mgr, isRotating in
            guard let self = self else { return }
            if isRotating {
                if mgr.isFullscreen {
                    self.landscapeView?.statusBar.startTimer()
                    self.player?.switcher.switchControlLayer(forIdentifier: ControlLayerLandscapeIdentifier)
                }else {
                    self.landscapeView?.statusBar.destoryTimer()
                    self.player?.switchControlLayer(forIdentifier: ControlLayerPortraitIdentifier)
                }
            }else {
                if mgr.isFullscreen {
                    self.portraitView?.isHidden = true
                    self.landscapeView?.isHidden = false
                }else {
                    self.landscapeView?.isHidden = true
                    self.portraitView?.isHidden = false
                }
            }
        }
    }
    
    override func destoryPlayer() {
        self.player?.stop()
        self.player = nil
    }
    
    // MARK: - Player
    override func playVideo(cell: VideoCell, forIndex index: Int) {
        let model = dataSource[index]
        
        self.landscapeView?.loadData(model: model)
        
        // 设置播放视图
        if let view = player?.view, view.superview != cell.coverImgView {
            view.frame = cell.coverImgView.bounds
            cell.coverImgView.addSubview(view)
        }
        
        // 播放内容一致，不做处理
        if let url = player?.urlAsset?.mediaURL?.absoluteString, url == model.play_url {
            return
        }
        
        // 设置封面图片
        player?.presentView.placeholderImageView.kf.setImage(with: URL(string: model.poster_small))
        player?.presentView.isHidden = false
        
        // 设置播放地址
        let asset = SJVideoPlayerURLAsset(url: URL(string: model.play_url)!)
        player?.urlAsset = asset
        player?.play()
        portraitView?.playBtn.isHidden = true
    }
    
    override func stopVideo(cell: VideoCell, forIndex index: Int) {
        let model = dataSource[index]
        
        if let url = player?.urlAsset?.mediaURL?.absoluteString, url != model.play_url {
            return
        }
        
        player?.stop()
        player?.presentView.isHidden = true
        cell.resetView()
    }
    
    override func enterFullScreen() {
        player?.rotate(.landscapeLeft, animated: true)
    }
}
