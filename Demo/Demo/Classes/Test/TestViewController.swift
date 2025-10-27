//
//  TestViewController.swift
//  Example
//
//  Created by QuintGao on 2024/1/8.
//  Copyright © 2024 QuintGao. All rights reserved.
//

import UIKit
import GKScrollView
import MJRefresh

class TestViewController: UIViewController {

    lazy var scrollView: GKScrollView = {
        let scrollView = GKScrollView()
        scrollView.gk_dataSource = self
        scrollView.gk_delegate = self
        scrollView.register(cellClass: TestCell1.self, forCellReuseIdentifier: "TestCell1")
        scrollView.register(cellClass: TestCell2.self, forCellReuseIdentifier: "TestCell2")
        scrollView.register(cellClass: TestCell3.self, forCellReuseIdentifier: "TestCell3")
//        scrollView.register(cellClass: TestCell4.self, forCellReuseIdentifier: "TestCell4")
        scrollView.register(nib: UINib.init(nibName: "TestCell4", bundle: nil), forCellReuseIdentifier: "TestCell4")
        return scrollView
    }()
    
    lazy var pageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white
        label.text = "页码切换"
        return label
    }()
    
    lazy var pageControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["1页", "2页", "3页", "4页", "5页"])
        control.addTarget(self, action: #selector(pageControlAction), for: .valueChanged)
        control.backgroundColor = .lightGray
        return control
    }()
    
    lazy var randomBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .black
        btn.setTitle("随机切换", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16)
        btn.layer.borderColor = UIColor.white.cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 15
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(randomAction), for: .touchUpInside)
        return btn
    }()
    
    lazy var nextBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .black
        btn.setTitle("下一个", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16)
        btn.layer.borderColor = UIColor.white.cgColor
        btn.layer.borderWidth = 1
        btn.layer.cornerRadius = 15
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        return btn
    }()
    
    var dataSource = [TestModel]()
    
    var page: Int = 1
    var pageSize: Int = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        setupRefresh()
        requestData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    func initUI() {
        navigationItem.title = "GKScrollView测试"
        view.backgroundColor = .black
        
        view.addSubview(scrollView)
        view.addSubview(pageLabel)
        view.addSubview(pageControl)
        view.addSubview(randomBtn)
        view.addSubview(nextBtn)
        
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(self.view)
        }
        
        pageLabel.snp.makeConstraints {
            $0.top.equalTo(self.view).offset(100)
            $0.left.equalTo(self.view).offset(20)
        }
        
        pageControl.snp.makeConstraints {
            $0.top.equalTo(pageLabel.snp.bottom).offset(10)
            $0.left.equalTo(self.view).offset(20)
            $0.right.equalTo(self.view).offset(-20)
        }
        
        randomBtn.snp.makeConstraints {
            $0.left.equalTo(self.view).offset(20)
            $0.top.equalTo(self.pageControl.snp.bottom).offset(10)
            $0.width.equalTo(80)
            $0.height.equalTo(30)
        }
        
        nextBtn.snp.makeConstraints {
            $0.right.equalTo(self.view).offset(-20)
            $0.top.equalTo(self.pageControl.snp.bottom).offset(10)
            $0.width.equalTo(80)
            $0.height.equalTo(30)
        }
    }
    
    func setupRefresh() {
        pageControl.selectedSegmentIndex = pageSize - 1
        
        scrollView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            guard let self = self else { return }
            self.page = 1
            self.requestData()
        })
        
        scrollView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
            guard let self = self else { return }
            self.page += 1
            self.requestData()
        })
    }
    
    func requestData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { [weak self] in
            guard let self = self else { return }
            if self.page == 1 {
                self.dataSource.removeAll()
            }
            for i in 0..<self.pageSize {
                let model = TestModel()
                if self.page == 1 {
                    model.pos = i
                }else {
                    model.pos = self.dataSource.count
                }
                model.test_id = "test_id_\(model.pos + 1)"
                self.dataSource.append(model)
            }
            self.scrollView.mj_header?.endRefreshing()
            self.scrollView.mj_footer?.endRefreshing()
            if self.page >= 5 {
                self.scrollView.mj_footer?.endRefreshingWithNoMoreData()
            }
            self.scrollView.reloadData()
        }
    }
    
    @objc func pageControlAction(sender: UISegmentedControl) {
        pageSize = sender.selectedSegmentIndex + 1
    }
    
    @objc func randomAction() {
        let random = dataSource.count - 1
        scrollView.scrollToCell(with: random)
    }
    
    @objc func nextAction() {
        scrollView.scrollToNextCell()
    }

}

extension TestViewController: GKScrollViewDataSource, GKScrollViewDelegate {
    func numberOfRows(in scrollView: GKScrollView) -> Int {
        dataSource.count
    }
    
    func scrollView(_ scrollView: GKScrollView, cellForRowAt indexPath: IndexPath) -> GKScrollViewCell {
        var cell: TestCell1?
        if indexPath.row % 4 == 0 {
            cell = scrollView.dequeueReusableCell(withIdentifier: "TestCell1", for: indexPath) as? TestCell1
        }else if indexPath.row % 4 == 1 {
            cell = scrollView.dequeueReusableCell(withIdentifier: "TestCell2", for: indexPath) as? TestCell1
        }else if indexPath.row % 4 == 2 {
            cell = scrollView.dequeueReusableCell(withIdentifier: "TestCell3", for: indexPath) as? TestCell1
        }else if indexPath.row % 4 == 3 {
            cell = scrollView.dequeueReusableCell(withIdentifier: "TestCell4", for: indexPath) as? TestCell1
        }
        cell?.loadData(dataSource[indexPath.row])
        return cell ?? GKScrollViewCell()
    }
}
