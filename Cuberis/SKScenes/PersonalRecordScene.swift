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

    var value: Int = 0 {
        didSet {
            valueLabel.text = "\(value)"
        }
    }

    var animatedAppearance = false
    var completion: (() -> Void)?

    private let topLabel = SKLabelNode(text: "CONGRATZ!")
    private let valueLabel = SKLabelNode()
    private let bottomLabel = SKLabelNode(text: "New personal record!")

    private let okButton = createButton(title: "OK")

    override init(size: CGSize) {

        super.init(size: size)
        addChild(topLabel)
        topLabel.fontName = "GillSans"
        topLabel.fontSize = 30
        topLabel.zPosition = 1
        topLabel.position = CGPoint(size.midW, size.midH + 70)

        addChild(valueLabel)
        valueLabel.fontName = "GillSans"
        valueLabel.fontSize = 49
        valueLabel.fontColor = .yellow
        valueLabel.zPosition = 1
        valueLabel.position = CGPoint(size.midW, size.midH)

        addChild(bottomLabel)
        bottomLabel.fontName = "GillSans"
        bottomLabel.fontSize = 30
        bottomLabel.zPosition = 1
        bottomLabel.position = CGPoint(size.midW, size.midH - 50)

        okButton.action = { [unowned self] in self.completion?() }
        addChild(okButton)
        okButton.position = CGPoint(0, size.midH)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        for _ in 0...5 + Int.random(in: 0...2) {
            explode(at: CGPoint(size.midW + CGFloat(Int.random(in: Int(-size.midW / 2)...Int(size.midW / 2))),
                                size.midH + CGFloat(Int.random(in: Int(-size.midH / 2)...Int(size.midH / 2)))),
                    withDelay: TimeInterval(drand48() * 3),
                    withColor: UIColor.colorsForCompound[Int.random(in: 0..<UIColor.colorsForCompound.count)],
                    withScaleFactor: 0.2 + CGFloat(drand48() * 0.4))
        }
    }

    private func explode(at point: CGPoint, withDelay delay: TimeInterval, withColor color: UIColor,
                         withScaleFactor scaleFactor: CGFloat) {

        let fireworkSound = SKAction.sequence([
            SKAction.wait(forDuration: delay),
            SKAction.playSoundFileNamed("Classic", waitForCompletion: false)
        ])
        let fireworkSequence = SKAction.sequence([
            SKAction.wait(forDuration: delay),
            SKAction.run { [unowned self] in
                guard let fireworkEmitter = SKEmitterNode(fileNamed: "Classic") else { return }
                fireworkEmitter.particlePosition = point
                fireworkEmitter.particleColorSequence = nil
                fireworkEmitter.particleScale *= scaleFactor
                fireworkEmitter.particleColor = color
                guard let smokeEmitter = SKEmitterNode(fileNamed: "FireworkSmokeEmitter") else { return }
                smokeEmitter.particlePosition = point
                smokeEmitter.particleScale *= scaleFactor
                self.addChild(fireworkEmitter)
                self.addChild(smokeEmitter)
            }])
        run(fireworkSound)
        run(fireworkSequence)
    }
}
