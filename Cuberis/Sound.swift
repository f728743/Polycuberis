//
//  Sound.swift
//  Cuberis
//

import SceneKit

enum SoundType {
    case move
    case hit
    case empty
    case layer
    case levelUp
}

struct Sound {
    let move = SCNAudioSource(named: "Move.wav")!
    let hit = SCNAudioSource(named: "Hit.wav")!
//    var hit: SCNAudioSource { hits[Int(drand48() * Double(hits.count))] }
//    let hits = [SCNAudioSource(named: "Hit1.wav")!,
//                       SCNAudioSource(named: "Hit2.wav")!,
//                       SCNAudioSource(named: "Hit3.wav")!]
    let empty = SCNAudioSource(named: "Empty.wav")!
    let layer = SCNAudioSource(named: "Layer.wav")!
    let levelUp = SCNAudioSource(named: "LevelUp.wav")!
    init () {
        move.load()
        hit.load()
        empty.load()
        layer.load()
        levelUp.load()
    }

    func play(_ soundType: SoundType, on node: SCNNode) {
        switch soundType {
        case .move: node.runAction(SCNAction.playAudio(move, waitForCompletion: false))
        case .hit: node.runAction(SCNAction.playAudio(hit, waitForCompletion: false))
        case .empty: node.runAction(SCNAction.playAudio(empty, waitForCompletion: false))
        case .layer: node.runAction(SCNAction.playAudio(layer, waitForCompletion: false))
        case .levelUp:
            let wait = SCNAction.wait(duration: 0.4)
            let play = SCNAction.playAudio(levelUp, waitForCompletion: false)
            node.runAction(SCNAction.sequence([wait, play]))
        }

    }
}
