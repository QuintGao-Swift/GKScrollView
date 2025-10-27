//
//  UIViewController+GKRotation.swift
//  Example
//
//  Created by QuintGao on 2023/9/27.
//  Copyright © 2023 QuintGao. All rights reserved.
//

import UIKit

extension UITabBarController {
    private func viewControllerRotation() -> UIViewController? {
        guard let vcs = viewControllers else { return nil }
        let vc = vcs[selectedIndex]
        if let nav = vc as? UINavigationController {
            return nav.topViewController
        }
        return vc
    }
    
    open override var shouldAutorotate: Bool {
        return viewControllerRotation()?.shouldAutorotate ?? false
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return viewControllerRotation()?.supportedInterfaceOrientations ?? .portrait
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return viewControllerRotation()?.preferredInterfaceOrientationForPresentation ?? .portrait
    }
}

extension UINavigationController {
    open override var shouldAutorotate: Bool {
        topViewController?.shouldAutorotate ?? false
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        topViewController?.supportedInterfaceOrientations ?? .portrait
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        topViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
    }
    
    open override var childForStatusBarStyle: UIViewController? {
        topViewController
    }
    
    open override var childForStatusBarHidden: UIViewController? {
        topViewController
    }
}
