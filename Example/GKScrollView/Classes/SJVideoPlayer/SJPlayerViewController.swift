//
//  SJPlayerViewController.swift
//  Example
//
//  Created by QuintGao on 2023/10/11.
//  Copyright © 2023 QuintGao. All rights reserved.
//

import UIKit

class SJPlayerViewController: VideoPlayerViewController {

    override func viewDidLoad() {
        manager = SJPlayerManager()
        
        super.viewDidLoad()

        navigationItem.title = "SJVideoPlayer播放"
    }
}
