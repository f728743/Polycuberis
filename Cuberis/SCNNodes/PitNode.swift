//
//  PitNode.swift
//  Cuberis
//

import SceneKit

class PitNode: SCNNode {
    var pitMesh: SCNNode

    init(size: Size3i) {
        pitMesh =  PitMeshNode(size: size)
        super.init()
        addChildNode(pitMesh)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
