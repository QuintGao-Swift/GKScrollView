//
//  VideoPortraitCell.swift
//  Example
//
//  Created by QuintGao on 2023/9/25.
//  Copyright © 2023 QuintGao. All rights reserved.
//

import UIKit
import GKScrollView
import GKSlider

class VideoPortraitCell: VideoCell {
    lazy var bottomView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    lazy var slider: GKSlider = {
        let slider = GKSlider()
        slider.isHideSliderBlock = true
        slider.sliderHeight = 1
        slider.maximumTrackTintColor = .clear
        slider.minimumTrackTintColor = .white
        return slider
    }()
    
    lazy var likeBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "ss_icon_star_normal"), for: .normal)
        btn.setImage(UIImage(named: "ss_icon_star_selected"), for: .selected)
        btn.addTarget(self, action: #selector(clickLikeBtn), for: .touchUpInside)
        return btn
    }()
    
    lazy var fullScreenBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "ss_icon_fullscreen"), for: .normal)
        btn.addTarget(self, action: #selector(clickFullscreenBtn), for: .touchUpInside)
        return btn
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        slider.value = 0
        coverImgView.image = nil
    }
    
    override func initUI() {
        super.initUI()
        
        addSubview(bottomView)
        bottomView.addSubview(nameLabel)
        bottomView.addSubview(contentLabel)
        bottomView.addSubview(slider)
        bottomView.addSubview(likeBtn)
        bottomView.addSubview(fullScreenBtn)
        
        bottomView.snp.makeConstraints {
            $0.left.right.bottom.equalTo(self)
            $0.height.equalTo(160)
        }
        
        nameLabel.snp.makeConstraints {
            $0.left.equalTo(self).offset(20)
            $0.bottom.equalTo(contentLabel.snp.top).offset(-10)
        }
        
        contentLabel.snp.makeConstraints {
            $0.bottom.equalTo(slider.snp.top).offset(-10)
            $0.left.equalTo(self).offset(20)
            $0.right.lessThanOrEqualTo(self).offset(-60)
        }
        
        slider.snp.makeConstraints {
            $0.left.equalTo(self).offset(20)
            $0.right.equalTo(self).offset(-20)
            $0.bottom.equalTo(self).offset(-60)
            $0.height.equalTo(1)
        }
        
        likeBtn.snp.makeConstraints {
            $0.bottom.equalTo(fullScreenBtn.snp.top).offset(-20)
            $0.centerX.equalTo(fullScreenBtn)
        }
        
        fullScreenBtn.snp.makeConstraints {
            $0.right.equalTo(self).offset(-20)
            $0.bottom.equalTo(slider.snp.top).offset(-10)
            $0.width.height.equalTo(40)
        }
    }
    
    override func loadData(model: VideoModel) {
        super.loadData(model: model)
        nameLabel.text = model.source_name
        contentLabel.text = model.title
        likeBtn.isSelected = model.isLike
    }
    
    override func resetView() {
        slider.value = 0
    }
    
    override func scrollViewBeginDragging() {
        bottomView.alpha = 0.4
    }
    
    override func scrollViewDidEndDragging() {
        bottomView.alpha = 1.0
    }
    
    override func showLoading() {
        slider.showLineLoading()
    }
    
    override func hideLoading() {
        slider.hideLineLoading()
    }
    
    override func setProgress(_ progress: Float) {
        slider.value = progress
    }
    
    @objc func clickLikeBtn() {
        delegate?.cellClickLikeBtn(cell: self)
    }
    
    @objc func clickFullscreenBtn() {
        delegate?.cellClickFullscreenBtn(cell: self)
    }
}
