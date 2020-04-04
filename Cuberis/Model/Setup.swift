//
//  Setup.swift
//  Cuberis
//

import Foundation

struct PolycubeSet {
    let basic: Bool
    let flat: Bool
    let maxSize: Int
}

struct Setup {
    let speed: Int
    let pitSize: PitSize
    let polycubeSet: PolycubeSet
}

enum UserDefaultsKey: String {
    case gameSpeed
    case pitWidth, pitHeight, pitDepth
    case basicPolycubeSet, flatPolycubeSet, maxPolycubeSize
}

func save(setup: Setup) {
    let defaults = UserDefaults.standard
    defaults.set(setup.speed, forKey: UserDefaultsKey.gameSpeed.rawValue)
    defaults.set(setup.pitSize.width, forKey: UserDefaultsKey.pitWidth.rawValue)
    defaults.set(setup.pitSize.height, forKey: UserDefaultsKey.pitHeight.rawValue)
    defaults.set(setup.pitSize.height, forKey: UserDefaultsKey.pitDepth.rawValue)
    defaults.set(setup.polycubeSet.basic, forKey: UserDefaultsKey.basicPolycubeSet.rawValue)
    defaults.set(setup.polycubeSet.flat, forKey: UserDefaultsKey.flatPolycubeSet.rawValue)
    defaults.set(setup.polycubeSet.maxSize, forKey: UserDefaultsKey.maxPolycubeSize.rawValue)
}

func loadSetup() -> Setup {
    let defaults = UserDefaults.standard
    let gameSpeed = defaults.object(forKey: UserDefaultsKey.gameSpeed.rawValue) as? Int ?? 0

    let pitWidth = defaults.object(forKey: UserDefaultsKey.pitWidth.rawValue) as? Int ?? 5
    let pitHeight = defaults.object(forKey: UserDefaultsKey.pitHeight.rawValue) as? Int ?? 5
    let pitDepth = defaults.object(forKey: UserDefaultsKey.pitDepth.rawValue) as? Int ?? 12

    let basic = defaults.object(forKey: UserDefaultsKey.basicPolycubeSet.rawValue) as? Bool ?? false
    let flat = defaults.object(forKey: UserDefaultsKey.pitDepth.rawValue) as? Bool ?? true
    let maxSize = defaults.object(forKey: UserDefaultsKey.maxPolycubeSize.rawValue) as? Int ?? 5

    return Setup(speed: gameSpeed,
                 pitSize: PitSize(width: pitWidth, height: pitHeight, depth: pitDepth),
                 polycubeSet: PolycubeSet(basic: basic, flat: flat, maxSize: maxSize))
}
