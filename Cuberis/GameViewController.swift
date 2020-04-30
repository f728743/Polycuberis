//
//  GameViewController.swift
//  Cuberis
//

import UIKit
import SceneKit
import GameKit

struct SceneProjection {
    let center: CGPoint
    let canvasRect: CGRect
    let pitRect: CGRect
    let ratio: CGFloat
}

extension GameViewController: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}

class GameViewController: UIViewController {
    var scene: GameScene!
    var setup: Setup
    var scnView: SCNView! { self.view as? SCNView }
    var engine: GameEngine?
    var sound = Sound()
    var leaderboard: Leaderboard
    var sceneProjection: SceneProjection {
        let pitSize = scene.pitSize
        let maxSize = max(pitSize.width, pitSize.height)
        let z = maxSize
        let sceneCenter = scnView.projectPoint(SCNVector3(0, 0, z))
        let ratio = CGFloat(sceneCenter.x - scnView.projectPoint(SCNVector3(1, 0, z)).x)
        let center = CGPoint(CGFloat(sceneCenter.x), CGFloat(sceneCenter.y))
        let canvasRect = CGRect(origin: CGPoint(center.x - CGFloat(maxSize) / 2 * ratio,
                                                center.y - CGFloat(maxSize) / 2 * ratio),
                                size: CGSize(width: CGFloat(maxSize) * ratio,
                                             height: CGFloat(maxSize) * ratio))

        let pitRect = CGRect(origin: CGPoint(center.x - CGFloat(pitSize.width) / 2 * ratio,
                                             center.y - CGFloat(pitSize.height) / 2 * ratio),
                             size: CGSize(width: CGFloat(pitSize.width) * ratio,
                                          height: CGFloat(pitSize.height) * ratio))
        return SceneProjection(center: center,
                               canvasRect: canvasRect,
                               pitRect: pitRect,
                               ratio: ratio)
    }

    // todo: haptic
    private var lightFeedback = UIImpactFeedbackGenerator(style: .light)
    private var heavyFeedback = UIImpactFeedbackGenerator(style: .heavy)

    required init?(coder: NSCoder) {
        var setup = Setup()
        setup.load()
        self.setup = setup
        leaderboard = Leaderboard(setup: setup)
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        scnView.antialiasingMode = .multisampling4X
        scene = GameScene(pitSize: setup.pitSize)
        scnView.scene = scene
    }

    override func viewDidAppear(_ animated: Bool) {
        goToMainMenu(animated: false)
        leaderboard.authenticateUser(rootViewController: self)
        leaderboard.setup = setup
    }

