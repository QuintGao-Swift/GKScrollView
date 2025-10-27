//
//  VideoLandscapeView.swift
//  Example
//
//  Created by QuintGao on 2023/9/26.
//  Copyright © 2023 QuintGao. All rights reserved.
//

import UIKit
import GKSlider

class VideoLandscapeView: UIView {
    lazy var topContainerView: VideoControlMaskView = {
        return .init(style: .top)
    }()
    
    lazy var bottomContainerView: VideoControlMaskView = {
        return .init(style: .bottom)
    }()
    
    lazy var statusBar: VideoPlayerStatusBar = {
        return VideoPlayerStatusBar()
    }()
    
    lazy var backBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "ic_back_white"), for: .normal)
        btn.setEnlargeEdge(size: 10)
        btn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        return btn
    }()
    
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 15)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white
        return label
    }()
    
    lazy var playBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "icon_play"), for: .normal)
        btn.setImage(UIImage(named: "icon_pause"), for: .selected)
        btn.addTarget(self, action: #selector(playAction), for: .touchUpInside)
        btn.setEnlargeEdge(size: 10)
        return btn
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .white
        return label
    }()
    
    lazy var likeBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "ss_icon_star_normal"), for: .normal)
        btn.setImage(UIImage(named: "ss_icon_star_selected"), for: .selected)
        btn.addTarget(self, action: #selector(likeAction), for: .touchUpInside)
        btn.setEnlargeEdge(size: 10)
        return btn
    }()
    
    lazy var fullScreenBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "ss_icon_shrinkscreen"), for: .normal)
        btn.addTarget(self, action: #selector(fullScreenAction), for: .touchUpInside)
        btn.setEnlargeEdge(size: 10)
        return btn
    }()
    
    lazy var slider: GKSlider = {
        let slider = GKSlider()
        slider.setThumbImage(UIImage(named: "icon_slider"), for: .normal)
        slider.setThumbImage(UIImage(named: "icon_slider"), for: .highlighted)
        slider.maximumTrackTintColor = .gray
        slider.minimumTrackTintColor = .white
        slider.sliderHeight = 2
        slider.delegate = self
        slider.isSliderAllowTapped = false
        return slider
    }()
    
    lazy var likeView: GKDoubleLikeView = {
        return GKDoubleLikeView()
    }()
    
    var model: VideoInfo?
    
    public var isContainerShow: Bool = false
    
    public var likeBlock: ((VideoInfo?) -> Void)?
    
    public var rotationManager: GKRotationManager?
    
    var isSeeking: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initUI()
    }
    
    private func initUI() {
        addSubview(topContainerView)
        topContainerView.addSubview(statusBar)
        topContainerView.addSubview(backBtn)
        topContainerView.addSubview(contentLabel)
        topContainerView.addSubview(nameLabel)
        
        addSubview(bottomContainerView)
        bottomContainerView.addSubview(playBtn)
        bottomContainerView.addSubview(timeLabel)
        bottomContainerView.addSubview(slider)
        bottomContainerView.addSubview(fullScreenBtn)
        bottomContainerView.addSubview(likeBtn)
        
        topContainerView.snp.makeConstraints {
            $0.top.left.right.equalTo(self)
            $0.height.equalTo(80)
        }
        
        statusBar.snp.makeConstraints {
            $0.top.equalTo(topContainerView.safeAreaLayoutGuide.snp.top)
            $0.left.equalTo(topContainerView.safeAreaLayoutGuide.snp.left).offset(10)
            $0.right.equalTo(topContainerView.safeAreaLayoutGuide.snp.right).offset(-10)
            $0.height.equalTo(20)
        }
        
        backBtn.snp.makeConstraints {
            $0.top.equalTo(statusBar.snp.bottom).offset(5)
            $0.left.equalTo(statusBar).offset(2)
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(backBtn).offset(3)
            $0.left.equalTo(backBtn.snp.right).offset(5)
            $0.right.equalTo(statusBar.snp.right).offset(-20)
        }
        
        nameLabel.snp.makeConstraints {
            $0.left.equalTo(contentLabel)
            $0.top.equalTo(contentLabel.snp.bottom).offset(5)
        }
        
        bottomContainerView.snp.makeConstraints {
            $0.bottom.left.right.equalTo(self)
            $0.height.equalTo(80)
        }
        
        playBtn.snp.makeConstraints {
            $0.left.equalTo(slider)
            $0.bottom.equalTo(bottomContainerView).offset(-10)
        }
        
        timeLabel.snp.makeConstraints {
            $0.centerY.equalTo(playBtn)
            $0.left.equalTo(playBtn.snp.right).offset(10)
        }
        
        fullScreenBtn.snp.makeConstraints {
            $0.right.equalTo(slider.snp.right)
            $0.centerY.equalTo(playBtn)
        }
        
        likeBtn.snp.makeConstraints {
            $0.centerY.equalTo(playBtn)
            $0.right.equalTo(fullScreenBtn.snp.left).offset(-20)
        }
        
        slider.snp.makeConstraints {
            $0.left.equalTo(bottomContainerView.safeAreaLayoutGuide.snp.left).offset(10)
            $0.right.equalTo(bottomContainerView.safeAreaLayoutGuide.snp.right).offset(-10)
            $0.bottom.equalTo(playBtn.snp.top).offset(-10)
            $0.height.equalTo(10)
        }
    }
    
    public func loadData(model: VideoInfo) {
        self.model = model
        contentLabel.text = model.title
        nameLabel.text = model.source_name
        likeBtn.isSelected = model.isLike
    }
    
    public func convertTime(time: Int) -> String {
        if time < 60 {
            return String(format: "00:%02d", time)
        }else if time >= 60 && time < 3600 {
            return String(format: "%02d:%02d", time/60, time%60)
        }else {
            return String(format: "%02d:%02d:%02d", time/3600, time%3600/60, time%60)
        }
    }
    
    @objc public func showContainerView(animated: Bool) {
        topContainerView.snp.updateConstraints {
            $0.top.equalTo(self)
        }
        
        bottomContainerView.snp.updateConstraints {
            $0.bottom.equalTo(self)
        }
        
        topContainerView.isHidden = false
        bottomContainerView.isHidden = false
        
        let duration = animated ? 0.15 : 0
        UIView.animate(withDuration: duration) {
            self.layoutIfNeeded()
        } completion: { finished in
            self.isContainerShow = true
        }
    }
    
    @objc public func hideContainerView(animated: Bool) {
        topContainerView.snp.updateConstraints {
            $0.top.equalTo(self).offset(-80)
        }
        
        bottomContainerView.snp.updateConstraints {
            $0.bottom.equalTo(self).offset(80)
        }
        
        let duration = animated ? 0.15 : 0
        UIView.animate(withDuration: duration) {
            self.layoutIfNeeded()
        } completion: { finished in
            self.isContainerShow = false
            self.topContainerView.isHidden = true
            self.bottomContainerView.isHidden = true
        }
    }
    
    @objc func backAction() {
        
    }
    
    @objc func playAction() {
        
    }
    
    @objc func likeAction() {
        guard var model = model else { return }
        model.isLike = !model.isLike
        likeBtn.isSelected = model.isLike
        likeBlock?(model)
    }
    
    @objc func fullScreenAction() {
        backAction()
    }
    
    public func draggingEnded() {
        
    }
}

extension VideoLandscapeView: GKSliderDelegate {
    func touchBegan(for slider: GKSlider, value: Float) {
        
    }
    
    func touchEnded(for slider: GKSlider, value: Float) {
        draggingEnded()
    }
}
