//
//  Statistics.swift
//  Cuberis
//

import Foundation

struct Statistics {
    private(set) var score = 0
    private(set) var cubesPlayed = 0
    private(set) var polycubesPlayed = 0
    private(set) var singleLayerClears  = 0
    private(set) var doubleLayerClears = 0
    private(set) var tripleLayerClears = 0
    private(set) var quadrupleLayerClears = 0
    private(set) var quintupleLayerClears = 0
    private(set) var timesPitIsEmpty = 0

    private let polycubeSet: PolycubeSet
    private let pitDepth: Int

    init(polycubeSet: PolycubeSet, pitDepth: Int) {
        self.polycubeSet = polycubeSet
        self.pitDepth = pitDepth
    }

    mutating func accountScores(for polycube: Polycube,
                                onLevel level: Int,
                                layersRemoved: Int,
                                isPitEmpty: Bool,
                                droppedFrom dropPosition: Int?) {
        // PolyCube level Factor (from level 0 to 10)
        let polyCubeLevelFactor = [0.066990, 0.139195, 0.219800, 0.308444, 0.403897, 0.507822,
                            0.619062, 0.738630, 0.865802, 1.000000, 1.133333]
        // Layer level Factor (from level 0 to 10)
        let layerLevelFactor = [0.096478, 0.163873, 0.242913, 0.328261, 0.422329, 0.518394,
                           0.630405, 0.747501, 0.867087, 1.000000, 1.131653]
        // Depth Factor (from depth 6 to 18)
        let depthFactor = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.557692, 1.367521, 1.217949, 1.100427, 1.000000,
                           0.918803, 0.852564, 0.788996, 0.737714, 0.691774, 0.651709, 0.614850, 0.583868]
        // Layer number factor (from 1 to 5)
        let layerNumberFactor = [0.0, 1.000000, 3.703372, 8.104827, 14.188325, 22.144941]
        // Layer base score (FLAT,BASIC,EXTENDED)
        let layerBase = [762.5, 875.5, 2886.25]

        let dropPosition = max(dropPosition ?? 0, 0)

        // Polycube score
        let positionFactor = Double(dropPosition) / Double(pitDepth - 1)
        let lowScore = Double(polycube.info.lowScore)
        let highScore = Double(polycube.info.highScore)
        let polycubeScore = (lowScore + (highScore - lowScore) * positionFactor) * polyCubeLevelFactor[level]

        // Layer score
        let layerScore = layerBase[polycubeSet.rawValue] * layerLevelFactor[level] * layerNumberFactor[layersRemoved]

        // Multiple layers bonus when pit is empty
        let pitScore = isPitEmpty ? layerBase[polycubeSet.rawValue] * layerLevelFactor[level] * layerNumberFactor[2] : 0

        // Total score
        let totalScore = (layerScore + polycubeScore + pitScore) * depthFactor[pitDepth]

        score += max(fround(Float(totalScore)), 1)
        polycubesPlayed += 1
        cubesPlayed += polycube.cubes.count
        if isPitEmpty { timesPitIsEmpty += 1 }
        switch layersRemoved {
        case 1: singleLayerClears += 1
        case 2: doubleLayerClears += 1
        case 3: tripleLayerClears += 1
        case 4: quadrupleLayerClears += 1
        case 5: quintupleLayerClears += 1
        default: break
        }
    }
}
