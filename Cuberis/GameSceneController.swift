//
//  GameSceneController.swift
//  Cuberis
//

import SceneKit

struct SceneConstants {
    static let scenePresentDuration: TimeInterval = 0.3
    static let polycubeMoveDuration: TimeInterval = 0.1
}

enum CameraPosition {
    case menu
    case game
}

class GameSceneController {
    var pitSize: Size3i {
        didSet {
            let node = PitNode(size: pitSize)
            scnScene.rootNode.addChildNode(node)
            pit.removeFromParentNode()
            pit = node
            moveCamera(to: cameraPosition, animated: false)
        }
    }
    var scnScene: SCNScene
    var pit: SCNNode
    var polycube: SCNNode?
    var pitContent: SCNNode?
    var camera: SCNNode
    var cameraPosition = CameraPosition.menu
    var gameCameraLocation: SCNVector3 {
        SCNVector3(x: Float(pitSize.width) / 2.0,
                   y: Float(pitSize.height) / 2.0,
                   z: Float(max(pitSize.width, pitSize.height)))
    }

 // 3 -1.185
 // 5 -2

    var menuCameraLocation: SCNVector3 {
        gameCameraLocation + SCNVector3(-Float(max(pitSize.width, pitSize.height)) / 2.7, 0.0, 0.0)
    }

    init(pitSize: Size3i) {
        self.pitSize = pitSize
        scnScene = SCNScene()
        scnScene.background.contents = "art.scnassets/Background_Diffuse.jpg"
        scnScene.rootNode.addChildNode(LightNode())
        camera = SCNNode()
        camera.camera = SCNCamera()
        scnScene.rootNode.addChildNode(camera)

        pit = PitNode(size: pitSize)
        scnScene.rootNode.addChildNode(pit)
    }

    func deletePolycube() {
        self.polycube?.removeFromParentNode()
        polycube = nil
    }

    func clearPit() {
        self.pitContent?.removeFromParentNode()
        pitContent = nil
    }

    func moveCamera(to position: CameraPosition, animated: Bool) {
        cameraPosition = position
        var location = SCNVector3()
        switch position {
        case .menu:
            location = menuCameraLocation
        case .game:
            location = gameCameraLocation
        }
        if animated {
            camera.runAction(SCNAction.move(to: location, duration: SceneConstants.scenePresentDuration))
        } else {
            camera.position = location
        }
    }

    func spawnNew(polycube: Polycube, at position: Vector3i, rotated rotation: SCNMatrix4) {
        let node = PolycubeNode(polycube: polycube)
        node.position = SCNVector3(position + polycube.center)
        pit.addChildNode(node)
        self.polycube?.removeFromParentNode()
        self.polycube = node
    }

    func movePolycube(by delta: Vector3i, andRotateBy rotationDelta: SCNMatrix4) {
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

    func updateContent(of pit: Pit) {
        let node = PitContentNode(pit: pit)
        self.pit.addChildNode(node)
        pitContent?.removeFromParentNode()
        pitContent = node
    }
}
