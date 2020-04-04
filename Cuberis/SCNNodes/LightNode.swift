//
//  PitNode.swift
//  Cuberis
//

import SceneKit

class LightNode: SCNNode {
    override init() {
        super.init()

        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.intensity = 200
        ambientLight.light?.type = .ambient
        addChildNode(ambientLight)

        let frontLight = SCNNode()
        frontLight.light = SCNLight()
        frontLight.position = SCNVector3(10, -3, 15)
        frontLight.light?.type = .omni
        addChildNode(frontLight)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