    func goToMainMenu(animated: Bool) {
        presentMainMenu(animated: animated) { [unowned self] selectedOption, level in
            if self.setup.level != level {
                self.setup.level = level
                self.setup.save()
            }
            switch selectedOption {
            case .start:
                self.startGame()
                self.presentGame { [unowned self] in
                    self.scene.hideGameOver()
                    self.processScores { [unowned self] in
                        self.scene.pit.isHidden = false
                        self.stopGame()
                        DispatchQueue.main.async { self.goToMainMenu(animated: true) }
                    }
                }
            case .leaderboard:
                self.scene.pit.isHidden = true
                self.presentLeaderboard { [unowned self] in
                    DispatchQueue.main.async {
                        self.scene.pit.isHidden = false
                        self.goToMainMenu(animated: false)
                    }
                }
            case .setup:
                self.presentSetupMenu { [unowned self] newSetup in
                    self.setup = newSetup
                    self.setup.save()
                    self.leaderboard.setup = newSetup
                    self.leaderboard.upateLocalPlayerScore()
                    DispatchQueue.main.async { self.goToMainMenu(animated: false) }
                }
            }
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    func shiftedPitPosition(xOffset: CGFloat) -> SCNVector3 {
        let centrOffset = (scnView.bounds.width - xOffset - sceneProjection.pitRect.width) / 2
        let x = (xOffset - sceneProjection.pitRect.minX + centrOffset) / sceneProjection.ratio
        return SCNVector3(x, 0, 0)
    }

    func processScores(completion: @escaping () -> Void) {
        guard let score = engine?.statistics.score else { fatalError("Engine fucked up") }
        engine = nil
        if score > leaderboard.localPlayerScoreValue {
            scene.pit.isHidden = true
            leaderboard.report(score: score) { [unowned self] error in
                if error != nil { print(error!) }
                let newRecord = PersonalRecordScene(size: self.scnView.bounds.size)
                newRecord.caption = "\(self.setup.description) High Score"  // TODO: show congratz instead
                // congratz on a new personal record
                newRecord.completion = completion
                self.scnView.overlaySKScene = newRecord
            }
        } else {
            leaderboard.upateLocalPlayerScore()
            completion()
        }
    }

    func presentMainMenu(animated: Bool, completion: @escaping (MainMenuOption, Int) -> Void) {
        let mainMenu = MainMenuScene(size: scnView.bounds.size, level: setup.level)
        let safeArea = safeAreaInsets()
        scene.alignPit(withOffset: shiftedPitPosition(xOffset: safeArea.left + 242), animated: animated)
        mainMenu.animatedAppearance = animated
        mainMenu.completion = completion
        scnView.overlaySKScene = mainMenu
    }

    func presentGame(completion: @escaping () -> Void) {
        scene.alignPit(animated: true)
        let gamepad = GamepadScene(size: scnView.bounds.size,
                                   sceneProjection: sceneProjection,
                                   pitDepth: setup.pitSize.depth)
        gamepad.completion = completion
        gamepad.level = setup.level
        gamepad.hiScore = leaderboard.bestScoreValue
        gamepad.gamepadDelegate = engine
        scnView.overlaySKScene = gamepad
    }

    func presentLeaderboard(completion: @escaping () -> Void) {
        let highScoreTable = LeaderboardScene(size: scnView.bounds.size)
        highScoreTable.caption = "\(setup.description) High Score"
        leaderboard.loadHighScores { rows in
            highScoreTable.rows = rows
        }
        highScoreTable.completion = completion
        scnView.overlaySKScene = highScoreTable
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
        scene.deletePolycube()
        scene.clearPit()
    }

    func startGame() {
        engine = GameEngine(pitSize: setup.pitSize, polycubeSet: setup.polycubeSet, level: setup.level)
        engine!.delegate = self
        scene.updateContent(of: engine!.pit)
        engine!.start()
    }
}

extension GameViewController: SetupSceneDelegate {
    func changed(pitSize: Size3i) {
        scene.pitSize = pitSize
        let safeArea = safeAreaInsets()
        scene.alignPit(withOffset: shiftedPitPosition(xOffset: safeArea.left + 242), animated: false)
    }
}

extension GameViewController: GameEngineDelegate {
    func didSpawnNew(polycube: Polycube, at position: Vector3i, rotated rotation: SCNMatrix4) {
        scene.spawnNew(polycube: polycube, at: position, rotated: rotation)
    }

    func didMove(by delta: Vector3i, andRotateBy rotationDelta: SCNMatrix4, moveType: MoveType) {
        guard let gamepad = scnView.overlaySKScene as? GamepadScene else { return }
        scene.movePolycube(by: delta, andRotateBy: rotationDelta)
        if moveType != .timerStep {
            lightFeedback.impactOccurred()
            sound.play(.move, on: gamepad)
        }
    }

    func impactOccurred(after move: MoveType) {
        if move == .move || move == .rotation {
            heavyFeedback.impactOccurred()
            heavyFeedback.impactOccurred()
        }
    }

    func gameOver(with statistics: Statistics) {
        scene.deletePolycube()
        guard let gamepad = scnView.overlaySKScene as? GamepadScene else { fatalError("Internal error") }
        gamepad.hideButtons()
        scene.showGameOver()
    }

    func didUpdateContent(of pit: Pit, layersCleared: Int, isPitEmpty: Bool) {
        scene.updateContent(of: pit)
        guard let gamepad = scnView.overlaySKScene as? GamepadScene else { return }
        heavyFeedback.impactOccurred()
        if isPitEmpty {
            sound.play(.empty, on: gamepad)
        } else if layersCleared > 0 {
            sound.play(.layer, on: gamepad)
        } else {
            sound.play(.hit, on: gamepad)
        }
        gamepad.gaugeValue = pit.pileHeight
    }

    func didChangeLevel(to level: Int) {
        guard let gamepad = scnView.overlaySKScene as? GamepadScene else { return }
        sound.play(.levelUp, on: gamepad)
        gamepad.level = level
    }

    func didUpdate(statistics: Statistics) {
        guard let gamepad = scnView.overlaySKScene as? GamepadScene else { return }
        gamepad.score = statistics.score
    }
}
