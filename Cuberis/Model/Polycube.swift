//
//  Polycube.swift
//  Cuberis
//

import SceneKit

struct PolycubeInfo: Codable {
    let index: Int
    let highScore: Int // score (dropped from top position)
    let lowScore: Int  // score (non dropped)
    let basic: Bool    // from the basic set
    let flat: Bool     // from the flat set
}

struct Orientation: Codable {
    let r0: Int
    let r1: Int
    let r2: Int
}

func loadPolycubes(from url: URL) -> [Polycube] {
    struct JSONPolycube: Codable {
        let info: PolycubeInfo
        let orientations: [Orientation]
        let cells: [Vector3i]
    }
    do {
        let jsonPolycubes = try JSONDecoder().decode([JSONPolycube].self, from: try Data(contentsOf: url))
        return jsonPolycubes.map { Polycube(cubes: $0.cells, allRot: $0.orientations, info: $0.info) }
    } catch {
        let error = error as NSError
        fatalError("Unresolved error \(error), \(error.userInfo)")
    }
}

struct Polycube {
    let info: PolycubeInfo
    let center: Vector3i
    let cubes: [Vector3i]
    let allRot: [Orientation]
    let width: Int
    let height: Int
    let depth: Int

    init(cubes: [Vector3i], allRot: [Orientation], info: PolycubeInfo) {
        self.info = info
        self.cubes = cubes
        self.allRot = allRot
        width = Polycube.width(of: cubes)
        height = Polycube.height(of: cubes)
        depth = Polycube.depth(of: cubes)
        center = Vector3i(x: width - 1,
                          y: 1,
                          z: depth - 1)
    }

    static func width(of cells: [Vector3i]) -> Int { (cells.max { $0.x < $1.x }?.x ?? 0) + 1 }
    static func height(of cells: [Vector3i]) -> Int { (cells.max { $0.y < $1.x }?.y ?? 0) + 1 }
    static func depth(of cells: [Vector3i]) -> Int { (cells.max { $0.z < $1.z }?.z ?? 0) + 1 }

    func haveVisibleFace(withIndex index: Int, in cube: Vector3i) -> Bool {
        let faceBorders = [[0, 0, -1], [-1, 0, 0], [0, 0, 1], [1, 0, 0], [0, 1, 0], [0, -1, 0]]
        return !cubes.contains(cube + Vector3i(faceBorders[index]))
    }
}

func fround(_ x: Float) -> Int { Int(x < 0.0 ? x - 0.5 : x + 0.5) }

extension Polycube {
    func cubes(afterRotation rotation: SCNMatrix4, andTranslation translation: Vector3i) -> [Vector3i] {
        return cubes.map {
            let r = (SCNVector3($0 - center) + SCNVector3(0.5, 0.5, 0.5)) * rotation
            return Vector3i(fround(r.x - 0.5), fround(r.y - 0.5), fround(r.z - 0.5)) + center + translation
        }
    }
}
