//
//  SKScene+Extension.swift
//  Cuberis
//

import SpriteKit

extension SKScene {
    var safeAreaInsets: UIEdgeInsets { UIApplication.shared.keyWindow?.safeAreaInsets ?? UIEdgeInsets() }
}
