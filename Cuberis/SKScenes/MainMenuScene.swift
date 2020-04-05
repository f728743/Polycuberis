//
//  MainMenuScene.swift
//  Cuberis
//

import SpriteKit

enum MainMenuOption: String {
   case start
   case options
}

private func createButton(title: String, option: MainMenuOption) -> ButtonNode {
    let button = ButtonNode(buttonImageName: "GreenButton", title: title)
    button.name = option.rawValue
    button.fontName = "GillSans-Light"
    button.fontColor = .black
    button.fontSize = 26
    return button
}

class MainMenuScene: SKScene {
    var completion: ((MainMenuOption) -> Void)?

    let panel = SKSpriteNode(texture: SKTexture(imageNamed: "Panel"))
    let startButton = createButton(title: "START", option: .start)
    let optionsButton = createButton(title: "OPTIONS", option: .options)

    override init(size: CGSize) {
        super.init(size: size)
        addChild(panel)
        startButton.responder = self
        panel.addChild(startButton)
        optionsButton.responder = self
        panel.addChild(optionsButton)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func layoutSubnodes() {
        panel.position = CGPoint(safeAreaInsets.left + panel.size.midW + 10, frame.midY)
        let spacing: CGFloat = 20
        let anchor = CGPoint(0, panel.size.midH - (startButton.size.midH + spacing))
        let step = -(startButton.size.height + spacing)
        startButton.position = anchor + CGPoint(0, 0 * step)
        optionsButton.position = anchor + CGPoint(0, 1 * step)
    }

    override func didMove(to view: SKView) {
        layoutSubnodes()
        alpha = 0.0
        run(SKAction.fadeIn(withDuration: SceneConstants.scenePresentDuration * 2))
    }
}

extension MainMenuScene: ButtonNodeResponderType {
    func buttonTriggered(button: ButtonNode) {
        if let completion = completion, let selectedOption = MainMenuOption(rawValue: button.name!) {
            completion(selectedOption)
        }
    }
}
