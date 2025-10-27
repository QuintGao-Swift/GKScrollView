//
//  UIColor+Extension.swift
//  Example
//
//  Created by QuintGao on 2023/9/27.
//  Copyright © 2023 QuintGao. All rights reserved.
//

import UIKit

extension UIColor {
    /// hexColor
    convenience init(hex: UInt32) {
        let r: CGFloat = CGFloat((hex & 0xFF000000) >> 24) / 255.0
        let g: CGFloat = CGFloat((hex & 0x00FF0000) >> 16) / 255.0
        let b: CGFloat = CGFloat((hex & 0x0000FF00) >> 8) / 255.0
        let a: CGFloat = CGFloat(hex & 0x000000FF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
