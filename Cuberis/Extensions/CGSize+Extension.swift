//
//  CGSize+Extension.swift
//  Cuberis
//

import UIKit

extension CGSize {
    public var mid: CGPoint { CGPoint(x: width / 2, y: height / 2) }
    public var midW: CGFloat { width / 2 }
    public var midH: CGFloat { height / 2 }
}
