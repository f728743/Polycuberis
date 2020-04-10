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
        sceneController = GameSceneController(pitSize: setup.pitSize)
        scnView.scene = sceneController.scnScene
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

    func presentMainMenu(animated: Bool, completion: @escaping (MainMenuOption) -> Void) {
        sceneController.moveCamera(to: menuCameraPosition, animated: animated)
        let mainMenu = MainMenuScene(size: scnView.bounds.size)
        mainMenu.animatedAppearance = animated
        mainMenu.completion = completion
        scnView.overlaySKScene = mainMenu
    }

    func presentGame(completion: @escaping () -> Void) {
        sceneController.moveCamera(to: gameCameraPosition, animated: true)
        let gamepad = GamepadScene(size: scnView.bounds.size)
        gamepad.completion = completion
        gamepad.gamepadDelegate = engine
        scnView.overlaySKScene = gamepad
        engine?.newPolycube()
    }

    func presentSetupMenu(completion: @escaping (Setup) -> Void) {
        let setupMenu = SetupScene(size: scnView.bounds.size)
        setupMenu.completion = completion
        setupMenu.setup = setup
        scnView.overlaySKScene = setupMenu
    }

    func resetGame() {
        if let oldEngine = engine {
            oldEngine.isStopped = true // stop retaining old engine by existing Timer to let deinit
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
