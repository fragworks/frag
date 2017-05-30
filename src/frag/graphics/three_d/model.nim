#[import
  os

import
  assimp

import
  ../../assets/asset_types,
  ../../assets/asset,
  ../../logger,
  mesh,
  pos_tex_vertex

#export Model

proc offset*[A](some: ptr A; b: int): ptr A =
  result = cast[ptr A](cast[int](some) + (b * sizeof(A)))

proc hasUVCords*(some: PMesh): bool {.inline.} = (some.vertexCount > 0 and
  not some.texCoords[0].isNil)

proc processMesh(model: var Model, mesh: PMesh) =
  
  var m = Mesh(
      vertexCount: mesh.vertexCount,
      indexCount: mesh.faceCount * 3,
      firstIndex: model.numIndices,
      firstVertex: model.numVertices
    )

  m.vertices = @[]

  for i in 0..<m.vertexCount:
    let vert = mesh.vertices.offset(i)[]

    var vertex = PosTexVertex(
      x: vert.x,
      y: vert.y,
      z: vert.z
    )

    var texCoord : TVector3d
    if mesh.hasUVCords:
      texCoord = mesh.texCoords[0].offset(i)[]
    else:
      texCoord = (x: 0.0.cfloat, y: 0.0.cfloat, z: 0.0.cfloat)

    #vertex.u = texCoord.x.float32
    #vertex.v = texCoord.y.float32
    
    m.vertices.add(
      vertex
    )
  
    inc(model.numVertices)

  m.indices = newSeq[uint16](mesh.faceCount* 3)
  for i in 0..<mesh.faceCount:
    let indices = mesh.faces[i].indices
    assert mesh.faces[i].indexCount == 3
    m.indices[3 * i + 0] = indices[0].uint16
    m.indices[3 * i + 1] = indices[1].uint16
    m.indices[3 * i + 2] = indices[2].uint16
    inc(model.numIndices, 3)

  model.meshes.add(m)

proc loadOBJ*(filename: string): Model =
  let scene = aiImportFile(filename, aiProcessPreset_TargetRealtime_MaxQuality or aiProcess_MakeLeftHanded or aiProcess_FlipUVs)
  
  result = Model(
    assetType: AssetType.Model,
    meshes: @[]
  )

  for i in 0..<scene.meshCount:
    processMesh(result, scene.meshes[i])

proc load*(filename: string): Model =
  discard
  let ext = splitFile(filename).ext
  case ext
  of ".obj":
    return loadOBJ(filename)
  else:
    logWarn "Extension : " & ext & " not recgonized."

]#