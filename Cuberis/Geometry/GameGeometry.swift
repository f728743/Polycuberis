//
//  GameGeometry.swift
//  Cuberis
//

import Foundation
import SceneKit

class GameGeometry {
    let viewSize: CGSize
    let pitSize: PitSize
    let cubeVertices = [
        [[0, 0, 0], [0, 1, 0], [1, 1, 0], [1, 0, 0]],
        [[0, 0, 1], [0, 1, 1], [0, 1, 0], [0, 0, 0]],
        [[1, 0, 1], [1, 1, 1], [0, 1, 1], [0, 0, 1]],
        [[1, 0, 0], [1, 1, 0], [1, 1, 1], [1, 0, 1]],
        [[0, 1, 0], [0, 1, 1], [1, 1, 1], [1, 1, 0]],
        [[1, 0, 0], [1, 0, 1], [0, 0, 1], [0, 0, 0]]
    ]
    let faceIndices = [0, 2, 1, 0, 3, 2]
    var cubeSize: Float { 5.0 / Float(pitSize.height) }
    var cameraPosition: SCNVector3 {
        return SCNVector3(x: Float(pitSize.width) * cubeSize / 2.0,
                          y: Float(pitSize.height) * cubeSize / 2.0,
                          z: 5.0)
    }

    init(viewSize: CGSize, pitSize: PitSize) {
        self.viewSize = viewSize
        self.pitSize = pitSize
    }

    private func createCubeFaces(size: Float) -> SCNGeometry {
        let mesh = deduplicate(
            vertices: cubeVertices.flatMap { $0.map { SCNVector3($0[0], $0[1], -$0[2]) * size } },
            indices: (0..<6).flatMap { n in faceIndices.map { Int32(n * 4 + $0) } })
        let source = SCNGeometrySource(vertices: mesh.vertices)
        let faces = SCNGeometryElement(indices: mesh.indices, primitiveType: .triangles)
        return SCNGeometry(sources: [source], elements: [faces])
    }

    func createContentNode(of pit: Pit) -> SCNNode {
        let palette: [UIColor] = [.systemBlue, .systemGreen, .systemTeal,
                                   .systemRed, .systemPurple, .systemOrange, .systemGray]
        let cube = createCubeFaces(size: cubeSize)
        cube.firstMaterial?.diffuse.contents = palette[1]
        let node = SCNNode()
        var layer = -pit.depth + 1
        while layer <= 0 && !pit.isEmpty(layer: layer) {
            guard let layerCube = cube.copy() as? SCNGeometry else { fatalError() }
            layerCube.materials = cube.materials.map { ($0.copy() as? SCNMaterial ?? SCNMaterial()) }
            let colorIndex = (pit.depth + layer - 1) % palette.count
            layerCube.firstMaterial?.diffuse.contents = palette[colorIndex]
            for y in 0..<pit.height {
                for x in 0..<pit.width {
                    let cell = Vector3i(x, y, layer)
                    if pit.isOccupied(at: cell) {
                        let cubeFacesNode = SCNNode(geometry: layerCube)
                        let facesScale: Float = 0.98
                        cubeFacesNode.position = SCNVector3(cell) * cubeSize + .unit * ((1.0 - facesScale) / 2)
                        cubeFacesNode.scale = .unit * facesScale
                        node.addChildNode(cubeFacesNode)
                    }
                }
            }
            layer += 1
        }
        return node
    }

    func createPitFrameNode() -> SCNNode {
        var indices: [Int32] = []
        var vertices: [SCNVector3] = []
        let w = pitSize.width
        let h = pitSize.height
        let d = pitSize.depth

        // depth layers
        for i in 0..<d {
            let verticeCubes = [[0, h, -i], [w, h, -i], [0, 0, -i], [w, 0, -i]]
            vertices.append(contentsOf: verticeCubes.map { SCNVector3($0) * cubeSize })
            indices.append(contentsOf: [0, 1, 1, 3, 3, 2, 2, 0].map { Int32($0 + 4 * i) })
        }

        // vertical layers
        var verticesCount = vertices.count
        for i in 0...w {
            let verticeCubes = [[i, 0, 0], [i, 0, -d], [i, h, -d], [i, h, 0]]
            vertices.append(contentsOf: verticeCubes.map { SCNVector3($0) * cubeSize })
            indices.append(contentsOf: [0, 1, 1, 2, 2, 3].map { Int32(verticesCount + $0 + 4 * i) })
        }
        verticesCount = vertices.count
        // horisontal layers
        for i in 0...h {
            let verticeCubes = [[0, i, 0], [0, i, -d], [w, i, -d], [w, i, 0]]
            vertices.append(contentsOf: verticeCubes.map { SCNVector3($0) * cubeSize })
            indices.append(contentsOf: [0, 1, 1, 2, 2, 3].map { Int32(verticesCount + $0 + 4 * i) })
        }

        let geometry = SCNGeometry(sources: [SCNGeometrySource(vertices: vertices)],
                                   elements: [SCNGeometryElement(indices: indices, primitiveType: .line)])
        geometry.firstMaterial?.lightingModel = SCNMaterial.LightingModel.constant
        geometry.firstMaterial?.diffuse.contents = UIColor.systemGreen
        return SCNNode(geometry: geometry)
    }

    func createNode(of polycube: Polycube) -> SCNNode {
        var vertices: [SCNVector3] = []
        var indices: [Int32] = []
        var faceCount = 0

        func addFace(withIndex faceIndex: Int, of cube: Vector3i) {
            vertices.append(contentsOf: cubeVertices[faceIndex].map {
                SCNVector3(Vector3i($0[0], $0[1], -$0[2]) + cube) * cubeSize
            })
            indices.append(contentsOf: faceIndices.map { Int32(faceCount * 4 + $0) })
            faceCount += 1
        }
        for cell in polycube.cubes {
            for faceIndex in 0..<6 {
                if polycube.haveVisibleFace(withIndex: faceIndex, in: cell) {
                    addFace(withIndex: faceIndex, of: cell)
                }
            }
        }

        let mesh = deduplicate(vertices: vertices, indices: indices)
        let element = SCNGeometryElement(indices: mesh.indices, primitiveType: .triangles)
        let source = SCNGeometrySource(vertices: mesh.vertices)
        let geometry = SCNGeometry(sources: [source], elements: [element])
        geometry.firstMaterial?.diffuse.contents = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.6)

        let node = SCNNode(geometry: geometry)
        node.pivot = SCNMatrix4MakeTranslation(SCNVector3(polycube.center) * cubeSize)
        let parent = SCNNode()
        parent.addChildNode(node)
        return parent
    }

    private func deduplicate(vertices: [SCNVector3], indices: [Int32]) -> (vertices: [SCNVector3], indices: [Int32]) {
        var indicesOfVertices: [SCNVector3: Int32] = [:]
        var maxIndex: Int32 = 0
        var result: (vertices: [SCNVector3], indices: [Int32]) = (vertices: [], indices: [])
        for i in indices {
            let vertex = vertices[Int(i)]
            if let pointIndex = indicesOfVertices[vertex] {
                result.indices.append(pointIndex)
            } else {
                let pointIndex = maxIndex
                maxIndex += 1
                indicesOfVertices[vertex] = pointIndex
                result.vertices.append(vertex)
                result.indices.append(pointIndex)
            }
        }
        return result
    }
}
