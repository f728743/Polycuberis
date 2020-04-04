//
//  PolycubeNode.swift
//  Cuberis
//

import SceneKit

class PolycubeNode: SCNNode {

    init(polycube: Polycube) {
        super.init()
        addChildNode(createNode(of: polycube))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func createNode(of polycube: Polycube) -> SCNNode {
        var vertices: [SCNVector3] = []
        var indices: [Int32] = []
        var faceCount = 0

        func addFace(withIndex faceIndex: Int, of cube: Vector3i) {
            vertices.append(contentsOf: cubeVertices[faceIndex].map {
                SCNVector3(Vector3i($0[0], $0[1], -$0[2]) + cube)
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
        node.pivot = SCNMatrix4MakeTranslation(SCNVector3(polycube.center))
        return node
    }
}
