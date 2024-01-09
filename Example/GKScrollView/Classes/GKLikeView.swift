//
//  GKLikeView.swift
//  Example
//
//  Created by QuintGao on 2023/9/26.
//  Copyright © 2023 QuintGao. All rights reserved.
//

import UIKit

class GKLikeView: UIView {
    public var isLike: Bool = false
    
    lazy var likeBeforeImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "ic_home_like_before")
        return imgView
    }()
    
    lazy var likeAfterImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "ic_home_like_after")
        return imgView
    }()
    
    lazy var countLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 13)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var imgCenter = likeBeforeImgView.center
        imgCenter.x = frame.size.width / 2
        likeBeforeImgView.center = imgCenter
        likeAfterImgView.center = imgCenter
        
        countLabel.sizeToFit()
        
        let countX = (frame.width - countLabel.frame.width) / 2
        let countY = (frame.height - countLabel.frame.height)
        countLabel.frame = CGRectMake(countX, countY, countLabel.frame.width, countLabel.frame.height)
    }
    
    func initUI() {
        addSubview(likeBeforeImgView)
        addSubview(likeAfterImgView)
        addSubview(countLabel)
        
        let imgWH: CGFloat = 40
        likeBeforeImgView.frame = CGRectMake(0, 0, imgWH, imgWH)
        likeAfterImgView.frame = CGRectMake(0, 0, imgWH, imgWH)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction)))
    }
    
    @objc func tapAction() {
        if isLike {
            startAnimation(isLike: false)
        }else {
            startAnimation(isLike: true)
        }
    }
    
    public func setupLikeState(isLike: Bool) {
        self.isLike = isLike
        if isLike {
            likeAfterImgView.isHidden = false
        }else {
            likeAfterImgView.isHidden = true
        }
    }
    
    public func setupLikeCount(count: String) {
        countLabel.text = count
        layoutSubviews()
    }
    
    public func startAnimation(isLike: Bool) {
        if self.isLike == isLike { return }
        self.isLike = isLike
        
        if isLike {
            let length: CGFloat = 30
            let duration: CGFloat = 0.5
            for i in 0..<6 {
                let layer = CAShapeLayer()
                layer.position = likeBeforeImgView.center
                layer.fillColor = UIColor.init(red: 232/255.0, green: 50/255.0, blue: 85/255.0, alpha: 1.0).cgColor
                
                let startPath = UIBezierPath()
                startPath.move(to: CGPointMake(-2, -length))
                startPath.addLine(to: CGPointMake(2, -length))
                startPath.addLine(to: CGPointMake(0, 0))
                layer.path = startPath.cgPath
                layer.transform = CATransform3DMakeRotation(.pi/3.0 * Double(i), 0, 0, 1.0)
                self.layer.addSublayer(layer)
                
                let group = CAAnimationGroup()
                group.isRemovedOnCompletion = false
                group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                group.fillMode = kCAFillModeForwards
                group.duration = duration
                
                let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
                scaleAnim.fromValue = 0.0
                scaleAnim.toValue = 1.0
                scaleAnim.duration = duration * 0.2
                
                let endPath = UIBezierPath()
                endPath.move(to: CGPointMake(-2, -length))
                endPath.addLine(to: CGPointMake(2, -length))
                endPath.addLine(to: CGPointMake(0, -length))
                
                let pathAnim = CABasicAnimation(keyPath: "path")
                pathAnim.fromValue = layer.path
                pathAnim.toValue = endPath.cgPath
                pathAnim.beginTime = duration * 0.2
                pathAnim.duration = duration * 0.8
                group.animations = [scaleAnim, pathAnim]
                layer.add(group, forKey: nil)
            }
            likeAfterImgView.isHidden = false
            likeAfterImgView.alpha = 0.0
            likeAfterImgView.transform = CGAffineTransformMakeScale(0.1, 0.1)
            
            UIView.animate(withDuration: 0.15) {
                self.likeAfterImgView.transform = CGAffineTransformMakeScale(1.0, 1.0)
                self.likeAfterImgView.alpha = 1.0
                self.likeAfterImgView.alpha = 0.0
            } completion: { finished in
                self.likeAfterImgView.transform = .identity
                self.likeAfterImgView.alpha = 1.0
            }
        }else {
            likeAfterImgView.alpha = 1.0
            likeAfterImgView.transform = CGAffineTransformMakeScale(1.0, 1.0)
            UIView.animate(withDuration: 0.15) {
                self.likeAfterImgView.transform = CGAffineTransformMakeScale(0.3, 0.3)
            } completion: { finished in
                self.likeAfterImgView.transform = .identity
                self.likeAfterImgView.isHidden = true
            }
        }
    }
}
