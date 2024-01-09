//
//  VideoPlayerViewController.swift
//  Example
//
//  Created by QuintGao on 2023/9/25.
//  Copyright © 2023 QuintGao. All rights reserved.
//

import UIKit
import Alamofire
import HandyJSON
import MJRefresh

class VideoPlayerViewController: UIViewController {

    var page: Int = 1
    var total: Int = 10
    var pageSize: Int = 5
    
    var manager: VideoManager?
    
    var isInsertFront: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        setupRefresh()
        requestData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
//        manager?.portraitScrollView.frame = view.bounds
    }
    
    func initUI() {
        view.backgroundColor = .black
        guard let manager = manager else { return }
        view.addSubview(manager.portraitScrollView)
        manager.portraitScrollView.frame = view.bounds
    }
    
    func setupRefresh() {
        manager?.portraitScrollView.mj_header = MJRefreshNormalHeader { [weak self] in
            guard let self = self else { return }
            self.requestNewData()
        }
        
        let footer = MJRefreshAutoNormalFooter { [weak self] in
            guard let self = self else { return }
            self.requestMoreData()
        }
        footer.isAutomaticallyRefresh = false
        manager?.portraitScrollView.mj_footer = footer
    }
    
    func requestNewData() {
        page = 1
        requestData()
    }
    
    func requestMoreData() {
        page += 1
        requestData()
    }
    
    func requestNewDataInsertFront() {
        isInsertFront = true
        requestData()
    }

    func requestData() {
        let url = "https://haokan.baidu.com/haokan/ui-web/video/rec?tab=recommend&act=pcFeed&pd=pc&num=\(pageSize)"
        
        AF.request(url, method: .get).response(queue: DispatchQueue.main) { [weak self] response in
            guard let self = self else { return }
            switch response.result {
            case .success:
                guard let data = response.data else { return }
                guard let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as! [String: Any] else { return }
                if let status = json["status"] as? Int, status == 0 {
                    guard let data = json["data"] as? [String: Any] else { return }
                    guard let response = data["response"] as? [String: Any] else { return }
                    guard let list = response["videos"] as? [Any] else { return }
                    if let lists = JSONDeserializer<VideoModel>.deserializeModelArrayFrom(array: list) as? [VideoModel] {
                        guard let manager = self.manager else { return }
                        
                        if self.isInsertFront {
                            self.isInsertFront = false
                            manager.dataSource.insert(contentsOf: lists, at: manager.dataSource.startIndex)
                            manager.portraitScrollView.mj_header?.endRefreshing()
                            manager.portraitScrollView.mj_footer?.endRefreshing()
                            if self.page >= self.total {
                                self.manager?.portraitScrollView.mj_footer?.endRefreshingWithNoMoreData()
                            }
                            let index = lists.count + manager.currentIndex
                            manager.reloadData(with: index)
                        }else {
                            if self.page == 1 {
                                manager.dataSource.removeAll()
                            }
                            manager.dataSource.append(contentsOf: lists)
                            manager.portraitScrollView.mj_header?.endRefreshing()
                            manager.portraitScrollView.mj_footer?.endRefreshing()
                            if self.page >= self.total {
                                manager.portraitScrollView.mj_footer?.endRefreshingWithNoMoreData()
                            }
                            // 解决先顶部插入数据清空后切换索引引起的崩溃问题
                            
                            if manager.portraitScrollView.defaultIndex < 0 || manager.portraitScrollView.defaultIndex >= manager.dataSource.count {
                                manager.portraitScrollView.defaultIndex = 0
                            }
                            manager.reloadData()
                        }
                    }
                }
                
            case .failure:
                self.manager?.portraitScrollView.mj_header?.endRefreshing()
                self.manager?.portraitScrollView.mj_footer?.endRefreshing()
            }
        }
    }
}
