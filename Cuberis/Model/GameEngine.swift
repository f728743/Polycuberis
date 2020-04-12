//
//  GameEngine.swift
//  Cuberis
//

import SceneKit

protocol GameEngineDelegate: AnyObject {
    func didSpawnNew(polycube: Polycube, at position: Vector3i, rotated rotation: SCNMatrix4)
    func didMove(by delta: Vector3i, andRotateBy rotationDelta: SCNMatrix4)
    func didUpdateContent(of pit: Pit)
    func didUpdate(statistics: Statistics)
    func didСlearLayers(count: Int, andPit isEmpty: Bool)
    func didChangeLevel(to level: Int)
    func gameOver()
}

extension GameEngineDelegate {
    func didSpawnNew(polycube: Polycube, at position: Vector3i, rotated rotation: SCNMatrix4) {}
    func didMove(by delta: Vector3i, andRotateBy rotationDelta: SCNMatrix4) {}
    func didUpdate(statistics: Statistics) {}
    func didChangeLevel(to level: Int) {}
    func didСlearLayers(count: Int, andPit isEmpty: Bool) {}
    func didUpdateContent(of pit: Pit) {}
    func gameOver() {}
}

class GameEngine {
    static let maxLevel = 9
    var level: Int
    var statistics: Statistics
    let cubesPerLevel: Int

    let timeBase: TimeInterval = 5.51
    let timeLevelFactor = 0.69
    var stepTime: TimeInterval
    var timer: Timer?
    var pauseTime: TimeInterval?

    var isDropHappened = false
    var dropPosition = 0

    var pit: Pit
    let polycubeSet: [Polycube]
    var currentPolycube: Polycube?
    var position = Vector3i()
    var rotation = SCNMatrix4Identity

    weak var delegate: GameEngineDelegate?

    init(pitSize: Size3i, polycubeSet: PolycubeSet, level: Int) {
        self.level = min(level, GameEngine.maxLevel)
        statistics = Statistics(polycubeSet: polycubeSet, pitDepth: pitSize.depth)
        stepTime = timeBase * pow(timeLevelFactor, Double(self.level))
        cubesPerLevel = pitSize.height * 15 + pitSize.width * 15

        pit = Pit(size: pitSize)
        let url = Bundle.main.resourceURL!.appendingPathComponent("polycubes.json")
        let minPitSzie = min(pit.width, pit.depth)
        self.polycubeSet = loadPolycubes(from: url) .filter {
            $0.isIn(set: polycubeSet) && $0.width <= minPitSzie && $0.height <= minPitSzie && $0.depth <= minPitSzie
        }
        srand48(Int(Date().timeIntervalSince1970))
    }

    func gameOver() {
        delegate?.gameOver()
    }

