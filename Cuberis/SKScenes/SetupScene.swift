//
//  SetupScene.swift
//  Cuberis
//

import SpriteKit

func setupPickerFont(control: PickerNode) {
    control.fontName = "GillSans"
    control.fontColor = .white
    control.fontSize = 26
}

protocol SetupSceneDelegate: AnyObject {
    func changed(pitSize: Size3i)
    func changed(polycubeSet: PolycubeSet)
}

extension SetupSceneDelegate {
    func changed(pitSize: Size3i) {}
    func changed(polycubeSet: PolycubeSet) {}
}

class SetupScene: SKScene {
    weak var setupDelegate: SetupSceneDelegate?
    var completion: ((Setup) -> Void)?
    let panel = SKSpriteNode(texture: SKTexture(imageNamed: "Panel"))
    let modePicker: StringPickerNode
    let widthPicker: NumericUpDownNode
    let heightPicker: NumericUpDownNode
    let depthPicker: NumericUpDownNode
    let polycubeSetPicker: StringPickerNode
    let okButton = createButton(title: "OK")
    var setup: Setup = Setup() {
        didSet { updateModeParams() }
    }

    override init(size: CGSize) {
        let options = GameMode.allCases.map { GameMode.names[$0.rawValue] }

        modePicker = StringPickerNode(options: options)
        widthPicker = NumericUpDownNode(label: "Pit width:",
                                        value: setup.pitSize.width,
                                        range: Setup.customWidthRange)
        heightPicker = NumericUpDownNode(label: "Pit height:",
                                         value: setup.pitSize.height,
                                         range: Setup.customHeighthRange)
        depthPicker = NumericUpDownNode(label: "Pit depth:",
                                        value: setup.pitSize.depth,
                                        range: Setup.customDepthRange)

        let polycubeSetOptions = PolycubeSet.allCases.map { PolycubeSet.names[$0.rawValue] }
        polycubeSetPicker = StringPickerNode(options: polycubeSetOptions)
        super.init(size: size)
        addChild(panel)
        setupModePicker()

        panel.addChild(widthPicker)
        setupPickerFont(control: widthPicker)
        widthPicker.changed = { [unowned self] in self.setSetupWidth() }
        panel.addChild(heightPicker)
        setupPickerFont(control: (heightPicker))
        heightPicker.changed = { [unowned self] in self.setSetupHeight() }
        panel.addChild(depthPicker)
        setupPickerFont(control: depthPicker)
        depthPicker.changed = { [unowned self] in self.setSetupDepth() }
        panel.addChild(polycubeSetPicker)
        polycubeSetPicker.index = setup.polycubeSet.rawValue
        polycubeSetPicker.changed = { [unowned self] in self.setSetuPolycubeSet() }
        setupPickerFont(control: polycubeSetPicker)

        panel.addChild(okButton)
        okButton.action = { [unowned self] in self.completion?(self.setup) }

        let spacing: CGFloat = 14
        let anchor = CGPoint(0, panel.size.midH - (modePicker.size.midH + 10))
        let step = -(modePicker.size.height + spacing)
        modePicker.position = anchor + CGPoint(0, 0 * step)
        widthPicker.position = anchor + CGPoint(0, 1 * step)
        heightPicker.position = anchor + CGPoint(0, 2 * step)
        depthPicker.position = anchor + CGPoint(0, 3 * step)
        polycubeSetPicker.position = anchor + CGPoint(0, 4 * step)
        okButton.position = CGPoint(0, -panel.size.midH + okButton.size.midH + 10)

        updateModeParams()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupModePicker() {
        panel.addChild(modePicker)
        setupPickerFont(control: modePicker)
        modePicker.index = setup.mode.rawValue
        modePicker.changed = { [unowned self] in
            self.setup.mode = GameMode(rawValue: self.modePicker.index)!
            self.updateModeParams()
            self.setupDelegate?.changed(pitSize: self.setup.pitSize)
        }
    }

    func layoutSubnodes() {
        panel.position = CGPoint(safeAreaInsets.left + panel.size.midW + 10, frame.midY)
    }

    override func didMove(to view: SKView) {
        layoutSubnodes()
    }

    func updateModeParams() {
        modePicker.index = setup.mode.rawValue
        let enabled = modePicker .index == modePicker.options.count - 1
        widthPicker.enabled = enabled
        widthPicker.value = setup.pitSize.width
        heightPicker.enabled = enabled
        heightPicker.value = setup.pitSize.height
        depthPicker.enabled = enabled
        depthPicker.value = setup.pitSize.depth
        polycubeSetPicker.enabled = enabled
        polycubeSetPicker.index = setup.polycubeSet.rawValue
    }

    private func setSetupWidth() {
        let current = setup.customSetup
        let newPitSize = Size3i(width: widthPicker.value, height: current.pitSize.height, depth: current.pitSize.depth)
        guard newPitSize != current.pitSize else { return }
        setupDelegate?.changed(pitSize: newPitSize)
        setup.customSetup = ModeSetup(name: current.name,
                                      pitSize: newPitSize,
                                      polycubeSet: current.polycubeSet)
    }

    private func setSetupHeight() {
        let current = setup.customSetup
        let newPitSize = Size3i(width: current.pitSize.width, height: heightPicker.value, depth: current.pitSize.depth)
        guard newPitSize != current.pitSize else { return }
        setupDelegate?.changed(pitSize: newPitSize)
        setup.customSetup = ModeSetup(name: current.name,
                                      pitSize: newPitSize,
                                      polycubeSet: current.polycubeSet)
    }

    private func setSetupDepth() {
        let current = setup.customSetup
        let newPitSize = Size3i(width: current.pitSize.width, height: current.pitSize.height, depth: depthPicker.value)
        guard newPitSize != current.pitSize else { return }
        setupDelegate?.changed(pitSize: newPitSize)
        setup.customSetup = ModeSetup(name: current.name,
                                      pitSize: newPitSize,
                                      polycubeSet: current.polycubeSet)
    }

    private func setSetuPolycubeSet() {
        let current = setup.customSetup
        let newSet = PolycubeSet(rawValue: polycubeSetPicker.index)!
        guard newSet != current.polycubeSet else { return }
        setupDelegate?.changed(polycubeSet: newSet)
        setup.customSetup = ModeSetup(name: current.name,
                                      pitSize: current.pitSize,
                                      polycubeSet: newSet)
    }
}
