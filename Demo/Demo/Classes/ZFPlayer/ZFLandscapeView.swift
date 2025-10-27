//
//  ZFLandscapeView.swift
//  Example
//
//  Created by QuintGao on 2023/9/27.
//  Copyright © 2023 QuintGao. All rights reserved.
//

import UIKit
import ZFPlayer

class ZFLandscapeView: VideoLandscapeView, ZFPlayerMediaControl {

    var player: ZFPlayerController? {
        didSet {
            playBtn.isSelected = player?.currentPlayerManager.isPlaying ?? false
        }
    }
    
    override func backAction() {
        if let rotationManager = rotationManager {
            rotationManager.rotate()
        }else if let player = player {
            player.enterFullScreen(!player.isFullScreen, animated: true)
        }
    }
    
    override func playAction() {
        guard let manager = player?.currentPlayerManager else { return }
        if manager.isPlaying {
            manager.pause()
        }else {
            manager.play()
        }
        playBtn.isSelected = manager.isPlaying
    }

    func videoPlayer(_ videoPlayer: ZFPlayerController, orientationDidChanged observer: ZFOrientationObserver) {
        if videoPlayer.isFullScreen {
            showContainerView(animated: false)
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideContainerView), object: true)
            perform(#selector(hideContainerView), with: true, afterDelay: 5.0)
        }
    }
    
    func gestureSingleTapped(_ gestureControl: ZFPlayerGestureControl) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideContainerView), object: true)
        if isContainerShow {
            hideContainerView(animated: true)
        }else {
            showContainerView(animated: true)
            perform(#selector(hideContainerView), with: true, afterDelay: 5.0)
        }
    }
    
    func gestureDoubleTapped(_ gestureControl: ZFPlayerGestureControl) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideContainerView), object: true)
        
        let gesture = gestureControl.doubleTap
        let point = gesture.location(in: gesture.view)
        
        likeView.createAnimation(point: point, view: gesture.view) { [weak self] in
            guard let self = self else { return }
            self.perform(#selector(hideContainerView), with: true, afterDelay: 5.0)
        }
        model?.isLike = true
        likeBtn.isSelected = true
        likeBlock?(model)
    }
    
    func videoPlayer(_ videoPlayer: ZFPlayerController, reachabilityChanged status: ZFReachabilityStatus) {
        var net = "WIFI"
        switch status {
        case .reachableViaWiFi:
            net = "WIFI"
        case .notReachable:
            net = "无网络"
        case .reachableVia2G:
            net = "2G"
        case .reachableVia3G:
            net = "3G"
        case .reachableVia4G:
            net = "4G"
        case .reachableVia5G:
            net = "5G"
        default:
            net = "未知"
        }
        statusBar.network = net
    }
    
    func videoPlayer(_ videoPlayer: ZFPlayerController, currentTime: TimeInterval, totalTime: TimeInterval) {
        if slider.isDragging { return }
        if isSeeking { return }
        slider.value = videoPlayer.progress
        timeLabel.text = String(format: "%@  /  %@", convertTime(time: Int(currentTime)), convertTime(time: Int(totalTime)))
    }
    
    override func draggingEnded() {
        guard let player = player else { return }
        let time = player.currentPlayerManager.totalTime * Double(slider.value)
        
        self.isSeeking = true
        player.seek(toTime: time) { [weak self] finished in
            guard let self = self else { return }
            self.isSeeking = false
        }
    }
}
