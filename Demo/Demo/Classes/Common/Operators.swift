//
//  Operators.swift
//  Demo
//
//  Created by QuintGao on 2024/8/22.
//

import Foundation

precedencegroup AppFunctionPrecedence {
    associativity: left
    higherThan: BitwiseShiftPrecedence
}

infix operator ~: AppFunctionPrecedence

public func ~ <T>(value: T, function:(inout T) throws -> Void) rethrows -> T {
    var m_value = value
    try function(&m_value)
    return m_value
}
