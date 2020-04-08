//
//  SceneManager.swift
//  Cuberis
//

import SpriteKit

struct SceneManager {
    let mainMenu: MainMenuScene
    let gamepad: GamepadScene
    let setup: SetupScene

    init(viewSize: CGSize) {
        mainMenu = MainMenuScene(size: viewSize)
        gamepad = GamepadScene(size: viewSize)
        setup = SetupScene(size: viewSize)
    }
}
