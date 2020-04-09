//
//  Size3i.swift
//  Cuberis
//

import Foundation

struct Size3i {
    let width: Int
    let height: Int
    let depth: Int
}

extension Size3i: Equatable {
    public static func == (lhs: Size3i, rhs: Size3i) -> Bool {
        return lhs.width == rhs.width && lhs.height == rhs.height && lhs.depth == rhs.depth
    }
}
