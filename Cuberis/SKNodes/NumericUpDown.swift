//
//  NumericUpDown.swift
//  Cuberis
//

import SpriteKit

class NumericUpDownNode: SKSpriteNode {
    enum ButtonIdentifier: String {
       case decrease
       case increase
    }

    let width: CGFloat = 180
    let height: CGFloat
    let decreaseButton = ButtonNode(buttonImageName: "DecreaseButton")
    let increaseButton = ButtonNode(buttonImageName: "IncreaseButton")

    var fontColor: UIColor? {
        get { labelNode.fontColor }
        set { labelNode.fontColor = newValue }
    }
    var fontName: String? {
        get { labelNode.fontName }
        set { labelNode.fontName = newValue }
    }
    var fontSize: CGFloat {
        get { labelNode.fontSize }
        set { labelNode.fontSize = newValue }
    }

    private var value: Int {
        didSet {
            labelNode.text = "\(label) \(value)"
        }
    }
    private var label = ""
    private var labelNode: SKLabelNode

    init(label: String, value: Int, range: CountableClosedRange<Int>) {
        self.value = value
        self.label = label
        labelNode = SKLabelNode(text: label)
        height = decreaseButton.size.height
        super.init(texture: nil, color: .clear, size: CGSize(width: width, height: height))

        addChild(labelNode)
        labelNode.text = "\(label) \(value)"
        labelNode.verticalAlignmentMode = .center
        labelNode.zPosition = 0

        addChild(decreaseButton)
        decreaseButton.position = CGPoint(-width / 2 + decreaseButton.size.midW, 0)
        decreaseButton.name = ButtonIdentifier.decrease.rawValue
        decreaseButton.action = { if range.contains(self.value - 1) { self.value -= 1 } }

        addChild(increaseButton)
        increaseButton.position = CGPoint(width / 2 - increaseButton.size.midW, 0)
        increaseButton.name = ButtonIdentifier.increase.rawValue
        increaseButton.action = { if range.contains(self.value + 1) { self.value += 1 } }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
