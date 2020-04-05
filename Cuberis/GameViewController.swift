//
//  GameViewController.swift
//  Cuberis
//

import UIKit
import SceneKit

class GameViewController: UIViewController {
    var sceneController: GameSceneController!
    var setup = loadSetup()
    var scnView: SCNView! { self.view as? SCNView }
    var scnScene: SCNScene!
    var camera: SCNNode!
    var mainMenuScene: MainMenuScene!
    var gamepadScene: GamepadScene!
    var engine: GameEngine!

    var gameCameraPosition: SCNVector3 {
        SCNVector3(x: Float(setup.pitSize.width) / 2.0,
                          y: Float(setup.pitSize.height) / 2.0,
                          z: 5.0)
    }

    var menuCameraPosition: SCNVector3 {
        gameCameraPosition + SCNVector3(-2.0, 0.0, 0.0)
    }

    private var feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    private var firstTimeMainMenu = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        setupCamera()
        sceneController = GameSceneController(scnScene: scnScene, pitSize: setup.pitSize)
        let viewSize = scnView.bounds.size
        mainMenuScene = MainMenuScene(size: viewSize)
        gamepadScene = GamepadScene(size: viewSize)
        engine = GameEngine(pitSize: setup.pitSize)
        engine.delegate = sceneController
        schedulePresentMainMenu()
    }

    func schedulePresentMainMenu() {
        DispatchQueue.main.async { self.presentMainMenu() }
    }

    func presentMainMenu() {
        print("presentMainMenu")
        presentMainMenu(setup: setup, animated: !firstTimeMainMenu) { selectedOption in
            self.firstTimeMainMenu = false
            switch selectedOption {
            case .start:
                self.presentGame(setup: self.setup) {
                    self.schedulePresentMainMenu()
                }
            case .options:
                self.presentSetupMenu(setup: self.setup) { newSetup in
                    if let newSetup = newSetup {
                        self.setup = newSetup
                    }
                    self.schedulePresentMainMenu()
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

    func presentMainMenu(setup: Setup, animated: Bool, completion: @escaping (MainMenuOption) -> Void) {
        let duration = SceneConstants.scenePresentDuration
        if animated {
            camera.runAction(SCNAction.move(to: menuCameraPosition, duration: duration))
        } else {
            camera.position = menuCameraPosition
        }
        mainMenuScene.completion = completion
        scnView.overlaySKScene = mainMenuScene
    }

    func presentGame(setup: Setup, completion: @escaping () -> Void) {
        let duration = SceneConstants.scenePresentDuration
        camera.runAction(SCNAction.move(to: gameCameraPosition, duration: duration))
        gamepadScene.completion = completion
        gamepadScene.gamepadDelegate = engine
        scnView.overlaySKScene = gamepadScene
        engine.newPolycube()
    }

    func presentSetupMenu(setup: Setup, completion: (Setup?) -> Void) {
        print("presentSetupMenu")

        let setup = Setup(speed: 0,
                          pitSize: Size3i(width: 5, height: 5, depth: 12),
                          polycubeSet: PolycubeSet(basic: false, flat: true, maxSize: 5))
        completion(setup)
    }

}
