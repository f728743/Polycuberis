//
//  GamepadScene.swift
//  Cuberis
//

import SpriteKit

class GamepadScene: SKScene {
    weak var gamepadDelegate: GamepadProtocol?

    var completion: (() -> Void)?

    var level = 0 {
        didSet {
            levelValue.text = "\(level)"
        }
    }

    var score = 0 {
        didSet {
            scoreValue.text = "\(score)"
        }
    }

    var hiScore = 0 {
        didSet {
            highScoreValue.text = "\(hiScore)"
        }
    }

    var gaugeValue = 0 {
        didSet {
            gaugeNode.value = gaugeValue
        }
    }

    private let playButton = ButtonNode(buttonImageName: "PlayButton")
    private let pauseButton = ButtonNode(buttonImageName: "PauseButton")

    private let goBackButton = ButtonNode(buttonImageName: "GoBackButton")
    private let rotateXCounterclockwiseButton = GamepadButtonNode(buttonImageName: "RotateXCounterclockwise")
    private let rotateYCounterclockwiseButton = GamepadButtonNode(buttonImageName: "RotateYCounterclockwise")
    private let rotateZCounterclockwiseButton = GamepadButtonNode(buttonImageName: "RotateZCounterclockwise")
    private let moveUpButton = GamepadButtonNode(buttonImageName: "MoveUp")
    private let moveDownButton = GamepadButtonNode(buttonImageName: "MoveDown")
    private let moveLeftButton = GamepadButtonNode(buttonImageName: "MoveLeft")
    private let moveRightButton = GamepadButtonNode(buttonImageName: "MoveRight")
    private let dropButton = GamepadButtonNode(buttonImageName: "Drop")

    private let levelLabel = SKLabelNode(text: "Level")
    private let levelValue = SKLabelNode(text: "0")
    private let scoreLabel = SKLabelNode(text: "Score")
    private let scoreValue = SKLabelNode(text: "0")
    private let highScoreLabel = SKLabelNode(text: "Hi-Score")
    private let highScoreValue = SKLabelNode(text: "0")
    private let gaugeNode: GaugeNode
    private let allButtons = SKNode()

    init(size: CGSize, sceneProjection: SceneProjection, pitDepth: Int) {
        gaugeNode = GaugeNode(fullHeight: sceneProjection.canvasRect.height, cellCount: pitDepth)
        super.init(size: size)
        addChild(allButtons)
        addChild(levelLabel)
        setupLabelFont(levelLabel, color: .gray)
        addChild(levelValue)
        setupLabelFont(levelValue, color: .white)
        addChild(scoreLabel)
        setupLabelFont(scoreLabel, color: .gray)
        addChild(scoreValue)
        setupLabelFont(scoreValue, color: .white)
        addChild(highScoreLabel)
        setupLabelFont(highScoreLabel, color: .gray)
        addChild(highScoreValue)
        setupLabelFont(highScoreValue, color: .white)

        goBackButton.action = { [unowned self] in self.completion?() }
        addChild(goBackButton)
        pauseButton.action = { [unowned self] in
            self.pauseButton.isHidden = true
            self.playButton.isHidden = false
            self.gamepadDelegate?.pause()
        }
        allButtons.addChild(pauseButton)

        gaugeNode.position = CGPoint(sceneProjection.pitRect.minX - gaugeNode.width - 10,
                                     sceneProjection.canvasRect.minY)
        allButtons.addChild(gaugeNode)

        playButton.action = { [unowned self] in
            self.playButton.isHidden = true
            self.pauseButton.isHidden = false
            self.gamepadDelegate?.resume()
        }
        allButtons.addChild(playButton)
        playButton.isHidden = true

        addGamepadButton(rotateXCounterclockwiseButton) { [unowned self] in
            self.gamepadDelegate?.rotateXCounterclockwise()
        }
        addGamepadButton(rotateYCounterclockwiseButton) { [unowned self] in
            self.gamepadDelegate?.rotateYCounterclockwise()
        }
        addGamepadButton(rotateZCounterclockwiseButton) { [unowned self] in
            self.gamepadDelegate?.rotateZCounterclockwise()
        }
        addGamepadButton(moveUpButton) { [unowned self] in self.gamepadDelegate?.moveUp() }
        addGamepadButton(moveLeftButton) { [unowned self] in self.gamepadDelegate?.moveLeft() }
        addGamepadButton(moveRightButton) { [unowned self] in self.gamepadDelegate?.moveRight() }
        addGamepadButton(moveDownButton) { [unowned self] in self.gamepadDelegate?.moveDown() }
        addGamepadButton(dropButton) { [unowned self] in self.gamepadDelegate?.drop() }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        layoutSubnodes()
        alpha = 0.0
        run(SKAction.fadeIn(withDuration: SceneConstants.scenePresentDuration * 2))
    }

