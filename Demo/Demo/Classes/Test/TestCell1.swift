//
//  TestCell1.swift
//  Example
//
//  Created by QuintGao on 2024/1/8.
//  Copyright © 2024 QuintGao. All rights reserved.
//

import UIKit
import GKScrollView

class TestCell1: GKScrollViewCell {

    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    required init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initUI()
    }

    func initUI() {
        addSubview(textLabel)
        textLabel.snp.makeConstraints {
            $0.center.equalTo(self)
        }
    }
    
    public func loadData(_ model: TestModel) {
        textLabel.text = "\(self.classForCoder)---\(model.pos!)"
    }
}
