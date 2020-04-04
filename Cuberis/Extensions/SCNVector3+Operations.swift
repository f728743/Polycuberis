//
//  SCNVector3+Operations.swift
//  Cuberis
//

import SceneKit

// swiftlint:disable shorthand_operator
extension SCNVector3 {
    public static let unit = SCNVector3(1.0, 1.0, 1.0)

    init(_ v: Vector3i) {
        self.init(x: Float(v.x), y: Float(v.y), z: Float(v.z))
    }

    init(_ v: [Float]) {
        self.init(x: v[0], y: v[1], z: v[2])
    }

    init(_ v: [Int]) {
        self.init(x: Float(v[0]), y: Float(v[1]), z: Float(v[2]))
    }

    static func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
    }

    static func += ( left: inout SCNVector3, right: SCNVector3) {
        left = left + right
    }

    static func * (vector: SCNVector3, scalar: Float) -> SCNVector3 {
        return SCNVector3Make(vector.x * scalar, vector.y * scalar, vector.z * scalar)
    }

    static func *= ( vector: inout SCNVector3, scalar: Float) {
        vector = vector * scalar
    }
}

extension SCNVector3: Equatable, Hashable, CustomStringConvertible {
    public static func == (lhs: SCNVector3, rhs: SCNVector3) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
        hasher.combine(z)
    }

    public var description: String { return "[\(x), \(y), \(z)]" }
}
