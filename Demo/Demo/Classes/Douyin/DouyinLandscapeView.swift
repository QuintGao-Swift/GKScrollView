//
//  DouyinLandscapeView.swift
//  Example
//
//  Created by QuintGao on 2023/10/11.
//  Copyright © 2023 QuintGao. All rights reserved.
//

import UIKit
import SJVideoPlayer

class DouyinLandscapeView: VideoLandscapeView, SJControlLayer {
    
    var player: SJVideoPlayer?
    
    var singleTapBlock: (() -> Void)?
    
    override func fullScreenAction() {
        backAction()
    }
    
    override func backAction() {
        if let rotationManager = rotationManager {
            rotationManager.rotate()
        }else {
            player?.rotate(.portrait, animated: true)
        }
    }

    override func playAction() {
        if let player = player, player.isPaused {
            player.play()
        }else {
            player?.pauseForUser()
        }
        playBtn.isSelected = player?.isPlaying == true
    }
    
    // MARK: - SJControlLayer
    var restarted: Bool = false
    
    func controlView() -> UIView! {
        self
    }
    
    func installedControlView(to videoPlayer: SJBaseVideoPlayer!) {
        player = videoPlayer as? SJVideoPlayer
        playBtn.isSelected = videoPlayer.isPlaying
        
        player?.gestureController.singleTapHandler = { [weak self] control, location in
            guard let self = self else { return }
            self.singleTapBlock?()
        }
        
        player?.gestureController.doubleTapHandler = { [weak self] control, location in
            guard let self = self else { return }
            guard let player = self.player else { return }
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideContainerView), object: true)
            self.likeView.createAnimation(point: location, view: player.presentView) { [weak self] in
                guard let self = self else { return }
                self.perform(#selector(hideContainerView), with: true, afterDelay: 5.0)
            }
            self.model?.isLike = true
            self.likeBtn.isSelected = true
            self.likeBlock?(self.model)
        }
    }
    
    func restartControlLayer() {
        restarted = true
    }
    
    func exitControlLayer() {
        restarted = false
    }
    
    func videoPlayer(_ videoPlayer: SJBaseVideoPlayer!, willRotateView isFull: Bool) {
        self.isHidden = true
    }
    
    func videoPlayer(_ videoPlayer: SJBaseVideoPlayer!, gestureRecognizerShouldTrigger type: SJPlayerGestureType, location: CGPoint) -> Bool {
        if CGRectContainsPoint(topContainerView.frame, location) {
            return false
        }
        if CGRectContainsPoint(bottomContainerView.frame, location) {
            return false
        }
        return true
    }
    
    func videoPlayer(_ videoPlayer: SJBaseVideoPlayer!, reachabilityChanged status: SJNetworkStatus) {
        var net = "WIFI"
        switch status {
        case .notReachable:
            net = "无网络"
        case .reachableViaWWAN:
            net = "蜂窝网络"
        case .reachableViaWiFi:
            net = "WIFI"
        default:
            net = "未知"
        }
        statusBar.network = net
    }
    
    func videoPlayer(_ videoPlayer: SJBaseVideoPlayer!, currentTimeDidChange currentTime: TimeInterval) {
        if slider.isDragging { return }
        if isSeeking { return }
        let progress = videoPlayer.duration == 0 ? 0 : currentTime / videoPlayer.duration
        slider.value = Float(progress)
        timeLabel.text = convertTime(time: Int(currentTime)) + "  /  " + convertTime(time: Int(videoPlayer.duration))
    }
    
    override func draggingEnded() {
        guard let player = player else { return }
        isSeeking = true
        let time = player.duration * Double(slider.value)
        
        player.seek(toTime: time) { [weak self] finished in
            guard let self = self else { return }
            self.isSeeking = false
        }
    }
    
    public func autoHide() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideContainerView), object: true)
        if isContainerShow {
            hideContainerView(animated: true)
        }else {
            showContainerView(animated: true)
            perform(#selector(hideContainerView), with: true, afterDelay: 5.0)
        }
    }
}
