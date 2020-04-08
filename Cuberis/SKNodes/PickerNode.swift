//
//  PickerNode.swift
//  Cuberis
//

import SpriteKit

class PickerNode: SKSpriteNode {
    let width: CGFloat = 216
    let height: CGFloat
    let decreaseButton = ButtonNode(buttonImageName: "DecreaseButton")
    let increaseButton = ButtonNode(buttonImageName: "IncreaseButton")
    var enabled: Bool = true {
        didSet {
            decreaseButton.isHidden = !enabled
            increaseButton.isHidden = !enabled
        }
    }
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

    let labelNode: SKLabelNode

    init() {
        labelNode = SKLabelNode(text: "")
        height = decreaseButton.size.height
        super.init(texture: nil, color: .clear, size: CGSize(width: width, height: height))

        addChild(labelNode)
        labelNode.verticalAlignmentMode = .baseline
        labelNode.zPosition = 0

        addChild(decreaseButton)
        decreaseButton.position = CGPoint(-width / 2 + decreaseButton.size.midW, 0)

        addChild(increaseButton)
        increaseButton.position = CGPoint(width / 2 - increaseButton.size.midW, 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
