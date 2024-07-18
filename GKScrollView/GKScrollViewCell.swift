//
//  GKScrollViewCell.swift
//  GKScrollView
//
//  Created by QuintGao on 2023/8/17.
//

import UIKit

open class GKScrollViewCell: UIView {
    
    @IBInspectable open private(set) var reuseIdentifier: String?
    
    public init() {
        super.init(frame: UIScreen.main.bounds)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
    }
    
    public required init(reuseIdentifier: String?) {
        super.init(frame: UIScreen.main.bounds)
        self.reuseIdentifier = reuseIdentifier
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    open func prepareForReuse() {
        
    }
}
