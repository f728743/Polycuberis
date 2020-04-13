//
//  GameOverNode.swift
//  Cuberis
//

import SceneKit

class GameOverNode: SCNNode {
    override init() {
        super.init()
        let text = "Game Over"
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 5),
                                                         .kern: -0.6]
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        let textGeometry = SCNText(string: attributedText, extrusionDepth: 0.5)
        textGeometry.chamferRadius = 0.1
        textGeometry.flatness = 0.01
        geometry = textGeometry
        let (minVec, maxVec) = boundingBox
        pivot = SCNMatrix4MakeTranslation((maxVec.x - minVec.x) / 2, maxVec.y - minVec.y, 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
