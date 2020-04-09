//
//  GameViewController.swift
//  Cuberis
//

import UIKit
import SceneKit

class GameViewController: UIViewController {
    var sceneController: GameSceneController!
    var setup = Setup()
    var scnView: SCNView! { self.view as? SCNView }
    var scnScene: SCNScene!
    var camera: SCNNode!
    var sceneManager: SceneManager!
    var engine: GameEngine?

    var gameCameraPosition: SCNVector3 {
        SCNVector3(x: Float(setup.pitSize.width) / 2.0,
                   y: Float(setup.pitSize.height) / 2.0,
                   z: 5.0)
    }

    var menuCameraPosition: SCNVector3 {
        gameCameraPosition + SCNVector3(-2.0, 0.0, 0.0)
    }

    // todo: haptic
    private var feedbackGenerator = UIImpactFeedbackGenerator(style: .light)

    override func viewDidLoad() {
        super.viewDidLoad()
        setup.load()
        setupScene()
        setupCamera()
        sceneController = GameSceneController(scnScene: scnScene, pitSize: setup.pitSize)
        sceneManager = SceneManager(viewSize: scnView.bounds.size)
        resetGame()
    }

    override func viewDidAppear(_ animated: Bool) {
        goToMainMenu(animated: false)
    }

    func goToMainMenu(animated: Bool) {
        presentMainMenu(animated: animated) { [unowned self] selectedOption in
            switch selectedOption {
            case .start:
                self.presentGame { [unowned self] in
                    self.resetGame()
                    DispatchQueue.main.async { self.goToMainMenu(animated: true) }
                }
            case .setup:
                self.presentSetupMenu { [unowned self] newSetup in
                    print(newSetup.pitSize, newSetup.mode)
                    self.setup = newSetup
                    self.setup.save()
                    DispatchQueue.main.async { self.goToMainMenu(animated: false) }
                }
            }
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    func setupScene() {
        let scene = SCNScene()
        scene.background.contents = "art.scnassets/Background_Diffuse.jpg"
        scene.rootNode.addChildNode(LightNode())
        scnView.scene = scene
        scnScene = scene
    }

    func setupCamera() {
        camera = SCNNode()
        camera.camera = SCNCamera()
        scnScene.rootNode.addChildNode(camera)
    }

    func presentMainMenu(animated: Bool, completion: @escaping (MainMenuOption) -> Void) {
        let duration = SceneConstants.scenePresentDuration
        if animated {
            camera.runAction(SCNAction.move(to: menuCameraPosition, duration: duration))
        } else {
            camera.position = menuCameraPosition
        }
        sceneManager.mainMenu.animatedAppearance = animated
        sceneManager.mainMenu.completion = completion
        scnView.overlaySKScene = sceneManager.mainMenu
    }

    func presentGame(completion: @escaping () -> Void) {
        let duration = SceneConstants.scenePresentDuration
        camera.runAction(SCNAction.move(to: gameCameraPosition, duration: duration))
        sceneManager.gamepad.completion = completion
        sceneManager.gamepad.gamepadDelegate = engine
        scnView.overlaySKScene = sceneManager.gamepad
        engine?.newPolycube()
    }

    func presentSetupMenu(completion: @escaping (Setup) -> Void) {
        sceneManager.setup.completion = completion
        sceneManager.setup.setup = setup
        scnView.overlaySKScene = sceneManager.setup
    }

    func resetGame() {
        if let oldEngine = engine {
            oldEngine.isStopped = true // stop retaining old engine by Timer to let deinit
            oldEngine.delegate = nil
        }
        engine = GameEngine(pitSize: setup.pitSize)

        engine!.delegate = self
        sceneController.deletePolycube()
        sceneController.updateContent(of: engine!.pit)
    }
}

extension GameViewController: GameEngineDelegate {
    func didSpawnNew(polycube: Polycube, at position: Vector3i, rotated rotation: SCNMatrix4) {
        sceneController.spawnNew(polycube: polycube, at: position, rotated: rotation)
    }

    func didMove(by delta: Vector3i, andRotateBy rotationDelta: SCNMatrix4) {
        sceneController.movePolycube(by: delta, andRotateBy: rotationDelta)
    }

    func gameOver() {
        print("Game over")
    }

    func didUpdateContent(of pit: Pit) {
        sceneController.updateContent(of: pit)
    }
}
