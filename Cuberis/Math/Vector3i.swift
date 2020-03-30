//
//  Vector3i.swift
//  Cuberis
//

import Foundation

// swiftlint:disable shorthand_operator

// MARK: Vector3i

struct Vector3i {
    var x: Int; var y: Int; var z: Int

    init(x: Int, y: Int, z: Int) {
        self.x = x; self.y = y; self.z = z
    }

    init(_ x: Int, _ y: Int, _ z: Int) {
        self.init(x: x, y: y, z: z)
    }

    init(_ values: [Int]) {
        self.init(x: values[0], y: values[1], z: values[2])
    }

    init() {
        self.init(0, 0, 0)
    }
}

extension Vector3i {
    static func + (left: Vector3i, right: Vector3i) -> Vector3i {
        return Vector3i(left.x + right.x, left.y + right.y, left.z + right.z)
    }

    static func += (left: inout Vector3i, right: Vector3i) {
        left = left + right
    }

    static func - (left: Vector3i, right: Vector3i) -> Vector3i {
        return Vector3i(left.x - right.x, left.y - right.y, left.z - right.z)
    }

    static func -= (left: inout Vector3i, right: Vector3i) {
        left = left - right
    }
}

extension Vector3i: Codable, Equatable, CustomStringConvertible {
    static func == (left: Vector3i, right: Vector3i) -> Bool {
        return (left.x == right.x) && (left.y == right.y) && (left.z == right.z)
    }

    public var description: String { return "[\(x), \(y), \(z)]" }
}
