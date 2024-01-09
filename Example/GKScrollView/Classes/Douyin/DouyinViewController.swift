//
//  DouyinViewController.swift
//  Example
//
//  Created by QuintGao on 2023/10/11.
//  Copyright © 2023 QuintGao. All rights reserved.
//

import UIKit

class DouyinViewController: VideoPlayerViewController {

    override func viewDidLoad() {
        
        manager = DouyinManager()
        
        super.viewDidLoad()

        navigationItem.title = "抖音"
    }
}
