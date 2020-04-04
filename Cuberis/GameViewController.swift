//
//  GameViewController.swift
//  Cuberis
//

import UIKit
import SceneKit

struct SceneConstants {
    static let presentDuration: TimeInterval = 0.3
}

class GameViewController: UIViewController {

    var setup = loadSetup()
    var game: Game!
    let moveDuration: TimeInterval = 0.1
    var scnView: SCNView! { self.view as? SCNView }
    var scnScene: SCNScene!
    var camera: SCNNode!
    var polycube: SCNNode?

    var pitNode: PitNode!

    var pitContent: SCNNode?

    var mainMenuScene: MainMenuScene!
    var gamepadScene: GamepadScene!

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

        game.delegate = self

        setupScene()
        setupCamera()
        scnScene.rootNode.addChildNode(LightNode())

        pitNode = PitNode(pitSize: game.pit.size)
        scnScene.rootNode.addChildNode(pitNode)
        didUpdateCells(of: game.pit)

        let viewSize = scnView.bounds.size
        mainMenuScene = MainMenuScene(size: viewSize)
        gamepadScene = GamepadScene(size: viewSize)
        gamepadScene.gamepadDelegate = game
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
                self.game.newPolycube()
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
        scnScene = SCNScene()
        scnView.scene = scnScene
        scnScene.background.contents = "art.scnassets/Background_Diffuse.jpg"
    }

    func setupCamera() {
        camera = SCNNode()
        camera.camera = SCNCamera()
        scnScene.rootNode.addChildNode(camera)
    }

    func presentMainMenu(setup: Setup, animated: Bool, completion: @escaping (MainMenuOption) -> Void) {
        if animated {
            camera.runAction(SCNAction.move(to: menuCameraPosition, duration: SceneConstants.presentDuration))
        } else {
            camera.position = menuCameraPosition
        }
        mainMenuScene.completion = completion
        scnView.overlaySKScene = mainMenuScene
    }

    func presentGame(setup: Setup, completion: @escaping () -> Void) {
        camera.runAction(SCNAction.move(to: gameCameraPosition, duration: SceneConstants.presentDuration))
        scnView.overlaySKScene = gamepadScene
        gamepadScene.completion = completion
    }

    func presentSetupMenu(setup: Setup, completion: (Setup?) -> Void) {
        print("presentSetupMenu")

        let setup = Setup(speed: 0,
                          pitSize: Size3i(width: 5, height: 5, depth: 12),
                          polycubeSet: PolycubeSet(basic: false, flat: true, maxSize: 5))
        completion(setup)
    }

}
