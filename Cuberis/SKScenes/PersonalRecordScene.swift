//
//  PersonalRecordScene.swift
//  Polycuberis
//

import SpriteKit

class PersonalRecordScene: SKScene {

    var value: Int = 0 {
        didSet {
            valueLabel.text = "\(value)"
        }
    }

    var completion: (() -> Void)?

    private let topLabel = SKLabelNode(text: "CONGRATZ!")
    private let valueLabel = SKLabelNode()
    private let bottomLabel = SKLabelNode(text: "New personal record!")
    private var heavyFeedback = UIImpactFeedbackGenerator(style: .heavy)

    override init(size: CGSize) {
        super.init(size: size)
        isUserInteractionEnabled = true
        setup(topLabel, offset: CGPoint(0, 70), fontSize: 30, color: .white)
        setup(valueLabel, offset: CGPoint(0, 0), fontSize: 49, color: .yellow)
        setup(bottomLabel, offset: CGPoint(0, -50), fontSize: 30, color: .white)
    }

    func setup(_ label: SKLabelNode, offset: CGPoint, fontSize: CGFloat, color: UIColor) {
        addChild(label)
        label.fontName = "GillSans"
        label.fontSize = fontSize
        label.zPosition = 1
        label.fontColor = color
        label.position = CGPoint(size.midW, size.midH) + offset
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
        run(SKAction.playSoundFileNamed("Fanfare.wav", waitForCompletion: false))
    }

    private func explode(at point: CGPoint, withDelay delay: TimeInterval, withColor color: UIColor,
                         withScaleFactor scaleFactor: CGFloat) {

        let fireworkSound = SKAction.sequence([
            SKAction.wait(forDuration: delay),
            SKAction.playSoundFileNamed("Firework", waitForCompletion: false)
        ])
        let fireworkSequence = SKAction.sequence([
            SKAction.wait(forDuration: delay),
            SKAction.run { [unowned self] in
                guard let fireworkEmitter = SKEmitterNode(fileNamed: "Firework") else { return }
                fireworkEmitter.particlePosition = point
                fireworkEmitter.particleColorSequence = nil
                fireworkEmitter.particleScale *= scaleFactor
                fireworkEmitter.particleColor = color
                guard let smokeEmitter = SKEmitterNode(fileNamed: "FireworkSmokeEmitter") else { return }
                smokeEmitter.particlePosition = point
                smokeEmitter.particleScale *= scaleFactor
                self.heavyFeedback.impactOccurred()
                self.addChild(fireworkEmitter)
                self.addChild(smokeEmitter)
            }])
        run(fireworkSound)
        run(fireworkSequence)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        completion?()
    }
}
