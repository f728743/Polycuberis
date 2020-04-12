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

    // todo: haptic
    private var feedbackGenerator = UIImpactFeedbackGenerator(style: .light)

    override func viewDidLoad() {
        super.viewDidLoad()
        setup.load()
        sceneController = GameSceneController(pitSize: setup.pitSize)
        scnView.scene = sceneController.scnScene
    }

    override func viewDidAppear(_ animated: Bool) {
        goToMainMenu(animated: false)
    }

    func goToMainMenu(animated: Bool) {
        presentMainMenu(animated: animated) { [unowned self] selectedOption in
            switch selectedOption {
            case let .start(level):
                self.startGame(level: level)
                self.presentGame { [unowned self] in
                    self.stopGame()
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
        sceneController.moveCamera(to: .menu, animated: animated)
        let mainMenu = MainMenuScene(size: scnView.bounds.size, level: setup.level)
        mainMenu.animatedAppearance = animated
        mainMenu.completion = completion
        scnView.overlaySKScene = mainMenu
    }

    func presentGame(completion: @escaping () -> Void) {
        sceneController.moveCamera(to: .game, animated: true)
        let gamepad = GamepadScene(size: scnView.bounds.size)
        gamepad.completion = completion
        gamepad.level = setup.level
        gamepad.gamepadDelegate = engine
        scnView.overlaySKScene = gamepad
    }

    func presentSetupMenu(completion: @escaping (Setup) -> Void) {
        let setupMenu = SetupScene(size: scnView.bounds.size)
        setupMenu.completion = completion
        setupMenu.setup = setup
        setupMenu.setupDelegate = self
        scnView.overlaySKScene = setupMenu
    }

    func stopGame() {
        engine = nil
        sceneController.deletePolycube()
        sceneController.clearPit()
    }

    func startGame(level: Int) {
        setup.level = level
        setup.save()
        engine = GameEngine(pitSize: setup.pitSize, polycubeSet: setup.polycubeSet, level: level)
        engine!.delegate = self
        sceneController.updateContent(of: engine!.pit)
        engine!.start()
    }
}

extension GameViewController: SetupSceneDelegate {
    func changed(pitSize: Size3i) {
        sceneController.pitSize = pitSize
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

    func didChangeLevel(to level: Int) {
        guard let gamepad = scnView.overlaySKScene as? GamepadScene else {
            fatalError("Internal error")
        }
        gamepad.level = level
    }

    func didUpdate(statistics: Statistics) {
        guard let gamepad = scnView.overlaySKScene as? GamepadScene else {
            fatalError("Internal error")
        }
        gamepad.score = statistics.score
    }

    func didСlearLayers(count: Int, andPit isEmpty: Bool) {
        print("Clear \(count) layer(s)")
        if isEmpty { print("Pit is empty") }
    }
}
