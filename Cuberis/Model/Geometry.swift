//
//  Geometry.swift
//  Cuberis
//

import SceneKit

let cubeVertices = [
    [[0, 0, 0], [0, 1, 0], [1, 1, 0], [1, 0, 0]],
    [[0, 0, 1], [0, 1, 1], [0, 1, 0], [0, 0, 0]],
    [[1, 0, 1], [1, 1, 1], [0, 1, 1], [0, 0, 1]],
    [[1, 0, 0], [1, 1, 0], [1, 1, 1], [1, 0, 1]],
    [[0, 1, 0], [0, 1, 1], [1, 1, 1], [1, 1, 0]],
    [[1, 0, 0], [1, 0, 1], [0, 0, 1], [0, 0, 0]]
]

let faceIndices = [0, 2, 1, 0, 3, 2]

func deduplicate(vertices: [SCNVector3], indices: [Int32]) -> (vertices: [SCNVector3], indices: [Int32]) {
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
