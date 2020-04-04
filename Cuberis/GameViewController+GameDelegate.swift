//
//  GameViewController+GameDelegate.swift
//  Cuberis
//

import SceneKit

extension GameViewController: GameDelegate {
    func didSpawnNew(polycube: Polycube, at position: Vector3i, rotated rotation: SCNMatrix4) {
        let node = PolycubeNode(polycube: polycube)
        node.position = SCNVector3(position + polycube.center)
        scnScene.rootNode.addChildNode(node)
        self.polycube?.removeFromParentNode()
        self.polycube = node
    }

    func didMove(by delta: Vector3i, andRotateBy rotationDelta: SCNMatrix4) {
        guard let polycube = polycube else { return }
        let moveAction = SCNAction.move(by: SCNVector3(delta), duration: moveDuration)
        polycube.runAction(moveAction)

        let child = polycube.childNodes[0]
        let from = child.transform
        let to = child.transform * rotationDelta
        let rotateAnimation = CABasicAnimation(keyPath: "transform")
        rotateAnimation.fromValue = NSValue(scnMatrix4: from)
        rotateAnimation.toValue = NSValue(scnMatrix4: to)
        rotateAnimation.duration = moveDuration
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
