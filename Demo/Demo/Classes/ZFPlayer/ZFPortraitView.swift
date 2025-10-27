//
//  ZFPortraitView.swift
//  Example
//
//  Created by QuintGao on 2023/9/27.
//  Copyright © 2023 QuintGao. All rights reserved.
//

import UIKit
import ZFPlayer

class ZFPortraitView: VideoPortraitView, ZFPlayerMediaControl {

    public var longBlock: (() -> Void)?
    
    var player: ZFPlayerController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longAction)))
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc func longAction(gesture: UIGestureRecognizer) {
        if gesture.state == .began {
            longBlock?()
        }
    }
    
    func gestureSingleTapped(_ gestureControl: ZFPlayerGestureControl) {
        perform(#selector(playPause), with: nil, afterDelay: 0.25)
    }
    
    func gestureDoubleTapped(_ gestureControl: ZFPlayerGestureControl) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(playPause), object: nil)
        let gesture = gestureControl.doubleTap
        let point = gesture.location(in: gesture.view)
        likeView.createAnimation(point: point, view: gesture.view, completion: nil)
        likeBlock?()
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
