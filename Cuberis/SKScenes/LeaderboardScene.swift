//
//  LeaderboardScene.swift
//  Cuberis
//

import SpriteKit

class LeaderboardScene: SKScene {

    static func setupLabelFont(_ label: SKLabelNode) {
        label.fontName = "GillSans"
        label.fontSize = 26
    }

    class ScoreTableRow: SKSpriteNode {
        var isHighlighted: Bool = false {
            didSet {
                textColor = isHighlighted ? .yellow : .white
            }
        }
        var textColor: UIColor = .white {
            didSet {
                rank.fontColor = textColor
                player.fontColor = textColor
                value.fontColor = textColor
            }
        }
        let rank = SKLabelNode()
        let player = SKLabelNode()
        let value = SKLabelNode()
        init(size: CGSize) {
            super.init(texture: nil, color: UIColor.clear, size: size)
            addChild(rank)
            setupLabelFont(rank)
            rank.horizontalAlignmentMode = .right
            rank.position = CGPoint(-size.midW + 60, -9)
            addChild(player)
            setupLabelFont(player)
            player.horizontalAlignmentMode = .left
            player.position = CGPoint(-size.midW + 80, -9)
            addChild(value)
            setupLabelFont(value)
            value.horizontalAlignmentMode = .right
            value.position = CGPoint(size.midW - 6, -9)
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    class ScoreTableNode: SKSpriteNode {
        let cells: [ScoreTableRow]
        init(cellSize: CGSize, cellCount: Int) {
            cells =  (0..<cellCount).map { _ in ScoreTableRow(size: CGSize(width: cellSize.width, height: 30)) }
            super.init(texture: nil,
                       color: .clear,
                       size: CGSize(width: cellSize.width, height: cellSize.height * CGFloat(cellCount)))
            for (index, cell) in cells.enumerated() {
                addChild(cell)
                cell.color = index % 2 == 0 ? UIColor(white: 1.0, alpha: 0.22) : UIColor(white: 1.0, alpha: 0.09)
                cell.position = CGPoint(0, size.midH - cellSize.midH - (CGFloat(index) * 30))
            }
        }
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    var caption: String = "" {
        didSet {
            captionLabel.text = caption
        }
    }

    var rows: [ScoreRow] = [] {
        didSet {
            for (index, cell) in table.cells.enumerated() {
                if index < rows.count {
                    cell.rank.text = rows[index].rank
                    cell.player.text = rows[index].player
                    cell.value.text = rows[index].value
                    cell.isHighlighted = rows[index].isHighlighted
                } else {
                    cell.rank.text = ""
                    cell.player.text = ""
                    cell.value.text = ""
                }
            }
        }
    }
    var animatedAppearance = false
    var completion: (() -> Void)?

    private let captionLabel = SKLabelNode()
    private let panel: SKSpriteNode
    private let okButton = createButton(title: "OK")
    private let table: ScoreTableNode

    override init(size: CGSize) {
        let panelTexture = SKTexture(imageNamed: "HighScorePanel")
        panel = SKSpriteNode(texture: panelTexture)
        table = ScoreTableNode(cellSize: CGSize(width: Int(panelTexture.size().width) - 42, height: 30),
                          cellCount: 7)

        super.init(size: size)
        addChild(panel)
        panel.addChild(captionLabel)
        setupCaption()
        okButton.action = { [unowned self] in self.completion?() }
        panel.addChild(okButton)
        okButton.position = CGPoint(0, -panel.size.midH + okButton.size.midH + 8)

        table.position = CGPoint(0, 9)
        panel.addChild(table)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCaption() {
        captionLabel.verticalAlignmentMode = .baseline
        captionLabel.horizontalAlignmentMode = .center
        captionLabel.position = CGPoint(0, panel.size.midH - 40)
        LeaderboardScene.setupLabelFont(captionLabel)
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
