//
//  GameViewController.swift
//  Cuberis
//

import UIKit
import SceneKit

class GameViewController: UIViewController {
    var game: Game!
    var geometry: GameGeometry!
    let moveDuration: TimeInterval = 0.1
    var gameView: GameView! { self.view as? GameView }
    var scnScene: SCNScene!
    var cameraNode: SCNNode!
    var polycube: SCNNode?
    var pitFrame: SCNNode?
    var pitContent: SCNNode?
    private var feedbackGenerator = UIImpactFeedbackGenerator(style: .light)

    override func viewDidLoad() {
        super.viewDidLoad()
        game.delegate = self
        geometry = GameGeometry(viewSize: gameView.bounds.size, pitSize: game.pit.size)
        setupView()
        setupScene()
        setupCamera()
        scnScene.rootNode.addChildNode(LightNode())
        createPit()
        game.newPolycube()
        didUpdateCells(of: game.pit)

//        let trail = SCNParticleSystem(named: "Stars.scnp", inDirectory: nil)!
//        let node = SCNNode()
//        node.position = SCNVector3(2.5, 2.5, -3)
//        node.addParticleSystem(trail)
//        scnScene.rootNode.addChildNode(node)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    func setupView() {
        gameView.gamepadDelegate = game
//        gameView.antialiasingMode = .multisampling4X
    }

    func setupScene() {
        scnScene = SCNScene()
        gameView.scene = scnScene
//        scnScene.background.contents = UIColor.black
        scnScene.background.contents = "art.scnassets/Background_Diffuse.jpg"
    }

    func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = geometry.cameraPosition
        scnScene.rootNode.addChildNode(cameraNode)
    }

    func createPit() {
        let node = geometry.createPitFrameNode()
        scnScene.rootNode.addChildNode(node)
        pitFrame = node
    }
}
