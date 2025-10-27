//
//  VideoCell.swift
//  Demo
//
//  Created by QuintGao on 2024/8/22.
//

import UIKit
import GKScrollView
import Kingfisher
import SnapKit

protocol VideoCellDelegate: NSObjectProtocol {
    func cellClickBackBtn()
    
    func cellClickLikeBtn(cell: VideoCell)
    
    func cellClickFullscreenBtn(cell: VideoCell)
}

class VideoCell: GKScrollViewCell {
    public weak var delegate: VideoCellDelegate?
    
    lazy var coverImgView = UIImageView() ~ {
        $0.contentMode = .scaleAspectFit
        $0.isUserInteractionEnabled = true
    }
    
    required init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func initUI() {
        addSubview(coverImgView)
        coverImgView.snp.makeConstraints {
            $0.edges.equalTo(self)
        }
    }
    
    func loadData(model: VideoInfo) {
        coverImgView.kf.setImage(with: URL(string: model.poster_small))
    }
    
    func resetView() {
        
    }
    
    func scrollViewBeginDragging() {
        
    }
    
    func scrollViewDidEndDragging() {
        
    }
    
    func showLoading() {
        
    }
    
    func hideLoading() {
        
    }
    
    func setProgress(_ progress: Float) {
        
    }
}
