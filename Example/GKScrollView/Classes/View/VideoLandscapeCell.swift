//
//  VideoLandscapeCell.swift
//  Example
//
//  Created by QuintGao on 2023/9/25.
//  Copyright © 2023 QuintGao. All rights reserved.
//

import UIKit
import GKScrollView

class VideoLandscapeCell: VideoCell {
    lazy var topContainerView: VideoControlMaskView = {
        return VideoControlMaskView(style: .top)
    }()
    
    lazy var backBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "ic_back_white"), for: .normal)
        btn.setEnlargeEdge(size: 10)
        btn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        return btn
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 15)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    public var isShowTop = false
    
    override func initUI() {
        super.initUI()
        
        addSubview(topContainerView)
        topContainerView.addSubview(backBtn)
        topContainerView.addSubview(titleLabel)
        
        topContainerView.snp.makeConstraints {
            $0.top.left.right.equalTo(self)
            $0.height.equalTo(80)
        }
        
        backBtn.snp.makeConstraints {
            $0.top.equalTo(self).offset(25)
            $0.left.equalTo(topContainerView.safeAreaLayoutGuide.snp.left).offset(12)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(backBtn).offset(3)
            $0.left.equalTo(backBtn.snp.right).offset(5)
            $0.right.equalTo(topContainerView.safeAreaLayoutGuide.snp.right).offset(-30)
        }
        
        hideTopView()
    }
    
    override func loadData(model: VideoModel) {
        super.loadData(model: model)
        titleLabel.text = model.title
    }
    
    @objc func backAction() {
        delegate?.cellClickBackBtn()
    }
    
    @objc public func hideTopView() {
        topContainerView.isHidden = true
        isShowTop = false
    }
    
    @objc public func showTopView() {
        topContainerView.isHidden = false
        isShowTop = true
    }
    
    override func resetView() {
        super.resetView()
        showTopView()
    }
    
    public func autoHide() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideTopView), object: nil)
        perform(#selector(hideTopView), with: nil, afterDelay: 3.0)
    }
}