    func scheduleStepTimer(afterDrop: Bool) {
        let interval: TimeInterval = afterDrop ? 0.6 : pauseTime ?? stepTime
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.step()
        }
    }

    func newPolycube() {
        let polycube = polycubeSet[Int(drand48() * Double(polycubeSet.count))]
        position = Vector3i()
        currentPolycube = polycube
        rotation = SCNMatrix4Identity
        delegate?.didSpawnNew(polycube: polycube, at: position, rotated: rotation)
        if isOverlapped(afterRotation: rotation, andTranslation: position) {
            gameOver()
            return
        }
        isDropHappened = false
        dropPosition = pit.depth - 1
        scheduleStepTimer(afterDrop: false)
    }

    func isOverlapped(afterRotation rotation: SCNMatrix4, andTranslation translation: Vector3i) -> Bool {
        return !overlap(afterRotation: rotation, andTranslation: translation).cells.isEmpty
    }

    func overlap(afterRotation newRotation: SCNMatrix4,
                 andTranslation newTranslation: Vector3i) -> (cells: [Vector3i], excess: Vector3i) {
        var excess = Vector3i()
        var cells = [Vector3i]()
        guard let polycube = currentPolycube else { return (cells: [], excess: Vector3i()) }
        for cell in polycube.cubes(afterRotation: newRotation, andTranslation: newTranslation) {
            if !pit.includes(cell: cell) || pit.isOccupied(at: cell) { cells.append(cell) }
            let cellExcess = pit.excess(of: cell)
            if abs(cellExcess.x) > abs(excess.x) { excess.x = cellExcess.x }
            if abs(cellExcess.y) > abs(excess.y) { excess.y = cellExcess.y }
            if abs(cellExcess.z) > abs(excess.z) { excess.z = cellExcess.z }
        }
        return (cells: cells, excess: excess)
    }

    func move(by delta: Vector3i) {
        guard pauseTime == nil else { return }
        let newPosition = position + delta
        if !isOverlapped(afterRotation: rotation, andTranslation: newPosition) {
            position = newPosition
            delegate?.didMove(by: delta, andRotateBy: SCNMatrix4Identity)
        }
    }

    func rotate(by rotationDelta: SCNMatrix4) {
        guard pauseTime == nil else { return }
        let newRotation = (rotation.transposed() * rotationDelta).transposed()
        let overlap = self.overlap(afterRotation: newRotation, andTranslation: position)
        if !overlap.cells.isEmpty {
            let overlapAfterCorrection = self.overlap(afterRotation: newRotation,
                                                      andTranslation: position + overlap.excess)
            if overlapAfterCorrection.cells.isEmpty {
                let newPosition = position + overlap.excess
                rotation = newRotation
                position = newPosition
                delegate?.didMove(by: overlap.excess, andRotateBy: rotationDelta)
            }
        } else {
            rotation = newRotation
            delegate?.didMove(by: Vector3i(), andRotateBy: rotationDelta)
        }
    }

    func moveDeep() {
        guard pauseTime == nil else { return }
        if isDropHappened { return }
        var probe = position
        let delta = Vector3i(0, 0, -1)
        while !isOverlapped(afterRotation: rotation, andTranslation: probe + delta) { probe += delta }
        isDropHappened = true
        move(by: probe - position)
        scheduleStepTimer(afterDrop: true)
    }

    func step() {
        guard let polycube = currentPolycube else { fatalError("Current polycube fucked up") }
        let delta = Vector3i(0, 0, -1)
        dropPosition -= 1
        if isOverlapped(afterRotation: rotation, andTranslation: position + delta) {
            pit.add(cubes: polycube.cubes(afterRotation: rotation, andTranslation: position))
            let layersRemoved = pit.removeLayers()
            let isPitEmpty = pit.isEmpty
            delegate?.didUpdateContent(of: pit)
            statistics.accountScores(for: polycube,
                                     onLevel: level,
                                     layersRemoved: layersRemoved,
                                     isPitEmpty: isPitEmpty,
                                     droppedFrom: isDropHappened ? dropPosition : nil)
            if layersRemoved > 0 {
                delegate?.didСlearLayers(count: layersRemoved, andPit: isPitEmpty)
            }
            delegate?.didUpdate(statistics: statistics)
            if level <= GameEngine.maxLevel {
                if statistics.cubesPlayed >= cubesPerLevel * (level + 1) {
                    level += 1
                    delegate?.didChangeLevel(to: level)
                    stepTime *= timeLevelFactor
                }
            }
            newPolycube()
        } else {
            move(by: delta)
            scheduleStepTimer(afterDrop: false)
        }
    }
}

extension GameEngine: GamepadProtocol {
    func rotateXClockwise() { rotate(by: SCNMatrix4MakeRotation(Float.pi / 2.0, -1.0, 0.0, 0.0)) }
    func rotateXCounterclockwise() { rotate(by: SCNMatrix4MakeRotation(Float.pi / 2.0, 1.0, 0.0, 0.0)) }
    func rotateYClockwise() { rotate(by: SCNMatrix4MakeRotation(Float.pi / 2.0, 0.0, -1.0, 0.0)) }
    func rotateYCounterclockwise() { rotate(by: SCNMatrix4MakeRotation(Float.pi / 2.0, 0.0, 1.0, 0.0)) }
    func rotateZClockwise() { rotate(by: SCNMatrix4MakeRotation(Float.pi / 2.0, 0.0, 0.0, -1.0)) }
    func rotateZCounterclockwise() { rotate(by: SCNMatrix4MakeRotation(Float.pi / 2.0, 0.0, 0.0, 1.0)) }
    func moveUp() { move(by: Vector3i(x: 0, y: 1, z: 0)) }
    func moveDown() { move(by: Vector3i(x: 0, y: -1, z: 0)) }
    func moveLeft() { move(by: Vector3i(x: -1, y: 0, z: 0)) }
    func moveRight() { move(by: Vector3i(x: 1, y: 0, z: 0)) }
    func drop() { moveDeep() }
    func pause() {
        pauseTime = timer?.fireDate.timeIntervalSinceNow
        timer?.invalidate()
    }
    func resume() {
        scheduleStepTimer(afterDrop: false)
        pauseTime = nil
    }
}
