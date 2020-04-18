//
//  PitMeshNode.swift
//  Cuberis
//

import SceneKit

class PitMeshNode: SCNNode {

    init(size: Size3i) {
        super.init()
        geometry = createPitMeshGeometry(size: size)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createPitMeshGeometry(size: Size3i) -> SCNGeometry {
        var indices: [Int32] = []
        var vertices: [SCNVector3] = []
        let w = size.width
        let h = size.height
        let d = size.depth

        // depth layers
        for i in 0..<d {
            let verticeCubes = [[0, h, -i], [w, h, -i], [0, 0, -i], [w, 0, -i]]
            vertices.append(contentsOf: verticeCubes.map { SCNVector3($0) })
            indices.append(contentsOf: [0, 1, 1, 3, 3, 2, 2, 0].map { Int32($0 + 4 * i) })
        }

        // vertical layers
        var verticesCount = vertices.count
        for i in 0...w {
            let verticeCubes = [[i, 0, 0], [i, 0, -d], [i, h, -d], [i, h, 0]]
            vertices.append(contentsOf: verticeCubes.map { SCNVector3($0) })
            indices.append(contentsOf: [0, 1, 1, 2, 2, 3].map { Int32(verticesCount + $0 + 4 * i) })
        }
        verticesCount = vertices.count
        // horisontal layers
        for i in 0...h {
            let verticeCubes = [[0, i, 0], [0, i, -d], [w, i, -d], [w, i, 0]]
            vertices.append(contentsOf: verticeCubes.map { SCNVector3($0) })
            indices.append(contentsOf: [0, 1, 1, 2, 2, 3].map { Int32(verticesCount + $0 + 4 * i) })
        }

        let geometry = SCNGeometry(sources: [SCNGeometrySource(vertices: vertices)],
                                   elements: [SCNGeometryElement(indices: indices, primitiveType: .line)])
        geometry.firstMaterial?.lightingModel = SCNMaterial.LightingModel.constant
        geometry.firstMaterial?.diffuse.contents = Palette.mesh
        return geometry
    }

}
