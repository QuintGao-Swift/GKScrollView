//
//  RotationViewController.swift
//  Example
//
//  Created by QuintGao on 2023/10/11.
//  Copyright © 2023 QuintGao. All rights reserved.
//

import UIKit

class RotationViewController: VideoPlayerViewController {

    override func viewDidLoad() {
        manager = TestManager()
        
        super.viewDidLoad()

        navigationItem.title = "旋转"
    }
}
