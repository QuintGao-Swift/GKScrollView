//
//  GKLandscapeWindow.swift
//  Example
//
//  Created by QuintGao on 2023/9/27.
//  Copyright © 2023 QuintGao. All rights reserved.
//

import UIKit

open class GKLandscapeWindow: UIWindow {
    public weak var rotationManager: GKRotationManager?
    private var old_bounds: CGRect?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        windowLevel = UIWindow.Level.statusBar - 1
        if #available(iOS 13.0, *) {
            if windowScene == nil {
                windowScene = UIApplication.shared.keyWindow?.windowScene
            }
            if windowScene == nil {
                windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            }
            isHidden = true
        }
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    open override var rootViewController: UIViewController? {
        didSet {
            super.rootViewController = rootViewController
            rootViewController?.view.frame = bounds
            rootViewController?.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }
    
    open override var backgroundColor: UIColor? { didSet {} }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        true
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        // 如果是大屏转大屏，就不需要修改了
        if old_bounds != bounds {
            old_bounds = bounds
            
            var superview: UIView? = self
            if #available(iOS 13.0, *) {
                superview = subviews.first
            }
            UIView.performWithoutAnimation {
                superview?.subviews.forEach {
                    if $0 != rootViewController?.view && $0.isMember(of: UIView.self) {
                        $0.backgroundColor = .clear
                        $0.subviews.forEach {
                            $0.backgroundColor = .clear
                        }
                    }
                }
            }
        }
        rootViewController?.view.frame = bounds
    }
}
