//
//  VideoWortListView.swift
//  Example
//
//  Created by QuintGao on 2023/10/12.
//  Copyright © 2023 QuintGao. All rights reserved.
//

import UIKit
import SnapKit

class VideoWortListView: UIView {

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        layout.itemSize = CGSizeMake(54, 95)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initUI()
    }
    
    func initUI() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(self)
        }
    }
}

extension VideoWortListView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .gray
        return cell
    }
}
