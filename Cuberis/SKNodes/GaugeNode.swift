//
//  GaugeNode.swift
//  Cuberis
//

import SpriteKit

class GaugeNode: SKNode {
    let cellCount: Int
    private let gaugeFrame = SKShapeNode()
    private let cells: [SKShapeNode]
    let width: CGFloat
    var value: Int = 0 {
        didSet {
            for index in 0..<cellCount {
                cells[index].isHidden = index >= value
            }
        }
    }
    init(fullHeight: CGFloat, cellCount: Int) {
        self.cellCount = cellCount
        let width: CGFloat = 21
        self.width = width
        let cellHeight = fullHeight / 18
        cells =  (0..<cellCount).map { i in
            let cell = SKShapeNode(rectOf: CGSize(width: width - 4, height: cellHeight - 4) )
            cell.fillColor = Palette.layers[i % Palette.layers.count]
            cell.lineWidth = 0
            cell.position = CGPoint(width/2, cellHeight * CGFloat(i) + cellHeight/2)
            cell.isHidden = true
            return cell
        }
        super.init()
        addChild(gaugeFrame)
        gaugeFrame.path = createGaugePath(fullHeight: fullHeight, cellCount: cellCount)
        gaugeFrame.strokeColor = Palette.mesh
        for cell in cells {
            addChild(cell)
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func createGaugePath(fullHeight: CGFloat, cellCount: Int) -> CGPath {
        let path = CGMutablePath()
        let width: CGFloat = 21
        let cellHeight = fullHeight / 18
        let height = cellHeight * CGFloat(cellCount)

        path.move(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: width, y: 0 ))
        path.addLine(to: CGPoint(x: width, y: height))
        for index in 1...cellCount {
            let i = CGFloat(index)
            path.move(to: CGPoint(x: 0, y: i * cellHeight))
            path.addLine(to: CGPoint(x: 4, y: i * cellHeight))
            path.move(to: CGPoint(x: width-4, y: i * cellHeight))
            path.addLine(to: CGPoint(x: width, y: i * cellHeight))
        }
        return path
    }
}
