//
//  GKScrollViewCell.swift
//  GKScrollView
//
//  Created by QuintGao on 2023/8/17.
//

import UIKit

open class GKScrollViewCell: UIView {
    
    public init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
    }
    
    public override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
    }
    
    required public init(reuseIdentifier: String?) {
        super.init(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
        self.reuseIdentifier = reuseIdentifier
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @IBInspectable open private(set) var reuseIdentifier: String?
    
    open func prepareForReuse() {
        
    }
}
