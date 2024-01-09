//
//  GKLandscapeViewController.swift
//  Example
//
//  Created by QuintGao on 2023/9/27.
//  Copyright © 2023 QuintGao. All rights reserved.
//

import UIKit

@objc protocol GKLandscapeViewControllerDelegate {
    func viewControllerShouldAutorotate(_ viewController: GKLandscapeViewController) -> Bool
    func viewController(_ viewController: GKLandscapeViewController, viewWillTransitionTo size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
}

class GKLandscapeViewController: UIViewController {

    weak var delegate: GKLandscapeViewControllerDelegate?
    var disableAnimations: Bool = false
    var statusBarHidden: Bool = false
    var statusBarStyle: UIStatusBarStyle = .lightContent
    var statusBarAnimation: UIStatusBarAnimation = .slide
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        delegate?.viewController(self, viewWillTransitionTo: size, with: coordinator)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .allButUpsideDown
    }
    
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        statusBarStyle
    }
    
    override var prefersStatusBarHidden: Bool {
        statusBarHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        statusBarAnimation
    }
}
