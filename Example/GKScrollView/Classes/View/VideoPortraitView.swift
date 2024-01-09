//
//  VideoPortraitView.swift
//  Example
//
//  Created by QuintGao on 2023/9/26.
//  Copyright © 2023 QuintGao. All rights reserved.
//

import UIKit

class VideoPortraitView: UIView {
    public lazy var playBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "ss_icon_pause"), for: .normal)
        btn.isUserInteractionEnabled = false
        btn.isHidden = true
        return btn
    }()
    
    public lazy var likeView: GKDoubleLikeView = {
        return GKDoubleLikeView()
    }()

    public var likeBlock: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(playBtn)
        playBtn.snp.makeConstraints {
            $0.center.equalTo(self)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
