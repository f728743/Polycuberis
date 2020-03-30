import SceneKit
import SpriteKit

/// Is used in Main.storyboard
/// under Identity Inspector

final class GameView: SCNView {
    weak var gamepadDelegate: GamepadProtocol?

    var rotateXCounterclockwiseButton: SKButton!
    var rotateYCounterclockwiseButton: SKButton!
    var rotateZCounterclockwiseButton: SKButton!
    var moveUpButton: SKButton!
    var moveDownButton: SKButton!
    var moveLeftButton: SKButton!
    var moveRightButton: SKButton!
    var dropButton: SKButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        setup2DOverlay()
    }

    func setup2DOverlay() {
        let skScene = SKScene()
        skScene.scaleMode = .resizeFill
        skScene.isUserInteractionEnabled = false
        setupControllerButtons(on: skScene)
        overlaySKScene = skScene
    }

    func setupControllerButtons(on skScene: SKScene) {
        rotateXCounterclockwiseButton = SKButton(texture:
        SKTexture(imageNamed: "RotateXCounterclockwise")) {
            self.gamepadDelegate?.rotateXCounterclockwise()
        }
        skScene.addChild(rotateXCounterclockwiseButton)

        rotateYCounterclockwiseButton = SKButton(texture:
        SKTexture(imageNamed: "RotateYCounterclockwise")) {
            self.gamepadDelegate?.rotateYCounterclockwise()
        }
        skScene.addChild(rotateYCounterclockwiseButton)

        rotateZCounterclockwiseButton = SKButton(texture:
        SKTexture(imageNamed: "RotateZCounterclockwise")) {
            self.gamepadDelegate?.rotateZCounterclockwise()
        }
        skScene.addChild(rotateZCounterclockwiseButton)

        moveUpButton = SKButton(texture:
        SKTexture(imageNamed: "MoveUp")) {
            self.gamepadDelegate?.moveUp()
        }
        skScene.addChild(moveUpButton)

        moveDownButton = SKButton(texture:
        SKTexture(imageNamed: "MoveDown")) {
            self.gamepadDelegate?.moveDown()
        }
        skScene.addChild(moveDownButton)

        moveLeftButton = SKButton(texture:
        SKTexture(imageNamed: "MoveLeft")) {
            self.gamepadDelegate?.moveLeft()
        }
        skScene.addChild(moveLeftButton)

        moveRightButton = SKButton(texture:
        SKTexture(imageNamed: "MoveRight")) {
            self.gamepadDelegate?.moveRight()
        }
        skScene.addChild(moveRightButton)

        dropButton = SKButton(texture:
        SKTexture(imageNamed: "Drop")) {
            self.gamepadDelegate?.drop()
        }
        skScene.addChild(dropButton)

    }

    override func layoutSubviews() {
        overlaySKScene?.size = bounds.size
        let leftMargin: CGFloat = 50
        let topMargin: CGFloat = 50
        let rightMargin: CGFloat = 10
        let verticalSpacing: CGFloat = 10

        rotateXCounterclockwiseButton.position =
            CGPoint(x: leftMargin + rotateXCounterclockwiseButton.width / 2,
                    y: bounds.size.height - topMargin - rotateXCounterclockwiseButton.height / 2)

        rotateYCounterclockwiseButton.position =
            CGPoint(x: rotateXCounterclockwiseButton.position.x,
                    y: rotateXCounterclockwiseButton.position.y -
                        rotateXCounterclockwiseButton.height - verticalSpacing)

        rotateZCounterclockwiseButton.position =
            CGPoint(x: rotateYCounterclockwiseButton.position.x,
                    y: rotateYCounterclockwiseButton.position.y -
                        rotateYCounterclockwiseButton.height - verticalSpacing)

        moveUpButton.position =
            CGPoint(x: bounds.size.width - rightMargin - moveRightButton.width - moveUpButton.width / 2,
                    y: bounds.size.height - topMargin - moveUpButton.height / 2)

        moveLeftButton.position =
            CGPoint(x: moveUpButton.position.x - moveUpButton.width,
                    y: moveUpButton.position.y - moveUpButton.height)

        moveRightButton.position =
            CGPoint(x: moveUpButton.position.x + moveUpButton.width,
                    y: moveUpButton.position.y - moveUpButton.height)

        moveDownButton.position =
            CGPoint(x: moveLeftButton.position.x + moveLeftButton.width,
                    y: moveLeftButton.position.y - moveLeftButton.height)

        dropButton.position =
            CGPoint(x: moveLeftButton.position.x,
                    y: moveDownButton.position.y - moveDownButton.height)

    }
}
