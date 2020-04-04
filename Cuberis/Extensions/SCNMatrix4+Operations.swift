//
//  SCNMatrix4+Operations.swift
//  Cuberis
//

import SceneKit

public func SCNMatrix4MakeTranslation(_ t: SCNVector3) -> SCNMatrix4 {
    return SCNMatrix4MakeTranslation(t.x, t.y, t.z)
}

extension SCNVector3 {
    static func * (left: SCNVector3, right: SCNMatrix4) -> SCNVector3 {
        return SCNVector3(
            x: left.x * right.m11 + left.y * right.m12 + left.z * right.m13,
            y: left.x * right.m21 + left.y * right.m22 + left.z * right.m23,
            z: left.x * right.m31 + left.y * right.m32 + left.z * right.m33
        )
    }
}

extension SCNMatrix4 {

    func transposed() -> SCNMatrix4 {
        return SCNMatrix4(m11: m11, m12: m21, m13: m31, m14: m41,
                          m21: m12, m22: m22, m23: m32, m24: m42,
                          m31: m13, m32: m23, m33: m33, m34: m43,
                          m41: m14, m42: m24, m43: m34, m44: m44)
    }

    static func * (left: SCNMatrix4, right: SCNMatrix4) -> SCNMatrix4 {
        return SCNMatrix4Mult(left, right)
    }
}
