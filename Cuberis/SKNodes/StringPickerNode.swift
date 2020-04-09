//
//  StringPickerNode.swift
//  Cuberis
//

import SpriteKit

class StringPickerNode: PickerNode {
    var index: Int = 0 {
        didSet {
            if oldValue != index && enabled { changed?() }
            labelNode.text = options[index]
        }
    }
    let options: [String]

    init(options: [String]) {
        self.options = options
        super.init()
        labelNode.text = options[0]
        labelNode.position = CGPoint(0, -9)
        decreaseButton.action = { self.index = self.index - 1 < 0 ? self.options.count - 1 : self.index - 1 }
        increaseButton.action = { self.index = self.index + 1 == self.options.count ? 0 : self.index + 1 }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
