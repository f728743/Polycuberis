//
//  PitNode.swift
//  Cuberis
//

import SceneKit

class PitNode: SCNNode {
    var pitMesh: SCNNode

    init(pitSize: Size3i) {
        pitMesh =  PitMeshNode(size: pitSize)
        super.init()

        addChildNode(pitMesh)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
