//
//  VideoPlayerViewController.swift
//  Demo
//
//  Created by QuintGao on 2024/8/22.
//

import UIKit
import RxNetworks
import NSObject_Rx
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

    func initUI() {
        view.backgroundColor = .black
        guard let manager else { return }
        view.addSubview(manager.portraitScrollView)
        manager.portraitScrollView.frame = view.bounds
    }
    
    func setupRefresh() {
        manager?.portraitScrollView.mj_header = MJRefreshNormalHeader { [weak self] in
            guard let self else { return }
            self.requestNewData()
        }
        
        let footer = MJRefreshAutoNormalFooter { [weak self] in
            guard let self else { return }
            self.requestMoreData()
        }
    }
    
    func requestNewData() {
        self.page = 1
        self.requestData()
    }
    
    func requestMoreData() {
        self.page += 1
        self.requestData()
    }
    
    func requestData() {
        VideoAPI.getVideoList("recommend", pageSize)
            .request()
            .mapHandyJSON(HandyDataModel<VideoData>.self)
            .compactMap { $0.data }
            .subscribe { [weak self] event in
                guard let self else { return }
                switch event {
                case let .next(data):
                    if self.isInsertFront {
                        self.isInsertFront = false
                        if let manager {
                            manager.dataSource.insert(contentsOf: data.response.videos, at: manager.dataSource.startIndex)
                            manager.portraitScrollView.mj_header?.endRefreshing()
                            manager.portraitScrollView.mj_footer?.endRefreshing()
                            if self.page >= self.total {
                                manager.portraitScrollView.mj_footer?.endRefreshingWithNoMoreData()
                            }
                            let index = data.response.videos.count + manager.currentIndex
                            manager.reloadData(with: index)
                        }
                    }else {
                        if self.page == 1 {
                            self.manager?.dataSource.removeAll()
                        }
                        if let manager {
                            manager.dataSource.append(contentsOf: data.response.videos)
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
                case .error:
                    self.manager?.portraitScrollView.mj_header?.endRefreshing()
                    self.manager?.portraitScrollView.mj_footer?.endRefreshing()
                    break
                default: break
                }
            }.disposed(by: rx.disposeBag)
    }
}
