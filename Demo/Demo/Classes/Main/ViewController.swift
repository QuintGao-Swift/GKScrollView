//
//  ViewController.swift
//  Demo
//
//  Created by QuintGao on 2024/8/22.
//

import UIKit
import GKNavigationBarSwift
import SnapKit

class ViewController: UIViewController {

    lazy var tableView = UITableView(frame: .zero, style: .plain) ~ {
        $0.dataSource = self
        $0.delegate = self
        $0.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    var dataSource: [String] = ["ZFPlayer播放",
                                "SJVideoPlayer播放",
                                "列表旋转",
                                "抖音",
                                "快手",
                                "测试"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 13.0, *) {
            let appearance = navigationController?.navigationBar.standardAppearance
            appearance?.configureWithTransparentBackground()
            appearance?.backgroundColor = .clear
            appearance?.backgroundImage = nil
            appearance?.titleTextAttributes = [.foregroundColor: UIColor.red]
            guard let appearance = appearance else { return }
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationController?.navigationBar.isTranslucent = true
        }
    }
    
    func initUI() {
        navigationController?.gk_openScrollLeftPush = true
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalTo(self.view)
        }
        navigationItem.title = "GKScrollView"
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var vc: UIViewController? = nil
        if indexPath.row == 0 {
            vc = ZFPlayerViewController()
        }else if indexPath.row == 1 {
            vc = SJPlayerViewController()
        }else if indexPath.row == 2 {
            vc = RotationViewController()
        }else if indexPath.row == 3 {
            vc = DouyinViewController()
        }else if indexPath.row == 4 {
            vc = KuaishouViewController()
        }else if indexPath.row == 5 {
            vc = TestViewController()
        }
        if let vc = vc {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

