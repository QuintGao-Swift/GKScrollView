//
//  DouyinPortraitView.swift
//  Example
//
//  Created by QuintGao on 2023/10/11.
//  Copyright © 2023 QuintGao. All rights reserved.
//

import UIKit
import SJVideoPlayer

class DouyinPortraitView: VideoPortraitView, SJControlLayer {
    
    var restarted: Bool = false
    var player: SJVideoPlayer?
    
    func controlView() -> UIView! {
        self
    }
    
    func installedControlView(to videoPlayer: SJBaseVideoPlayer!) {
        self.player = videoPlayer as? SJVideoPlayer
        
        self.player?.gestureController.singleTapHandler = { [weak self] control, location in
            guard let self = self else { return }
            guard let player = self.player else { return }
            if player.isPaused {
                player.play()
                playBtn.isHidden = true
            }else {
                player.pauseForUser()
                playBtn.isHidden = false
            }
        }
        
        self.player?.gestureController.doubleTapHandler = { [weak self] control, location in
            guard let self = self else { return }
            self.likeView.createAnimation(point: location, view: player?.presentView, completion: nil)
            self.likeBlock?()
        }
    }
    
    func restartControlLayer() {
        restarted = true
    }
    
    func exitControlLayer() {
        restarted = false
    }
    
}
