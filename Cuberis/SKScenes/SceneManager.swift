//
//  SceneManager.swift
//  Cuberis
//

import SpriteKit

struct SceneManager {
    let mainMenu: MainMenuScene
    let gamepad: GamepadScene
    let setup: OptionsScene

    init(viewSize: CGSize) {
        mainMenu = MainMenuScene(size: viewSize)
        gamepad = GamepadScene(size: viewSize)
        setup = OptionsScene(size: viewSize)
    }
}
