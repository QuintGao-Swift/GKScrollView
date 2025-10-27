//
//  ZFPlayerViewController.swift
//  Example
//
//  Created by QuintGao on 2023/9/25.
//  Copyright © 2023 QuintGao. All rights reserved.
//

import UIKit

class ZFPlayerViewController: VideoPlayerViewController {

    var statusBarStyle: UIStatusBarStyle = .lightContent
    
    override func viewDidLoad() {
        self.manager = ZFPlayerManager()
        self.manager?.viewController = self
        
        super.viewDidLoad()

        self.navigationItem.title = "ZFPlayer播放"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "跳转", style: .plain, target: self, action: #selector(jump))
    }
    
    @objc func jump() {
        let vc = UIViewController()
        vc.view.backgroundColor = .red
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func showNavBar() {
        let dic = [NSAttributedString.Key.foregroundColor: UIColor.gray, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .white
            appearance.shadowColor = .white
            appearance.titleTextAttributes = dic
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.isTranslucent = false
        }else {
            navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
            navigationController?.navigationBar.titleTextAttributes = dic
        }
    }
    
    func hideNavBar() {
        
    }
}
