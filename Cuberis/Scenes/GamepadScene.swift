//
//  GamepadScene.swift
//  Cuberis
//

import SpriteKit

class GamepadScene: SKScene {
    weak var gamepadDelegate: GamepadProtocol?

    var completion: (() -> Void)?

    let goBackButton = ButtonNode(buttonImageName: "GoBackButton")
    let rotateXCounterclockwiseButton = GamepadButtonNode(buttonImageName: "RotateXCounterclockwise")
    let rotateYCounterclockwiseButton = GamepadButtonNode(buttonImageName: "RotateYCounterclockwise")
    let rotateZCounterclockwiseButton = GamepadButtonNode(buttonImageName: "RotateZCounterclockwise")
    let moveUpButton = GamepadButtonNode(buttonImageName: "MoveUp")
    let moveDownButton = GamepadButtonNode(buttonImageName: "MoveDown")
    let moveLeftButton = GamepadButtonNode(buttonImageName: "MoveLeft")
    let moveRightButton = GamepadButtonNode(buttonImageName: "MoveRight")
    let dropButton = GamepadButtonNode(buttonImageName: "Drop")

    override init(size: CGSize) {
        super.init(size: size)
        goBackButton.responder = self
        addChild(goBackButton)
        addGamepadButton(rotateXCounterclockwiseButton) { self.gamepadDelegate?.rotateXCounterclockwise() }
        addGamepadButton(rotateYCounterclockwiseButton) { self.gamepadDelegate?.rotateYCounterclockwise() }
        addGamepadButton(rotateZCounterclockwiseButton) { self.gamepadDelegate?.rotateZCounterclockwise() }
        addGamepadButton(moveUpButton) { self.gamepadDelegate?.moveUp() }
        addGamepadButton(moveLeftButton) { self.gamepadDelegate?.moveLeft() }
        addGamepadButton(moveRightButton) { self.gamepadDelegate?.moveRight() }
        addGamepadButton(moveDownButton) { self.gamepadDelegate?.moveDown() }
        addGamepadButton(dropButton) { self.gamepadDelegate?.drop() }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        layoutSubnodes()
        alpha = 0.0
        run(SKAction.fadeIn(withDuration: SceneConstants.presentDuration * 2))
    }

    func layoutSubnodes() {
        layoutGoBackButton()
        layoutRotationButtons()
        layoutMoveButtons()
        layoutDropButton()
    }

    private func addGamepadButton(_ button: GamepadButtonNode, action:@escaping (() -> Void)) {
        button.action = action
        addChild(button)
    }

    private func layoutGoBackButton() {
        goBackButton.position = CGPoint(x: safeAreaInsets.left, y: frame.height - safeAreaInsets.top) +
            goBackButton.size.mid * CGPoint(1, -1) +
            CGPoint(5, -5)
    }

    private func layoutRotationButtons() {
        let spacing: CGFloat = 14
        let buttonHeight = rotateYCounterclockwiseButton.size.height
        let buttonMidW = rotateYCounterclockwiseButton.size.midW
        let anchor = CGPoint(x: safeAreaInsets.left + buttonMidW, y: frame.midY) +
            CGPoint(30, -30)
        rotateXCounterclockwiseButton.position = anchor + CGPoint(0, buttonHeight + spacing)
        rotateYCounterclockwiseButton.position = anchor
        rotateZCounterclockwiseButton.position = anchor + CGPoint(0, -(buttonHeight + spacing))
    }

    private func layoutMoveButtons() {
        let buttonHeight = moveUpButton.size.height
        let buttonWidth = moveUpButton.size.width
        let buttonMidW = moveUpButton.size.midW
        let anchor = CGPoint(x: frame.width - (buttonWidth + safeAreaInsets.right + buttonMidW), y: frame.midY) +
            CGPoint(-20, 40)
        moveUpButton.position = anchor + CGPoint(0, buttonHeight)
        moveLeftButton.position = anchor + CGPoint(-buttonWidth, 0)
        moveRightButton.position = anchor + CGPoint(buttonWidth, 0)
        moveDownButton.position = anchor + CGPoint(0, -buttonHeight)
    }

    private func layoutDropButton() {
        let buttonWidth = moveUpButton.size.width
        dropButton.position = CGPoint(x: frame.width - (safeAreaInsets.right + buttonWidth * 2), y: 0) +
            dropButton.size.mid * CGPoint(-1, 1) +
            CGPoint(-20, 20)
    }

}

extension GamepadScene: ButtonNodeResponderType {
    func buttonTriggered(button: ButtonNode) {
        if let completion = completion {
            completion()
        }
    }
}
