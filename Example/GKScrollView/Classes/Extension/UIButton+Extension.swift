//
//  UIButton+Extension.swift
//  Example
//
//  Created by QuintGao on 2023/9/25.
//  Copyright © 2023 QuintGao. All rights reserved.
//

import UIKit

var topNameKey: Void?
var rightNameKey: Void?
var bottomNameKey: Void?
var leftNameKey: Void?

extension UIButton {
    public func setEnlargeEdge(size: CGFloat) {
        objc_setAssociatedObject(self, &topNameKey, size, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        objc_setAssociatedObject(self, &rightNameKey, size, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        objc_setAssociatedObject(self, &bottomNameKey, size, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        objc_setAssociatedObject(self, &leftNameKey, size, .OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
    
    public func setEnlargeEdge(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        objc_setAssociatedObject(self, &topNameKey, top, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        objc_setAssociatedObject(self, &leftNameKey, left, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        objc_setAssociatedObject(self, &bottomNameKey, bottom, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        objc_setAssociatedObject(self, &rightNameKey, right, .OBJC_ASSOCIATION_COPY_NONATOMIC)
    }
    
    func enlargedRect() -> CGRect {
        guard let topEdge = objc_getAssociatedObject(self, &topNameKey) as? CGFloat else { return bounds}
        guard let rightEdge = objc_getAssociatedObject(self, &rightNameKey) as? CGFloat else { return bounds }
        guard let bottomEdge = objc_getAssociatedObject(self, &bottomNameKey) as? CGFloat else { return bounds }
        guard let leftEdge = objc_getAssociatedObject(self, &leftNameKey) as? CGFloat else { return bounds }
        return CGRect(x: bounds.origin.x - leftEdge,
                      y: bounds.origin.y - topEdge,
                      width: bounds.size.width + leftEdge + rightEdge,
                      height: bounds.size.height + topEdge + bottomEdge)
    }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let rect = enlargedRect()
        if CGRectEqualToRect(rect, bounds) {
            return super.point(inside: point, with: event)
        }
        return CGRectContainsPoint(rect, point) ? true : false
    }
}
