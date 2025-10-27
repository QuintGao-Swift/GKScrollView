//
//  KuaishouViewController.swift
//  Example
//
//  Created by QuintGao on 2023/10/11.
//  Copyright © 2023 QuintGao. All rights reserved.
//

import UIKit
import GKNavigationBarSwift

class KuaishouViewController: VideoPlayerViewController {

    lazy var panGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        gesture.delegate = self
        return gesture
    }()
    
    lazy var workListView: VideoWortListView = {
        return VideoWortListView()
    }()
    
    var beginX: CGFloat = 0
    var translationX: CGFloat = 0
    var isWorkListShow: Bool = false
    
    override func viewDidLoad() {
        manager = KuaishouManager()
        super.viewDidLoad()

        navigationItem.title = "快手"
        view.addGestureRecognizer(panGesture)
        gk_pushDelegate = self
    }
    
    override func initUI() {
        super.initUI()
        
        view.addSubview(workListView)
        workListView.frame = CGRectMake(view.bounds.width, 80, 62, view.bounds.height - 160)
    }

    @objc func handlePan(pan: UIPanGestureRecognizer) {
        let translation = pan.translation(in: pan.view)
        if pan.state == .began {
            beginX = workListView.frame.origin.x
            translationX = translation.x
        }else if pan.state == .changed {
            let diff = translation.x - translationX
            handlePanChange(distance: diff)
        }else {
            handlePnaEnded()
        }
    }
    
    func handlePanChange(distance: CGFloat) {
        let width = view.bounds.width
        let height = view.bounds.height
        
        let maxW = workListView.frame.width
        let maxH = workListView.frame.height
        
        let ratio = maxW / (height - maxW)
        let hDistance = distance / ratio
        
        if distance > 0 { // 右滑
            if beginX >= width { return }
            var x = width - maxW + distance
            if x >= width {
                x = width
            }
            var scrollH = maxH + hDistance
            if scrollH >= height {
                scrollH = height
            }
            var frame = workListView.frame
            frame.origin.x = x
            workListView.frame = frame
            
            var scrollFrame = manager?.portraitScrollView.frame
            scrollFrame?.size.width = x
            scrollFrame?.size.height = scrollH
            scrollFrame?.origin.y = (height - scrollH) / 2
            manager?.portraitScrollView.frame = scrollFrame ?? .zero
        }else { // 左滑
            if beginX < width { return }
            var x = width + distance
            if x <= width - maxW {
                x = width - maxW
            }
            var scrollH = height + hDistance
            if scrollH <= maxH {
                scrollH = maxH
            }
            
            var frame = workListView.frame
            frame.origin.x = x
            workListView.frame = frame
            
            var scrollFrame = manager?.portraitScrollView.frame
            scrollFrame?.size.width = x
            scrollFrame?.size.height = scrollH
            scrollFrame?.origin.y = (height - scrollH) / 2
            manager?.portraitScrollView.frame = scrollFrame ?? .zero
        }
    }
    
    func handlePnaEnded() {
        let width = view.bounds.width
        let height = view.bounds.height
        let maxW = workListView.frame.width
        let diff = width - workListView.frame.origin.x
        if diff >= maxW / 2 {
            UIView.animate(withDuration: 0.2) {
                var frame = self.workListView.frame
                frame.origin.x = width - maxW
                self.workListView.frame = frame
                self.manager?.portraitScrollView.frame = CGRectMake(0, (height - frame.size.height)/2, frame.origin.x, frame.size.height)
                self.isWorkListShow = true
            }
        }else {
            UIView.animate(withDuration: 0.2) {
                var frame = self.workListView.frame
                frame.origin.x = width
                self.workListView.frame = frame
                self.manager?.portraitScrollView.frame = CGRectMake(0, 0, width, height)
                self.isWorkListShow = false
            }
        }
    }
}

extension KuaishouViewController: GKViewControllerPushDelegate {
    func pushToNextViewController() {
        if !isWorkListShow { return }
        let vc = KuaishouDetailViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension KuaishouViewController: GKViewControllerPopDelegate {
    func navigationShouldPopOnGesture() -> Bool {
        return !isWorkListShow
    }
    
    func popGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension KuaishouViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGesture {
            let transition = panGesture.translation(in: panGesture.view)
            if transition.x < 0 {
                
            }else if transition.x > 0 {
                if isWorkListShow {
                    return true
                }
                return false
            }else {
                return false
            }
        }
        return true
    }
}
