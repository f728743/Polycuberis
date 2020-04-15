//
//  HighScoreScene.swift
//  Cuberis
//

import SpriteKit

class HighScoreScene: SKScene {
    static func setupLabelFont(_ label: SKLabelNode) {
        label.fontName = "GillSans"
        label.fontSize = 26
    }

    class ScoreTableLine: SKSpriteNode {

        let placeLabel = SKLabelNode()
        let playerLabel = SKLabelNode()
        let scoreLabel = SKLabelNode()
        init(size: CGSize) {
            super.init(texture: nil, color: UIColor.clear, size: size)
            addChild(placeLabel)
            setupLabelFont(placeLabel)
            placeLabel.horizontalAlignmentMode = .right
            placeLabel.position = CGPoint(-size.midW + 60, -8)
            addChild(playerLabel)
            setupLabelFont(playerLabel)
            playerLabel.horizontalAlignmentMode = .left
            playerLabel.position = CGPoint(-size.midW + 70, -8)
            addChild(scoreLabel)
            setupLabelFont(scoreLabel)
            scoreLabel.horizontalAlignmentMode = .right
            scoreLabel.position = CGPoint(size.midW - 6, -8)
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    class ScoreTableNode: SKSpriteNode {
        let cells: [ScoreTableLine]
        init(cellSize: CGSize, cellsCount: Int) {
            cells =  (0..<cellsCount).map { _ in ScoreTableLine(size: CGSize(width: cellSize.width, height: 30)) }
            super.init(texture: nil,
                       color: .clear,
                       size: CGSize(width: cellSize.width, height: cellSize.height * CGFloat(cellsCount)))
            for (index, cell) in cells.enumerated() {
                addChild(cell)
                cell.color = index % 2 == 0 ? UIColor(white: 1.0, alpha: 0.22) : UIColor(white: 1.0, alpha: 0.09)
                cell.placeLabel.text = "\(index + 1)"
                cell.position = CGPoint(0, size.midH - cellSize.midH - (CGFloat(index) * 30))
            }
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    var animatedAppearance = false
    var completion: (() -> Void)?

    let panel: SKSpriteNode
    let okButton = createButton(title: "OK")
    let table: ScoreTableNode

    override init(size: CGSize) {
        let panelTexture = SKTexture(imageNamed: "HighScorePanel")
        panel = SKSpriteNode(texture: panelTexture)
        table = ScoreTableNode(cellSize: CGSize(width: Int(panelTexture.size().width) - 42, height: 30),
                          cellsCount: 7)

        super.init(size: size)
        addChild(panel)
        panel.addChild(createCaption(text: "High Score"))
        okButton.action = { [unowned self] in self.completion?() }
        panel.addChild(okButton)
        okButton.position = CGPoint(0, -panel.size.midH + okButton.size.midH + 8)

        table.position = CGPoint(0, 9)
        panel.addChild(table)
//        line.set(record: Record(place: 8888, player: "comrade.vorobyov@gmail.com", score: 9000000))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func createCaption(text: String) -> SKLabelNode {
        let caption = SKLabelNode(text: text)
        caption.verticalAlignmentMode = .baseline
        caption.horizontalAlignmentMode = .center
        caption.position = CGPoint(0, panel.size.midH - 40)
        HighScoreScene.setupLabelFont(caption)
        return caption
    }

    func layoutSubnodes() {
        panel.position = CGPoint(frame.midX, frame.midY)
    }

    override func didMove(to view: SKView) {
        layoutSubnodes()
        if animatedAppearance {
            alpha = 0.0
            run(SKAction.fadeIn(withDuration: SceneConstants.scenePresentDuration * 2))
        } else {
            alpha = 1.0
        }
    }
}
