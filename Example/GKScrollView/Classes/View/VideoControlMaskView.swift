//
//  VideoControlMaskView.swift
//  Example
//
//  Created by QuintGao on 2023/9/25.
//  Copyright © 2023 QuintGao. All rights reserved.
//

import UIKit

enum VideoMaskStyle {
    case bottom
    case top
}

class VideoControlMaskView: UIView {

    var style: VideoMaskStyle = .top
    
    init(style: VideoMaskStyle) {
        super.init(frame: .zero)
        self.style = style
        
        guard let maskLayer = layer as? CAGradientLayer else { return }
        
        switch style {
        case .top:
            maskLayer.colors = [UIColor.init(white: 0, alpha: 0.8).cgColor,
                                UIColor.clear.cgColor]
        case .bottom:
            maskLayer.colors = [UIColor.clear.cgColor,
                                UIColor.init(white: 0, alpha: 0.8).cgColor]
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }
    
    public func cleanColors() {
        if let maskLayer = layer as? CAGradientLayer {
            maskLayer.colors = nil
        }
    }
}
