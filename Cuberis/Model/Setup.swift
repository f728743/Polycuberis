//
//  Setup.swift
//  Cuberis
//

import Foundation

enum PolycubeSet: Int, CaseIterable {
    case flat
    case basic
    case extended
    static let names = ["Flat", "Basic", "Extended"]
}

struct ModeSetup {
    let name: String
    let pitSize: Size3i
    let polycubeSet: PolycubeSet
}

enum GameMode: Int, CaseIterable {
    case flatFun
    case the3DMania
    case outOfControl
    case custom
    static let names = ["Flat Fun", "3D Mania", "Out of control", "Custom"]
}

struct Setup {
    static let levelRange = 0...9
    static let customWidthRange =  3...7
    static let customHeighthRange =  3...7
    static let customDepthRange =  6...18
    static let defaultMode = GameMode.flatFun
    static let defaultLevel = 1
    static let defaultWidth = 5
    static let defaultHeight = 5
    static let defaultDepth = 12
    static let defaultPolycubeSet = PolycubeSet.flat

    var modeIdentifier: String {
        switch mode {
        case .flatFun, .the3DMania, .outOfControl: return GameMode.names[mode.rawValue]
        case .custom: return GameMode.names[mode.rawValue] + " \(pitSize.width)x\(pitSize.height)"
        }
    }
    var level: Int
    var mode: GameMode
    var customSetup: ModeSetup
    var pitSize: Size3i { mode == .custom ? customSetup.pitSize : setups[mode.rawValue].pitSize }
    var polycubeSet: PolycubeSet { mode == .custom ? customSetup.polycubeSet : setups[mode.rawValue].polycubeSet }
    var name: String { mode == .custom ? customSetup.name : setups[mode.rawValue].name }

    enum UserDefaultsKey: String {
        case gameLevel
        case gameMode
        case pitWidth, pitHeight, pitDepth
        case polycubeSet
    }

    private let setups = [ModeSetup(name: GameMode.names[GameMode.flatFun.rawValue],
                                    pitSize: Size3i(width: 5, height: 5, depth: 12),
                                    polycubeSet: .flat),
                          ModeSetup(name: GameMode.names[GameMode.the3DMania.rawValue],
                                    pitSize: Size3i(width: 3, height: 3, depth: 10),
                                    polycubeSet: .basic),
                          ModeSetup(name: GameMode.names[GameMode.outOfControl.rawValue],
                                    pitSize: Size3i(width: 5, height: 5, depth: 10),
                                    polycubeSet: .extended)]

    init() {
        level = Setup.defaultLevel
        mode = Setup.defaultMode
        customSetup = ModeSetup(name: GameMode.names[GameMode.custom.rawValue],
                                pitSize: Size3i(width: Setup.defaultWidth,
                                                height: Setup.defaultHeight,
                                                depth: Setup.defaultDepth),
                                polycubeSet: Setup.defaultPolycubeSet)
    }

    func save() {
        save(level, forKey: .gameLevel)
        save(mode.rawValue, forKey: .gameMode)
        save(customSetup.pitSize.width, forKey: .pitWidth)
        save(customSetup.pitSize.height, forKey: .pitHeight)
        save(customSetup.pitSize.depth, forKey: .pitDepth)
        save(customSetup.polycubeSet.rawValue, forKey: .polycubeSet)
    }

    mutating func load() {
        level = loadInt(forKey: .gameLevel) ?? Setup.defaultLevel
        mode = GameMode(rawValue: loadInt(forKey: .gameMode) ?? Setup.defaultMode.rawValue) ?? Setup.defaultMode
        let width = loadInt(forKey: .pitWidth) ?? Setup.defaultWidth
        let height = loadInt(forKey: .pitHeight) ?? Setup.defaultHeight
        let depth = loadInt(forKey: .pitDepth) ?? Setup.defaultDepth
        let set = PolycubeSet(rawValue: loadInt(forKey: .polycubeSet) ??
            Setup.defaultPolycubeSet.rawValue) ?? Setup.defaultPolycubeSet
        customSetup = ModeSetup(name: customSetup.name,
                                pitSize: Size3i(width: width, height: height, depth: depth),
                                polycubeSet: set)
    }

    private func save(_ value: Int, forKey key: UserDefaultsKey) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
    private func loadInt(forKey key: UserDefaultsKey) -> Int? {
        return UserDefaults.standard.object(forKey: key.rawValue) as? Int ?? 5
    }

}
