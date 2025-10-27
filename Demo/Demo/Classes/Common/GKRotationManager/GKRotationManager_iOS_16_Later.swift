//
//  GKRotationManager_iOS_16_Later.swift
//  Example
//
//  Created by QuintGao on 2023/9/27.
//  Copyright © 2023 QuintGao. All rights reserved.
//

import UIKit

class GKRotationManager_iOS_16_Later: GKRotationManager {
    var landscapeVC: GKLandscapeViewController?
    
    override var landscapeViewController: GKLandscapeViewController {
        if landscapeVC == nil {
            landscapeVC = GKLandscapeViewController()
        }
        return landscapeVC!
    }
    
    fileprivate func setNeedsUpdateOfSupportInterfaceOrientations() {
        if #available(iOS 16.0, *) {
            UIApplication.shared.keyWindow?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
            window?.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
        }
    }
    
    override func interface(_ orientation: UIInterfaceOrientation, completion: (() -> Void)?) {
        super.interface(orientation, completion: completion)
        let fromOrientation = getCurrentOrientation()
        let toOrientation = orientation
        willChange(orientation)
        currentOrientation = toOrientation
        guard let contentView = contentView else { return }
        guard let containerView = containerView else { return }
        let sourceWindow = containerView.window
        let sourceFrame = containerView.convert(containerView.bounds, to: sourceWindow)
        let screenBounds = UIScreen.main.bounds
        let maxSize = max(screenBounds.width, screenBounds.height)
        let minSize = min(screenBounds.width, screenBounds.height)
        contentView.autoresizingMask = []
        if fromOrientation == .portrait || contentView.superview != landscapeViewController.view {
            contentView.frame = sourceFrame
            sourceWindow?.addSubview(contentView)
            contentView.layoutIfNeeded()
            if window?.isKeyWindow == false {
                window?.isHidden = false
                window?.makeKeyAndVisible()
            }
        }else if toOrientation == .portrait {
            contentView.removeFromSuperview()
            sourceWindow?.addSubview(contentView)
            contentView.bounds = CGRectMake(0, 0, maxSize, minSize)
            contentView.center = CGPointMake(minSize * 0.5, maxSize * 0.5)
            contentView.transform = getRotationTransform(fromOrientation)
            contentView.layoutIfNeeded()
            contentView.snapshotView(afterScreenUpdates: true)
            UIView.performWithoutAnimation {
                sourceWindow?.makeKeyAndVisible()
                self.window?.isHidden = true
            }
        }
        setNeedsUpdateOfSupportInterfaceOrientations()
        
        var rotationBounds = CGRect.zero
        var rotationCenter = CGPoint.zero
        if toOrientation.isLandscape {
            rotationBounds = CGRectMake(0, 0, maxSize, minSize)
            rotationCenter = (fromOrientation == .portrait || contentView.superview != landscapeViewController.view) ? CGPointMake(minSize * 0.5, maxSize * 0.5) : CGPointMake(maxSize * 0.5, minSize * 0.5)
        }
        var rotationTransform = CGAffineTransform.identity
        if fromOrientation == .portrait {
            rotationTransform = getRotationTransform(toOrientation)
        }
        if disableAnimations {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
        }
        UIView.animate(withDuration: 0.3) {
            if toOrientation == .portrait {
                contentView.transform = rotationTransform
                contentView.frame = sourceFrame
            }else {
                contentView.transform = rotationTransform
                contentView.bounds = rotationBounds
                contentView.center = rotationCenter
            }
            contentView.layoutIfNeeded()
        } completion: { finished in
            if self.disableAnimations {
                CATransaction.commit()
            }
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            if toOrientation == .portrait {
                containerView.addSubview(contentView)
                contentView.frame = containerView.bounds
            }else {
                self.setNeedsUpdateOfSupportInterfaceOrientations()
                contentView.transform = .identity
                self.landscapeViewController.view.addSubview(contentView)
                contentView.frame = self.window?.bounds ?? .zero
                contentView.layoutIfNeeded()
            }
            completion?()
            self.didChanged(toOrientation)
        }
    }
    
    override func supportedInterfaceOrientation(for window: UIWindow) -> UIInterfaceOrientationMask {
        if window == self.window {
            return UIInterfaceOrientationMask(rawValue: 1 << self.currentOrientation.rawValue)
        }
        return .portrait
    }
    
    func getRotationTransform(_ orientation: UIInterfaceOrientation) -> CGAffineTransform {
        var transform = CGAffineTransform.identity
        if orientation == .landscapeLeft {
            transform = CGAffineTransformMakeRotation(-.pi/2)
        }else {
            transform = CGAffineTransformMakeRotation(.pi/2)
        }
        return transform
    }
}
