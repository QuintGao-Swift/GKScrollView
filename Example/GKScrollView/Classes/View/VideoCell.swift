//
//  VideoCell.swift
//  Example
//
//  Created by QuintGao on 2023/9/25.
//  Copyright © 2023 QuintGao. All rights reserved.
//

import UIKit
import GKScrollView
import Kingfisher

protocol VideoCellDelegate: NSObjectProtocol {
    func cellClickBackBtn()
    
    func cellClickLikeBtn(cell: VideoCell)
    
    func cellClickFullscreenBtn(cell: VideoCell)
}

class VideoCell: GKScrollViewCell {

    public weak var delegate: VideoCellDelegate?
    
    public lazy var coverImgView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.isUserInteractionEnabled = true
        return imgView
    }()

    required init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        initUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func initUI() {
        addSubview(coverImgView)
        coverImgView.snp.makeConstraints {
            $0.edges.equalTo(self)
        }
    }
    
    public func loadData(model: VideoModel) {
//        coverImgView.kf.setImage(with: URL(string: model.poster_small))
        coverImgView.kf.setImage(with: URL(string: model.poster_small))
    }
    
    public func resetView() {
        
    }
    
    public func scrollViewBeginDragging() {
        
    }
    
    public func scrollViewDidEndDragging() {
        
    }
    
    public func showLoading() {
        
    }
    
    public func hideLoading() {
        
    }
    
    public func setProgress(_ progress: Float) {
        
    }
}
