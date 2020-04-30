//
//  PersonalRecordScene.swift
//  Polycuberis
//

import SpriteKit

class PersonalRecordScene: SKScene {

    static func setupLabelFont(_ label: SKLabelNode) {
        label.fontName = "GillSans"
        label.fontSize = 26
    }

    var caption: String = "" {
        didSet {
            captionLabel.text = caption
        }
    }

    var animatedAppearance = false
    var completion: (() -> Void)?

    private let captionLabel = SKLabelNode()
    private let panel: SKSpriteNode
    private let okButton = createButton(title: "OK")

    override init(size: CGSize) {
        let panelTexture = SKTexture(imageNamed: "PersonalRecordPanel")
        panel = SKSpriteNode(texture: panelTexture)

        super.init(size: size)
        addChild(panel)
        panel.addChild(captionLabel)
        setupCaption()
        okButton.action = { [unowned self] in self.completion?() }
        panel.addChild(okButton)
        okButton.position = CGPoint(0, -panel.size.midH + okButton.size.midH + 8)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCaption() {
        captionLabel.verticalAlignmentMode = .baseline
        captionLabel.horizontalAlignmentMode = .center
        captionLabel.position = CGPoint(0, panel.size.midH - 40)
        LeaderboardScene.setupLabelFont(captionLabel)
    }

    func layoutSubnodes() {
        panel.position = CGPoint(frame.midX, frame.midY)
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
