//
//  HighScoreScene.swift
//  Cuberis
//

import SpriteKit

class HighScoreScene: SKScene {
    var animatedAppearance = false
    var completion: (() -> Void)?

    let panel = SKSpriteNode(texture: SKTexture(imageNamed: "HighScorePanel"))
    let okButton = createButton(title: "OK")

    init(size: CGSize, level: Int) {
        super.init(size: size)
        addChild(panel)
        okButton.action = { [unowned self] in self.completion?() }
        panel.addChild(okButton)
        okButton.position = CGPoint(0, 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func layoutSubnodes() {
        panel.position = CGPoint(safeAreaInsets.left + panel.size.midW + 10, frame.midY)
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
