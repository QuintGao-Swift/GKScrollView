//
//  KuaishouPortraitView.swift
//  Example
//
//  Created by QuintGao on 2023/10/12.
//  Copyright © 2023 QuintGao. All rights reserved.
//

import UIKit
import ZFPlayer

class KuaishouPortraitView: VideoPortraitView, ZFPlayerMediaControl {
    var player: ZFPlayerController?
    
    func gestureSingleTapped(_ gestureControl: ZFPlayerGestureControl) {
        perform(#selector(playPause), with: nil, afterDelay: 0.25)
    }
    
    func gestureDoubleTapped(_ gestureControl: ZFPlayerGestureControl) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(playPause), object: nil)
        let gesture = gestureControl.doubleTap
        let point = gesture.location(in: gesture.view)
        self.likeView.createAnimation(point: point, view: gesture.view, completion: nil)
        self.likeBlock?()
    }
    
    @objc func playPause() {
        guard let manager = player?.currentPlayerManager else { return }
        if manager.isPlaying {
            manager.pause()
            playBtn.isHidden = false
        }else {
            manager.play()
            playBtn.isHidden = true
        }
    }
}
