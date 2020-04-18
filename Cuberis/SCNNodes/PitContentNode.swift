//
//  PitContentNode.swift
//  Cuberis
//

import SceneKit

class PitContentNode: SCNNode {

    init(pit: Pit) {
        super.init()
        addContentNodes(of: pit)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createCubeEdges() -> SCNGeometry {
        let edgeVertices = [[0, 0, 0], [0, 1, 0], [1, 1, 0], [1, 0, 0],
                           [0, 0, 1], [0, 1, 1], [1, 1, 1], [1, 0, 1]]
        let vertices = edgeVertices.map { SCNVector3($0[0], $0[1], -$0[2]) }
        let source = SCNGeometrySource(vertices: vertices)
        let edgeIndices: [Int32] = [0, 1, 1, 2, 2, 3, 3, 0,
                                    4, 5, 5, 6, 6, 7, 7, 4,
                                    0, 4, 1, 5, 2, 6, 3, 7]
        let edges = SCNGeometryElement(indices: edgeIndices, primitiveType: .line)
        return SCNGeometry(sources: [source], elements: [edges])
    }

    private func createCubeFaces() -> SCNGeometry {
        let mesh = deduplicate(
            vertices: cubeVertices.flatMap { $0.map { SCNVector3($0[0], $0[1], -$0[2]) } },
            indices: (0..<6).flatMap { n in faceIndices.map { Int32(n * 4 + $0) } })
        let source = SCNGeometrySource(vertices: mesh.vertices)
        let faces = SCNGeometryElement(indices: mesh.indices, primitiveType: .triangles)
        return SCNGeometry(sources: [source], elements: [faces])
    }

    private func addContentNodes(of pit: Pit) {
        let cube = createCubeFaces()
        cube.firstMaterial?.diffuse.contents = Palette.layers[1]
        let cubeEdges = createCubeEdges()
        cubeEdges.firstMaterial?.lightingModel = SCNMaterial.LightingModel.constant
        cubeEdges.firstMaterial?.diffuse.contents = UIColor.black
        let bottom = -pit.depth + 1
        for layer in bottom..<bottom + pit.pileHeight {
            guard let layerCube = cube.copy() as? SCNGeometry else { fatalError() }
            layerCube.materials = cube.materials.map { ($0.copy() as? SCNMaterial ?? SCNMaterial()) }
            let colorIndex = (pit.depth + layer - 1) % Palette.layers.count
            layerCube.firstMaterial?.diffuse.contents = Palette.layers[colorIndex]
            addContentNodes(of: pit, layer: layer, cubeGeometry: layerCube, cubeEdges: cubeEdges)
        }
    }

    private func addContentNodes(of pit: Pit, layer: Int, cubeGeometry: SCNGeometry, cubeEdges: SCNGeometry) {
        for y in 0..<pit.height {
            for x in 0..<pit.width {
                let cell = Vector3i(x, y, layer)
                if pit.isOccupied(at: cell) {
                    let cubeFacesNode = SCNNode(geometry: cubeGeometry)
                    let facesScale: Float = 0.999
                    cubeFacesNode.position = SCNVector3(cell) +
                        SCNVector3(1, 1, -1) * ((1.0 - facesScale) / 2)
                    cubeFacesNode.scale = .unit * facesScale
                    addChildNode(cubeFacesNode)
                    let edgesScale: Float = 1
                    let cubeEdgesNode = SCNNode(geometry: cubeEdges)
                    cubeEdgesNode.position = SCNVector3(cell) +
                        SCNVector3(1, 1, -1) * ((1.0 - edgesScale) / 2)
                    cubeEdgesNode.scale = .unit * edgesScale
                    addChildNode(cubeEdgesNode)
                }
            }
        }
    }
}
