//
//  CGPoint+Extension.swift
//  Cuberis
//

import UIKit

extension CGPoint {
    static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }

    static func * (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x * right.x, y: left.y * right.y)
    }

    init(_ x: CGFloat, _ y: CGFloat) {
        self.init(x: x, y: y)
    }
}
