//
//  GamepadProtocol.swift
//  Cuberis
//

import Foundation

protocol GamepadProtocol: AnyObject {
    func rotateXClockwise()
    func rotateXCounterclockwise()
    func rotateYClockwise()
    func rotateYCounterclockwise()
    func rotateZClockwise()
    func rotateZCounterclockwise()
    func moveUp()
    func moveDown()
    func moveLeft()
    func moveRight()
    func drop()
    func pause()
    func resume()
}

extension GamepadProtocol {
    func rotateXClockwise() {}
    func rotateXCounterclockwise() {}
    func rotateYClockwise() {}
    func rotateYCounterclockwise() {}
    func rotateZClockwise() {}
    func rotateZCounterclockwise() {}
    func moveUp() {}
    func moveDown() {}
    func moveLeft() {}
    func moveRight() {}
    func drop() {}
    func pause() {}
    func resume() {}
}