    func hideButtons() {
        allButtons.run(SKAction.fadeOut(withDuration: 1))
    }

    func layoutSubnodes() {
        layoutLabels()
        layoutGoBackButton()
        layoutPlayPauseButton()
        layoutRotationButtons()
        layoutMoveButtons()
    }

    func setupLabelFont(_ label: SKLabelNode, color: UIColor) {
        label.fontName = "GillSans-Light"
        label.fontColor = color
        label.fontSize = 20
    }

    func layoutLabels() {
        let safeArea = safeAreaInsets()
        let valueInsets: CGFloat = 4
        let y = frame.height - levelLabel.frame.height - 3
        levelLabel.position = CGPoint(x: safeArea.left + levelLabel.frame.width / 2 + 100, y: y)
        levelValue.position = levelLabel.position + CGPoint(levelLabel.frame.width / 2 + valueInsets, 0)
        levelValue.horizontalAlignmentMode = .left

        scoreLabel.position = CGPoint(x: frame.midX - scoreLabel.frame.width / 2, y: y)
        scoreValue.position = scoreLabel.position + CGPoint(scoreLabel.frame.width / 2 + valueInsets, 0)
        scoreValue.horizontalAlignmentMode = .left

        highScoreLabel.position = CGPoint(x: frame.width - safeArea.right - 160, y: y)
        highScoreValue.position = highScoreLabel.position + CGPoint(highScoreLabel.frame.width / 2 + valueInsets, 0)
        highScoreValue.horizontalAlignmentMode = .left
    }

    private func addGamepadButton(_ button: GamepadButtonNode, action:@escaping (() -> Void)) {
        button.action = action
        allButtons.addChild(button)
    }

    private func layoutPlayPauseButton() {
        let safeArea = safeAreaInsets()
        let position = CGPoint(x: frame.width - safeArea.right, y: frame.height - safeArea.top) +
            goBackButton.size.mid * CGPoint(-1, -1) +
            CGPoint(-5, -5)
        pauseButton.position = position
        playButton.position = position
    }

    private func layoutGoBackButton() {
        let safeArea = safeAreaInsets()
        goBackButton.position = CGPoint(x: safeArea.left, y: frame.height - safeArea.top) +
            goBackButton.size.mid * CGPoint(1, -1) +
            CGPoint(5, -5)
    }

    private func layoutRotationButtons() {
        let spacing: CGFloat = 14
        let buttonHeight = rotateYCounterclockwiseButton.size.height
        let buttonMidW = rotateYCounterclockwiseButton.size.midW
        let anchor = CGPoint(x: safeAreaInsets().left + buttonMidW, y: frame.midY) +
            CGPoint(30, -30)
        rotateXCounterclockwiseButton.position = anchor + CGPoint(0, buttonHeight + spacing)
        rotateYCounterclockwiseButton.position = anchor
        rotateZCounterclockwiseButton.position = anchor + CGPoint(0, -(buttonHeight + spacing))
    }

    private func layoutMoveButtons() {
        let buttonHeight = moveUpButton.size.height
        let buttonWidth = moveUpButton.size.width
        let buttonMidW = moveUpButton.size.midW
        let anchor = CGPoint(x: frame.width - (buttonWidth + safeAreaInsets().right + buttonMidW), y: frame.midY) +
            CGPoint(-20, 40)
        moveUpButton.position = anchor + CGPoint(0, buttonHeight)
        moveLeftButton.position = anchor + CGPoint(-buttonWidth, 0)
        moveRightButton.position = anchor + CGPoint(buttonWidth, 0)
        moveDownButton.position = anchor + CGPoint(0, -buttonHeight)
        dropButton.position = anchor + CGPoint(0, -160)
    }
}
