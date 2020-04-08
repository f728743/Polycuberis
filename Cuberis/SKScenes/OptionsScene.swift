//
//  OptionsScene.swift
//  Cuberis
//

import SpriteKit

func setupPickerFont(control: PickerNode) {
    control.fontName = "GillSans"
    control.fontColor = .white
    control.fontSize = 26
}

class OptionsScene: SKScene {
    var completion: (() -> Void)?
    let panel = SKSpriteNode(texture: SKTexture(imageNamed: "Panel"))
    let gameTypePicker: StringPickerNode
    let widthPicker: NumericUpDownNode
    let heightPicker: NumericUpDownNode
    let depthPicker: NumericUpDownNode
    let polycubeSetPicker: StringPickerNode
    let okButton = createButton(title: "OK")

    override init(size: CGSize) {
        let options = ["3D Mania", "Flat Fun", "Out of control", "Custom"]
        gameTypePicker = StringPickerNode(options: options)
        widthPicker = NumericUpDownNode(label: "Pit width:", value: 5, range: 3...7)
        heightPicker = NumericUpDownNode(label: "Pit height:", value: 5, range: 3...7)
        depthPicker = NumericUpDownNode(label: "Pit depth:", value: 12, range: 6...18)
        polycubeSetPicker = StringPickerNode(options: ["Flat", "Basic", "Extended"])
        super.init(size: size)
        addChild(panel)
        panel.addChild(gameTypePicker)
        gameTypePicker.changed = {
            self.setSetupEdit(enabled: self.gameTypePicker.index == options.count - 1)
        }
        setSetupEdit(enabled: false)
        setupPickerFont(control: gameTypePicker)
        panel.addChild(widthPicker)
        setupPickerFont(control: widthPicker)
        panel.addChild(heightPicker)
        setupPickerFont(control: (heightPicker))
        panel.addChild(depthPicker)
        setupPickerFont(control: depthPicker)
        panel.addChild(polycubeSetPicker)
        setupPickerFont(control: polycubeSetPicker)

        panel.addChild(okButton)
        okButton.action = { self.completion?() }

        let spacing: CGFloat = 14
        let anchor = CGPoint(0, panel.size.midH - (gameTypePicker.size.midH + 10))
        let step = -(gameTypePicker.size.height + spacing)
        gameTypePicker.position = anchor + CGPoint(0, 0 * step)
        widthPicker.position = anchor + CGPoint(0, 1 * step)
        heightPicker.position = anchor + CGPoint(0, 2 * step)
        depthPicker.position = anchor + CGPoint(0, 3 * step)
        polycubeSetPicker.position = anchor + CGPoint(0, 4 * step)

        okButton.position = CGPoint(0, -panel.size.midH + okButton.size.midH + 10)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func layoutSubnodes() {
        panel.position = CGPoint(safeAreaInsets.left + panel.size.midW + 10, frame.midY)
    }

    override func didMove(to view: SKView) {
        layoutSubnodes()
    }

    func setSetupEdit(enabled: Bool) {
        widthPicker.enabled = enabled
        heightPicker.enabled = enabled
        depthPicker.enabled = enabled
        polycubeSetPicker.enabled = enabled
    }
}
