import SpriteKit

public class SKButton: SKNode {

	public var action:(() -> Void)?

	public var size: CGSize {
		get { sprite.size }
		set { sprite.size = newValue }
	}

    public var width: CGFloat {
        get { size.width }
        set { size.width = newValue }
    }

    public var height: CGFloat {
        get { size.height }
        set { size.height = newValue}
    }

	private var sprite: SKSpriteNode

	init(texture: SKTexture, action: (() -> Void)? = nil) {
    	self.sprite = SKSpriteNode(texture: texture)
		self.action = action
		super.init()
		isUserInteractionEnabled = true
		addChild(sprite)
	}

	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard touches.first != nil else { return }
        action?()
	}

}
