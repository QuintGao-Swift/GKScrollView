//
//  SJPortraitView.swift
//  Example
//
//  Created by QuintGao on 2023/10/11.
//  Copyright © 2023 QuintGao. All rights reserved.
//

import UIKit
import SJVideoPlayer

class SJPortraitView: VideoPortraitView, SJControlLayer {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
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
                self.playBtn.isHidden = true
            }else {
                player.pauseForUser()
                self.playBtn.isHidden = false
            }
        }
    }
    
    func restartControlLayer() {
        restarted = true
    }
    
    func exitControlLayer() {
        restarted = false
    }
}
