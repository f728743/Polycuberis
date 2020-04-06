//
//  NumericUpDown.swift
//  Cuberis
//

import SpriteKit

class NumericUpDown: SKSpriteNode {
    enum ButtonIdentifier: String {
       case decrease
       case increase
    }

    let width: CGFloat = 180
    let height: CGFloat = 40
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
    private let range: CountableClosedRange<Int>
    private var labelNode: SKLabelNode

    init(label: String, value: Int, range: CountableClosedRange<Int>) {
        self.value = value
        self.range = range
        self.label = label
        labelNode = SKLabelNode(text: label)

        super.init(texture: nil, color: .clear, size: CGSize(width: width, height: height))

        addChild(labelNode)
        labelNode.text = "\(label) \(value)"
        labelNode.verticalAlignmentMode = .center
        labelNode.zPosition = 0

        addChild(decreaseButton)
        decreaseButton.position = CGPoint(-width / 2 + decreaseButton.size.midW, 0)
        decreaseButton.name = ButtonIdentifier.decrease.rawValue
        decreaseButton.responder = self

        addChild(increaseButton)
        increaseButton.position = CGPoint(width / 2 - increaseButton.size.midW, 0)
        increaseButton.name = ButtonIdentifier.increase.rawValue
        increaseButton.responder = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NumericUpDown: ButtonNodeResponderType {
    func buttonTriggered(button: ButtonNode) {
        guard let buttonId = ButtonIdentifier(rawValue: button.name!) else {
            fatalError("button name must be ButtonIdentifier")
        }
        switch buttonId {
        case .decrease:
            let newValue = value - 1
            if range.contains(newValue) {
                value = newValue
            }
        case .increase:
            let newValue = value + 1
            if range.contains(newValue) {
                value = newValue
            }
        }
    }
}
