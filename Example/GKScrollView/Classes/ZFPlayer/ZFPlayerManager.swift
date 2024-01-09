//
//  ZFPlayerManager.swift
//  Example
//
//  Created by QuintGao on 2023/9/25.
//  Copyright © 2023 QuintGao. All rights reserved.
//

import UIKit
import ZFPlayer
import Kingfisher

class ZFPlayerManager: VideoManager {
    var player: ZFPlayerController?
    
    lazy var portraitView: ZFPortraitView = {
        let portraitView = ZFPortraitView(frame: UIScreen.main.bounds)
        portraitView.likeBlock = { [weak self] in
            guard let self = self else { return }
            self.likeVideo(model: nil)
        }
        portraitView.longBlock = { [weak self] in
            guard let self = self else { return }
            self.longAction()
        }
        return portraitView
    }()
    
    lazy var landscapeView: ZFLandscapeView = {
        let landscapeView = ZFLandscapeView(frame: UIScreen.main.bounds)
//        landscapeView.likeBlock = {
//            
//        }
        return landscapeView
    }()
    
    override func initPlayer() {
        // 初始化播放器
        let manager = ZFAVPlayerManager()
        manager.shouldAutoPlay = true // 自动播放
        
        let player = ZFPlayerController()
        player.currentPlayerManager = manager
        player.disableGestureTypes = [.pan, .pinch]
        player.allowOrentitaionRotation = false
        self.player = player
        
        // 设置竖屏controlView
        player.controlView = portraitView
        
        // 事件处理
        
        // 播放结束回调
        player.playerDidToEnd = { [weak self] asset in
            guard let self = self else { return }
            self.player?.currentPlayerManager.replay()
        }
        
        // 加载状态改变回调
        player.playerLoadStateChanged = { [weak self] asset, loadState in
            guard let self = self else { return }
            if (loadState == .prepare || loadState == .stalled) && asset.isPlaying {
                self.currentCell?.showLoading()
            }else {
                self.currentCell?.hideLoading()
            }
        }
        
        // 播放进度回调
        player.playerPlayTimeChanged = { [weak self] asset, currentTime, duration in
            guard let self = self else { return }
            self.currentCell?.setProgress(self.player?.progress ?? 0)
        }
        
        // 方向即将改变
        player.orientationWillChange = { [weak self] player, isFullScreen in
            guard let self = self else { return }
            self.player?.controlView?.isHidden = true
            if player.isFullScreen {
                self.landscapeView.statusBar.startTimer()
            }else {
                self.landscapeView.statusBar.destoryTimer()
            }
        }
        
        // 方向已经改变
        player.orientationDidChanged = { [weak self] playser, isFullScreen in
            guard let self = self else { return }
            if isFullScreen {
                self.landscapeView.isHidden = false
                self.player?.controlView = self.landscapeView
            }else {
                self.portraitView.isHidden = false
                self.player?.controlView = self.portraitView
            }
        }
    }
    
    override func destoryPlayer() {
        self.player?.stop()
        self.player = nil
    }
    
    override func preloadVideo(cell: VideoCell, forIndex index: Int) {
        print("即将出现----\(index)")
    }
    
    override func playVideo(cell: VideoCell, forIndex index: Int) {
        print("播放-----\(index)")
        
        let model = dataSource[index]
        landscapeView.loadData(model: model)
        
        // 设置播放内容视图
        if player?.containerView != cell.coverImgView {
            player?.containerView = cell.coverImgView
        }
        
        // 设置视频封面图
        guard let manager = player?.currentPlayerManager else { return }
        manager.view.coverImageView.image = nil
        manager.view.coverImageView.kf.setImage(with: URL(string: model.poster_small))
        
        // 播放内容一致，不做处理
        let playUrl = manager.assetURL?.absoluteString
        if playUrl != nil && !playUrl!.isEmpty && playUrl == model.play_url {
            return
        }
        
        player?.assetURL = URL(string: model.play_url)
        portraitView.playBtn.isHidden = true
    }
    
    override func stopVideo(cell: VideoCell, forIndex index: Int) {
        print("停止----\(index)")
        let model = dataSource[index]
        
        // 判断播放内容是否一致
        guard let manager = player?.currentPlayerManager else { return }
        
        let playUrl = manager.assetURL?.absoluteString
        if playUrl != nil && !playUrl!.isEmpty && playUrl != model.play_url {
            return
        }
        player?.stop()
        cell.resetView()
    }
    
    override func enterFullScreen() {
        player?.enterFullScreen(true, animated: true)
    }
    
    func longAction() {
        let alertVC = UIAlertController(title: "测试", message: "", preferredStyle: .actionSheet)
        
        alertVC.addAction(UIAlertAction(title: "不感兴趣(有动画)", style: .default, handler: { action in
            self.portraitScrollView.removeCurrentCell(animated: true)
        }))
        
        alertVC.addAction(UIAlertAction(title: "不感兴趣(无动画)", style: .default, handler: { action in
            self.portraitScrollView.removeCurrentCell(animated: false)
        }))
        
        alertVC.addAction(UIAlertAction(title: "清空后切换索引", style: .default, handler: { action in
            self.dataSource.removeAll()
            self.portraitScrollView.reloadData()
            self.portraitScrollView.defaultIndex = self.currentIndex
            self.viewController?.requestNewData()
        }))
        
        alertVC.addAction(UIAlertAction(title: "加载下一页", style: .default, handler: { action in
            self.viewController?.requestMoreData()
        }))
        
        alertVC.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        self.viewController?.present(alertVC, animated: true)
    }
}
