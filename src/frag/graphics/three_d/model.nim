import
  os

import
  assimp

import
  ../../assets/asset_types,
  ../../assets/asset,
  ../../logger,
  ../two_d/texture

export Model

proc offset*[A](some: ptr A; b: int): ptr A =
  result = cast[ptr A](cast[int](some) + (b * sizeof(A)))

proc hasUVCords*(some: PMesh): bool {.inline.} = (some.vertexCount > 0 and
  not some.texCoords[0].isNil)

proc loadMaterialTextures(model: Model, mat: PMaterial, textureType: TTextureType, typeName: string): seq[Texture] =
  result = @[]

  for i in 0..<mat.getTextureCount(textureType):
    var str: AIstring
    discard getTexture(mat, textureType, i.cint, addr str)

    var skip = false
    for textureLoaded in model.texturesLoaded:
      let fileParts = splitFile(textureLoaded.filename)
      let fileName = fileParts.name & fileParts.ext

      if filename == $str:
        result.add(textureLoaded)
        skip = true
        break

    if not skip:
      let filename = splitPath(model.filename).head & DirSep & $str
      
      var tex = texture.load(filename)
      tex.init()
      result.add(tex)
      model.texturesLoaded.add(tex)

proc processMesh(scene: PScene, model: var Model, mesh: PMesh) =
  
  var m = Mesh(
      vertexCount: mesh.vertexCount,
      indexCount: mesh.faceCount * 3,
      firstIndex: model.numIndices,
      firstVertex: model.numVertices,
      materialIndex: mesh.materialIndex,
      textures: @[]
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

    vertex.u = texCoord.x.float32
    vertex.v = texCoord.y.float32
    
    if mesh.hasNormals:
      var normal = mesh.normals.offset(i)[]

      vertex.normX = normal.x
      vertex.normY = normal.y
      vertex.normZ = normal.z
    
    if not mesh.tangents.isNil:
      var tangent = mesh.tangents.offset(i)[]
      vertex.tangentX = tangent.x
      vertex.tangentY = tangent.y
      vertex.tangentZ = tangent.z

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

  if mesh.materialIndex >= 0:
    let material = scene.materials[mesh.materialIndex]

    let diffuseMaps = model.loadMaterialTextures(material, TTextureType.TexDiffuse, "texture_diffuse")
    m.textures.add(diffuseMaps)

    let specularMaps = model.loadMaterialTextures(material, TTextureType.TexSpecular, "texture_specular")
    m.textures.add(specularMaps)

    let normalMaps = model.loadMaterialTextures(material, TTextureType.TexHeight, "texture_normal")
    m.textures.add(normalMaps)

    let ambientOcclusionMaps = model.loadMaterialTextures(material, TTextureType.TexAmbient, "texture_height")
    m.textures.add(ambientOcclusionMaps)


  model.meshes.add(m)

proc loadOBJ*(filename: string): Model =
  let scene = aiImportFile(filename, aiProcessPreset_TargetRealtime_MaxQuality or aiProcess_MakeLeftHanded or aiProcess_FlipUVs)
  
  result = Model(
    filename: filename,
    assetType: AssetType.Model,
    meshes: @[],
    texturesLoaded: @[]
  )

  for i in 0..<scene.meshCount:
    processMesh(scene, result, scene.meshes[i])

proc load*(filename: string): Model =
  discard
  let ext = splitFile(filename).ext
  case ext
  of ".obj":
    return loadOBJ(filename)
  else:
    logWarn "Extension : " & ext & " not recgonized."

