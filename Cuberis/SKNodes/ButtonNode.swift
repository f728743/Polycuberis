import SpriteKit

protocol ButtonNodeResponderType: class {
    func buttonTriggered(button: ButtonNode)
}

class ButtonNode: SKSpriteNode {
    var responder: ButtonNodeResponderType?

    var isFocused = false {
        didSet {
            guard oldValue != isFocused else { return }
            if isFocused {
                run(SKAction.scale(to: 1.08, duration: 0.2))
                focusRing?.alpha = 0.5
                focusRing?.isHidden = false
                focusRing?.run(SKAction.fadeIn(withDuration: 0.2))
            } else {
                run(SKAction.scale(to: 1.0, duration: 0.20))
                focusRing?.isHidden = true
            }
        }
    }

    var fontColor: UIColor? {
        get { titleLabel?.fontColor }
        set { titleLabel?.fontColor = newValue }
    }

    var fontName: String? {
        get { titleLabel?.fontName }
        set { titleLabel?.fontName = newValue }
    }

    var fontSize: CGFloat {
        get { titleLabel?.fontSize ?? 0 }
        set { titleLabel?.fontSize = newValue }
    }

    private(set) var titleLabel: SKLabelNode?

    private var focusRing: SKNode?

    private var isHighlighted = false {
        didSet {
            guard oldValue != isHighlighted else { return }
            removeAllActions()
            let newScale: CGFloat = isHighlighted ? 0.98 : 1.0
            let scaleAction = SKAction.scale(to: newScale, duration: 0.15)
            let newColorBlendFactor: CGFloat = isHighlighted ? 0.2 : 0.0
            let colorBlendAction = SKAction.colorize(withColorBlendFactor: newColorBlendFactor, duration: 0.15)
            run(SKAction.group([scaleAction, colorBlendAction]))
        }
    }

    init(buttonImageName: String, title: String? = nil, focusImageName: String? = nil) {
        let buttonTexture = SKTexture(imageNamed: buttonImageName)
        super.init(texture: buttonTexture, color: .black, size: buttonTexture.size())
        zPosition = 1

        setTitle(title)
        if let focusImageName = focusImageName {
            let focusTexture = SKTexture(imageNamed: focusImageName)
            let focusNode = SKSpriteNode(texture: focusTexture, color: .black, size: focusTexture.size())
            addChild(focusNode)
            focusNode.isHidden = true
            focusNode.zPosition = -1
            focusRing = focusNode
        }
        isUserInteractionEnabled = true
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setTitle(_ title: String?) {
        if let title = title {
            if let label = titleLabel {
                label.text = title
            } else {
                let label = SKLabelNode(text: title)
                label.verticalAlignmentMode = .center
                label.zPosition = 0
                addChild(label)
                titleLabel = label
            }
        } else {
            titleLabel?.removeFromParent()
            titleLabel = nil
        }
    }

    func buttonTriggered() {
        if isUserInteractionEnabled {
            responder?.buttonTriggered(button: self)
        }
    }

    // MARK: UIResponder

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        isHighlighted = true
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        isHighlighted = false
        if containsTouches(touches: touches) {
            buttonTriggered()
        }
    }

    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        isHighlighted = containsTouches(touches: touches)
    }

    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        super.touchesCancelled(touches!, with: event)
        isHighlighted = false
    }

    private func containsTouches(touches: Set<UITouch>) -> Bool {
        guard let scene = scene else { fatalError("Button must be used within a scene.") }
        return touches.contains { touch in
            let touchPoint = touch.location(in: scene)
            let touchedNode = scene.atPoint(touchPoint)
            return touchedNode === self || touchedNode.inParentHierarchy(self)
        }
    }
}
