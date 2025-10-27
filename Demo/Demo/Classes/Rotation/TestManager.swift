//
//  TestManager.swift
//  Example
//
//  Created by QuintGao on 2023/10/11.
//  Copyright © 2023 QuintGao. All rights reserved.
//

import UIKit
import SnapKit

class TestManager: VideoManager {
    lazy var playView: UIView = {
        let view = UIView()
        
        view.addSubview(coverView)
        coverView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        return view
    }()
    
    lazy var coverView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.isUserInteractionEnabled = true
        return imgView
    }()
    
    var rotationManager: GKRotationManager?
    
    override func initPlayer() {
        self.rotationManager = GKRotationManager.manager
        self.rotationManager?.allowOrientationRotation = true
        self.rotationManager?.contentView = playView
        
        self.rotationManager?.orientationWillChange = { [weak self] isFullScreen in
            guard let self = self else { return }
            self.willRotation(isFullScreen: isFullScreen)
        }
        
        self.rotationManager?.orientationDidChanged = { [weak self] isFullScreen in
            guard let self = self else { return }
            self.didRotation(isFullScreen: isFullScreen)
        }
    }
    
    func willRotation(isFullScreen: Bool) {
        print("即将旋转----\(isFullScreen ? "全屏" : "竖屏")")
        if !isFullScreen {
            if let landscapeScrollView = landscapeScrollView {
                let superview = landscapeScrollView.superview
                superview?.addSubview((rotationManager?.contentView)!)
                landscapeScrollView.removeFromSuperview()
                self.landscapeScrollView = nil
            }
        }
    }
    
    func didRotation(isFullScreen: Bool) {
        print("结束旋转----\(isFullScreen ? "全屏" : "竖屏")")
        if isFullScreen {
            self.isFullScreen = true
            if landscapeScrollView == nil {
                initLandscapeView()
                let superview = rotationManager?.contentView?.superview
                landscapeScrollView?.frame = superview!.bounds
                superview?.addSubview(landscapeScrollView!)
                landscapeScrollView?.defaultIndex = portraitScrollView.currentIndex
                landscapeScrollView?.reloadData()
            }
        }else {
            self.isFullScreen = false
        }
    }
    
    override func playVideo(cell: VideoCell, forIndex index: Int) {
        let model = dataSource[index]
        
        if cell.isKind(of: VideoPortraitCell.self) {
            rotationManager?.containerView = cell.coverImgView
            if self.isFullScreen { return }
        }else {
            portraitScrollView.scrollToCell(with: index)
        }
        self.currentCell = cell
        
        self.coverView.kf.setImage(with: URL(string: model.poster_small))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if self.playView.superview != cell.coverImgView {
                self.playView.frame = cell.coverImgView.bounds
                cell.coverImgView.addSubview(self.playView)
            }
        }
    }
    
    override func stopVideo(cell: VideoCell, forIndex index: Int) {
        self.coverView.image = nil
    }
    
    override func enterFullScreen() {
        self.rotationManager?.rotate()
    }
}
