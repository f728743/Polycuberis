//
//  MainMenuScene.swift
//  Cuberis
//

import SpriteKit

enum MainMenuOption: String {
   case start
   case options
}

func createButton(title: String, option: MainMenuOption) -> ButtonNode {
    let button = ButtonNode(buttonImageName: "GreenButton", title: title)
    button.name = option.rawValue
    button.fontName = "GillSans-Light"
    button.fontColor = .black
    button.fontSize = 26
    return button
}

class MainMenuScene: SKScene {
    var completion: ((MainMenuOption) -> Void)?

    let startButton = createButton(title: "START", option: .start)
    let optionsButton = createButton(title: "OPTIONS", option: .options)

    override init(size: CGSize) {
        super.init(size: size)
        startButton.responder = self
        addChild(startButton)
        optionsButton.responder = self
        addChild(optionsButton)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func layoutSubnodes() {
        let anchor = CGPoint(x: safeAreaInsets.left + startButton.size.midW + 40, y: frame.height)
        startButton.position = anchor + CGPoint(0, -80)
        optionsButton.position = anchor + CGPoint(0, -140)
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
