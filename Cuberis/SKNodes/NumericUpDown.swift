//
//  NumericUpDown.swift
//  Cuberis
//

import SpriteKit

class NumericUpDownNode: PickerNode {
    override var fontColor: UIColor? {
        get { super.fontColor }
        set {
            super.fontColor = newValue
            valueNode.fontColor = newValue
        }
    }
    override var fontName: String? {
        get { super.fontName }
        set {
            super.fontName = newValue
            valueNode.fontName = newValue
        }
    }
    override var fontSize: CGFloat {
        get { super.fontSize }
        set {
            super.fontSize = newValue
            valueNode.fontSize = newValue
        }
    }

    private(set) var value: Int {
        didSet {
            valueNode.text = "\(value)"
        }
    }
    private let valueNode: SKLabelNode

    init(label: String, value: Int, range: CountableClosedRange<Int>) {
        let inset: CGFloat = 13
        self.value = value
        valueNode = SKLabelNode(text: label)
        super.init()
        labelNode.text = label
        labelNode.horizontalAlignmentMode = .left
        labelNode.position = CGPoint(-width / 2 + decreaseButton.size.width + inset, -9)
        addChild(valueNode)
        valueNode.text = "\(value)"
        valueNode.verticalAlignmentMode = .baseline
        valueNode.horizontalAlignmentMode = .right
        valueNode.position = CGPoint(width / 2 - increaseButton.size.width - inset, -9)
        valueNode.zPosition = labelNode.zPosition
        decreaseButton.action = { if range.contains(self.value - 1) { self.value -= 1 } }
        increaseButton.action = { if range.contains(self.value + 1) { self.value += 1 } }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
