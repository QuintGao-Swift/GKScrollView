//
//  GKRotationManager_iOS_9_15.swift
//  Example
//
//  Created by QuintGao on 2023/9/27.
//  Copyright © 2023 QuintGao. All rights reserved.
//

import UIKit

class GKLandscapeViewController_iOS_9_15: GKLandscapeViewController {
    lazy var playerSuperView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(playerSuperView)
    }
    
    override var shouldAutorotate: Bool {
        delegate?.viewControllerShouldAutorotate(self) ?? false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .allButUpsideDown
    }
}

class GKRotationManager_iOS_9_15: GKRotationManager {
    var rotateCompletion: (() -> Void)?
    var forceRotation: Bool = false
    var landscapeVC: GKLandscapeViewController?
    
    override var landscapeViewController: GKLandscapeViewController {
        if landscapeVC == nil {
            landscapeVC = GKLandscapeViewController_iOS_9_15()
            landscapeVC?.delegate = self
        }
        return landscapeVC!
    }
    
    override func interface(_ orientation: UIInterfaceOrientation, completion: (() -> Void)?) {
        super.interface(orientation, completion: completion)
        rotateCompletion = completion
        forceRotation = true
        UIDevice.current.setValue(UIDeviceOrientation.unknown, forKey: "orientation")
        UIDevice.current.setValue(orientation, forKey: "orientaiton")
    }
    
    func rotationBegin() {
        if window?.isHidden == true {
            window?.isHidden = false
            window?.makeKeyAndVisible()
        }
        UIView.animate(withDuration: 0.0) {
            self.window?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    func rotationEnd() {
        if window?.isHidden == false && !currentOrientation.isLandscape {
            window?.isHidden = true
            containerView?.window?.makeKeyAndVisible()
        }
        disableAnimations = false
        rotateCompletion?()
        rotateCompletion = nil
    }
    
    func allowsRotation() -> Bool {
        if UIDevice.current.orientation.isValidInterfaceOrientation {
            let toOrientaiton = currentDeviceOrientation
            if !isSupport(toOrientaiton) {
                return false
            }
        }
        if self.forceRotation { return true }
        if self.allowOrientationRotation && !self.isLockedScreen { return true }
        return false
    }
    
    override func supportedInterfaceOrientation(for window: UIWindow) -> UIInterfaceOrientationMask {
        .allButUpsideDown
    }
}

extension GKRotationManager_iOS_9_15: GKLandscapeViewControllerDelegate {
    func viewControllerShouldAutorotate(_ viewController: GKLandscapeViewController) -> Bool {
        if allowsRotation() {
            rotationBegin()
            return true
        }
        return false
    }
    
    func viewController(_ viewController: GKLandscapeViewController, viewWillTransitionTo size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let toOrientation = currentDeviceOrientation
        if !isSupport(toOrientation) { return }
        willChange(toOrientation)
        currentOrientation = toOrientation
        guard let vc = landscapeViewController as? GKLandscapeViewController_iOS_9_15 else { return }
        guard let contentView = contentView else { return }
        guard let containerView = containerView else { return }
        if currentOrientation != .portrait {
            if contentView.superview != vc.playerSuperView {
                let frame = contentView.convert(contentView.bounds, to: contentView.window)
                vc.playerSuperView.frame = frame
                contentView.frame = CGRectMake(0, 0, frame.width, frame.height)
                contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                vc.playerSuperView.addSubview(contentView)
                contentView.layoutIfNeeded()
            }
            if disableAnimations {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
            }
            UIView.animate(withDuration: 0.0, animations: { /** preparing */ }) { finished in
                UIView.animate(withDuration: 0.3) {
                    vc.playerSuperView.frame = CGRect(origin: .zero, size: size)
                    contentView.layoutIfNeeded()
                } completion: { finished in
                    if self.disableAnimations {
                        CATransaction.commit()
                    }
                    self.forceRotation = false
                    self.rotationEnd()
                    self.didChanged(toOrientation)
                }
            }
        }else {
            if self.disableAnimations {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
            }
            UIView.animate(withDuration: 0.0, animations: { /** preparing */ }) { finished in
                UIView.animate(withDuration: 0.3) {
                    vc.playerSuperView.frame = containerView.convert(containerView.bounds, to: containerView.window)
                    contentView.layoutIfNeeded()
                } completion: { finished in
                    if self.disableAnimations {
                        CATransaction.commit()
                    }
                    self.forceRotation = false
                    let snapshot = contentView.snapshotView(afterScreenUpdates: false)
                    snapshot?.frame = containerView.bounds
                    snapshot?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    if snapshot != nil {
                        containerView.addSubview(snapshot!)
                    }
                    UIView.animate(withDuration: 0.0, animations: {}) { finished in
                        contentView.frame = containerView.bounds
                        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                        containerView.addSubview(contentView)
                        contentView.layoutIfNeeded()
                        snapshot?.removeFromSuperview()
                        self.rotationEnd()
                        self.didChanged(toOrientation)
                    }
                }
            }
        }
    }
}


