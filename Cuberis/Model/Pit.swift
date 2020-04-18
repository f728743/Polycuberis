//
//  Pit.swift
//  Cuberis
//

import Foundation

struct Pit {
    let size: Size3i
    var width: Int { size.width }
    var height: Int { size.height }
    var depth: Int { size.depth }
    var isEmpty: Bool { isEmpty(layer: -depth + 1) }
    var pileHeight: Int {
        var pile = 0
        var layer = -depth + 1
        while layer <= 0 && !isEmpty(layer: layer) {
            layer += 1
            pile += 1
        }
        return pile
    }

    private var cells: [Int]

    init(size: Size3i) {
        self.size = size
        cells = Array(repeating: 0, count: size.width * size.height * size.depth)
    }

    func indexOf(x: Int, y: Int, z: Int) -> Int { x + y * width + -z * width * height }
    func index(of cell: Vector3i) -> Int { indexOf(x: cell.x, y: cell.y, z: cell.z) }

    mutating func add(cubes: [Vector3i]) {
        cubes.forEach { cells[index(of: $0)] = 1 }
    }

    mutating func collapse(layer: Int, upTo bound: Int) {
        var i = layer
        while i < bound {
            copy(layer: i + 1, toLayer: i)
            i += 1
        }
        fill(layer: bound, with: 0)
    }

    mutating func removeLayers() -> Int {
        var removed = 0
        var i = (-depth + 1)
        while i < -removed {
            if isFull(layer: i) {
                collapse(layer: i, upTo: -removed)
                removed += 1
            } else {
                i += 1
            }
        }
        return removed
    }

    func includes(cell: Vector3i) -> Bool { excess(of: cell) == Vector3i() }

    func isOccupied(at cell: Vector3i) -> Bool { cells[index(of: cell)] != 0 }

    mutating func setCell(_ cell: Vector3i, value: Int) {
        guard includes(cell: cell) else { return }
        cells[index(of: cell)] = value
    }

    func excess(of cell: Vector3i) -> Vector3i {
        Vector3i(x: excess(of: cell.x, over: width),
                 y: excess(of: cell.y, over: height),
                 z: -excess(of: -cell.z, over: depth))
    }

    func allSatisfy(ofLayer layer: Int, condition: (Int) -> Bool) -> Bool {
        for y in 0..<height {
            for x in 0..<width {
                if !condition(cells[indexOf(x: x, y: y, z: layer)]) { return false }
            }
        }
        return true
    }

    func isFull(layer: Int) -> Bool { allSatisfy(ofLayer: layer) { $0 != 0 } }

    func isEmpty(layer: Int) -> Bool { allSatisfy(ofLayer: layer) { $0 == 0 } }

    private mutating func fill(layer: Int, with value: Int) {
        for y in 0..<height {
            for x in 0..<width {
                cells[indexOf(x: x, y: y, z: layer)] = value
            }
        }
    }

    private mutating func copy(layer: Int, toLayer: Int) {
        for y in 0..<height {
            for x in 0..<width {
                cells[indexOf(x: x, y: y, z: toLayer)] = cells[indexOf(x: x, y: y, z: layer)]
            }
        }
    }

    private func excess(of v: Int, over n: Int) -> Int { v < 0 ? -v : v >= n ? n - v - 1 : 0 }
}
