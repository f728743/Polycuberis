//
//  OptionsScene.swift
//  Cuberis
//

import SpriteKit

class OptionsScene: SKScene {
    var completion: (() -> Void)?
    let panel = SKSpriteNode(texture: SKTexture(imageNamed: "Panel"))
    let okButton = createButton(title: "OK")

    override init(size: CGSize) {
        super.init(size: size)
        addChild(panel)
        okButton.action = { self.completion?() }
        panel.addChild(okButton)

//        let spacing: CGFloat = 20
//        let anchor = CGPoint(0, panel.size.midH - (pitButton.size.midH + spacing))
//        let step = -(pitButton.size.height + spacing)
//        polycubeButton.position = anchor + CGPoint(0, 1 * step)

        okButton.position = CGPoint(0, -panel.size.midH + okButton.size.midH + 10)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func layoutSubnodes() {
        panel.position = CGPoint(safeAreaInsets.left + panel.size.midW + 10, frame.midY)
    }

    override func didMove(to view: SKView) {
        layoutSubnodes()
    }
}
