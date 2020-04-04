//
//  GamepadButtonNode.swift
//  Cuberis
//

import SpriteKit

public class GamepadButtonNode: SKSpriteNode {
	public var action:(() -> Void)?

    init(buttonImageName: String) {
        let buttonTexture = SKTexture(imageNamed: buttonImageName)
        super.init(texture: buttonTexture, color: .black, size: buttonTexture.size())
        isUserInteractionEnabled = true
    }

	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard touches.first != nil else { return }
        action?()
	}
}
