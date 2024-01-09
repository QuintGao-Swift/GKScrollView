//
//  GKDoubleLikeView.swift
//  Example
//
//  Created by QuintGao on 2023/9/26.
//  Copyright © 2023 QuintGao. All rights reserved.
//

import UIKit

class GKDoubleLikeView: UIView {

    var completion: (() -> Void)?
    
    public func createAnimation(touch: UITouch) {
        if touch.tapCount <= 1 { return }
        createAnimation(point: touch.location(in: touch.view), view: touch.view, completion: nil)
    }
    
    public func createAnimation(point: CGPoint, view: UIView?, completion: (() -> Void)?) {
        guard let view = view else { return }
        self.completion = completion
        
        let image = UIImage(named: "likeHeart")
        let imgView = UIImageView(frame: CGRectMake(0, 0, 80, 80))
        imgView.image = image
        imgView.contentMode = .scaleAspectFill
        imgView.center = point
        
        // 随机左右显示
        var leftOrRight = Int(arc4random() % 2)
        leftOrRight = (leftOrRight != 0) ? leftOrRight : -1
        imgView.transform = CGAffineTransformRotate(imgView.transform, .pi / 9 * CGFloat(leftOrRight))
        view.addSubview(imgView)
        
        // 出来的时候回弹一下
        UIView.animate(withDuration: 0.1) {
            imgView.transform = CGAffineTransformScale(imgView.transform, 1.2, 1.2)
        } completion: { finished in
            imgView.transform = CGAffineTransformScale(imgView.transform, 0.8, 0.8)
            
            // 向上飘，放大，透明
            self.perform(#selector(self.animationToTop), with: [imgView, image], afterDelay: 0.3)
        }
    }
    
    @objc func animationToTop(imgObjects: [Any]) {
        if imgObjects.count > 0 {
            var imgView = imgObjects.first as? UIImageView
            var image = imgObjects.last as? UIImage
            UIView.animate(withDuration: 1.0) {
                var imgViewFrame = imgView?.frame ?? .zero
                imgViewFrame.origin.y -= 100
                imgView?.frame = imgViewFrame
                imgView?.transform = CGAffineTransformScale(imgView!.transform, 1.8, 1.8)
                imgView?.alpha = 0.0
            } completion: { finished in
                imgView?.removeFromSuperview()
                imgView = nil
                _ = image?.size
                image = nil
                self.completion?()
            }
        }
    }
}
