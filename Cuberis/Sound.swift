//
//  Sound.swift
//  Cuberis
//

import SpriteKit

enum SoundType {
    case move
    case hit
    case step
    case empty
    case layer
    case levelUp
}

func play(_ soundType: SoundType, on node: SKNode) {
    switch soundType {
    case .move: node.run(SKAction.playSoundFileNamed("Move.wav", waitForCompletion: false))
    case .hit: node.run(SKAction.playSoundFileNamed("Hit.wav", waitForCompletion: false))
    case .step: node.run(SKAction.playSoundFileNamed("Step.wav", waitForCompletion: false))
    case .empty: node.run(SKAction.playSoundFileNamed("Empty.wav", waitForCompletion: false))
    case .layer: node.run(SKAction.playSoundFileNamed("Layer.wav", waitForCompletion: false))
    case .levelUp:
        let wait = SKAction.wait(forDuration: 0.4)
        let play = SKAction.playSoundFileNamed("LevelUp.wav", waitForCompletion: false)
        node.run(SKAction.sequence([wait, play]))
    }
}
