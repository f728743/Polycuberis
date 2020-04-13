//
//  BoundingBoxNode.swift
//  Cuberis
//

import SceneKit

class BoundingBoxNode: SCNNode {
    init(around node: SCNNode) {
        super.init()
        let (minVec, maxVec) = node.boundingBox
        let w = CGFloat(maxVec.x - minVec.x)
        let h = CGFloat(maxVec.y - minVec.y)
        let d = CGFloat(maxVec.z - minVec.z)
        let boxGeometry = SCNBox(width: w, height: h, length: d, chamferRadius: 0)
        boxGeometry.firstMaterial!.diffuse.contents = UIColor.green.withAlphaComponent(0.5)
        geometry = boxGeometry
        position = SCNVector3Make((maxVec.x - minVec.x) / 2 + minVec.x,
                                  (maxVec.y - minVec.y) / 2 + minVec.y, 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
