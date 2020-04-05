//
//  SceneManager.swift
//  Cuberis
//

import SpriteKit

struct SceneManager {
    var mainMenu: MainMenuScene!
    var gamepad: GamepadScene!

    init(viewSize: CGSize) {
        mainMenu = MainMenuScene(size: viewSize)
        gamepad = GamepadScene(size: viewSize)
    }
}
