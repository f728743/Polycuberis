//
//  GameScene.swift
//  Cuberis
//

import SceneKit

struct SceneConstants {
    static let scenePresentDuration: TimeInterval = 0.3
    static let polycubeMoveDuration: TimeInterval = 0.1
}

class GameScene {
    var polycube: SCNNode?
    var pitNode: PitNode
    var pitContent: SCNNode?
    var scnScene: SCNScene
    var game = GameEngine()

    init(scnScene: SCNScene) {
        self.scnScene = scnScene
        pitNode = PitNode(pitSize: game.pit.size)
        scnScene.rootNode.addChildNode(pitNode)
        game.delegate = self
    }
}

extension GameScene: GameDelegate {
    func didSpawnNew(polycube: Polycube, at position: Vector3i, rotated rotation: SCNMatrix4) {
        let node = PolycubeNode(polycube: polycube)
        node.position = SCNVector3(position + polycube.center)
        scnScene.rootNode.addChildNode(node)
        self.polycube?.removeFromParentNode()
        self.polycube = node
    }

    func didMove(by delta: Vector3i, andRotateBy rotationDelta: SCNMatrix4) {
        guard let polycube = polycube else { return }
        let duration = SceneConstants.polycubeMoveDuration
        let moveAction = SCNAction.move(by: SCNVector3(delta), duration: duration)
        polycube.runAction(moveAction)

        let child = polycube.childNodes[0]
        let from = child.transform
        let to = child.transform * rotationDelta
        let rotateAnimation = CABasicAnimation(keyPath: "transform")
        rotateAnimation.fromValue = NSValue(scnMatrix4: from)
        rotateAnimation.toValue = NSValue(scnMatrix4: to)
        rotateAnimation.duration = duration
        child.addAnimation(rotateAnimation, forKey: "rotate polycube")
        child.transform = to
    }

    func gameOver() {
        print("Game over")
    }

    func didUpdateCells(of pit: Pit) {
        let node = PitContentNode(pit: game.pit)
        scnScene.rootNode.addChildNode(node)
        pitContent?.removeFromParentNode()
        pitContent = node
    }
}
