//
//  MainMenuScene.swift
//  Cuberis
//

import SpriteKit

enum MainMenuOption {
    case start(Int)
    case leaderboard
    case setup
}

func createButton(title: String) -> ButtonNode {
    let button = ButtonNode(buttonImageName: "GreenButton", title: title)
    button.fontName = "GillSans-Light"
    button.fontColor = .black
    button.fontSize = 26
    return button
}

class MainMenuScene: SKScene {
    var animatedAppearance = false
    var completion: ((MainMenuOption) -> Void)?

    let panel = SKSpriteNode(texture: SKTexture(imageNamed: "Panel"))
    let startButton = createButton(title: "START")
    let setupButton = createButton(title: "SETUP")
    let leadersButton = createButton(title: "LEADERS")
    let levelControl: NumericUpDownNode

    init(size: CGSize, level: Int) {
        levelControl = NumericUpDownNode(label: "Level:", value: level, range: Setup.levelRange)
        super.init(size: size)
        addChild(panel)
        panel.addChild(levelControl)
        startButton.action = { [unowned self] in self.completion?(.start(self.levelControl.value)) }
        panel.addChild(startButton)
        setupButton.action = { [unowned self] in self.completion?(.setup) }
        panel.addChild(setupButton)
        panel.addChild(leadersButton)
        leadersButton.action = { [unowned self] in self.completion?(.leaderboard) }

        setupPickerFont(control: levelControl)

        let spacing: CGFloat = 20
        let anchor = CGPoint(0, panel.size.midH - (startButton.size.midH + spacing))
        let step = -(startButton.size.height + spacing)
        startButton.position = anchor + CGPoint(0, 0 * step)
        setupButton.position = anchor + CGPoint(0, 1 * step)
        leadersButton.position = anchor + CGPoint(0, 2 * step)
        levelControl.position = anchor + CGPoint(0, 3 * step)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func layoutSubnodes() {
        panel.position = CGPoint(safeAreaInsets().left + panel.size.midW + 10, frame.midY)
    }

    override func didMove(to view: SKView) {
        layoutSubnodes()
        if animatedAppearance {
            alpha = 0.0
            run(SKAction.fadeIn(withDuration: SceneConstants.scenePresentDuration * 2))
        } else {
            alpha = 1.0
        }
    }
}
