//
//  PickerNode.swift
//  Cuberis
//

import SpriteKit

class PickerNode: SKSpriteNode {
    enum ButtonIdentifier: String {
       case decrease
       case increase
    }

    var changed:(() -> Void)?
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

    var index: Int {
        didSet {
            if oldValue != index {
                changed?()
            }
            labelNode.text = options[index]
        }
    }

    private let options: [String]
    private let labelNode: SKLabelNode

    init(options: [String]) {
        self.options = options
        self.index = 0
        labelNode = SKLabelNode(text: options[0])
        height = decreaseButton.size.height
        super.init(texture: nil, color: .clear, size: CGSize(width: width, height: height))

        addChild(labelNode)
        labelNode.verticalAlignmentMode = .center
        labelNode.zPosition = 0

        addChild(decreaseButton)
        decreaseButton.position = CGPoint(-width / 2 + decreaseButton.size.midW, 0)
        decreaseButton.name = ButtonIdentifier.decrease.rawValue
        decreaseButton.action = { self.index = self.index - 1 < 0 ? self.options.count - 1 : self.index - 1 }

        addChild(increaseButton)
        increaseButton.position = CGPoint(width / 2 - increaseButton.size.midW, 0)
        increaseButton.name = ButtonIdentifier.increase.rawValue
        increaseButton.action = { self.index = self.index + 1 == self.options.count ? 0 : self.index + 1 }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
