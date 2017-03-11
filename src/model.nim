import assimp, glm, opengl, os

import asset, log, texture

type
  Model* = ref object of Asset
    vao: GLuint
    entries: seq[MeshEntry]
    textures: seq[Texture]
    vertices: seq[Vertex]
    indices: seq[GLushort]
    vb: GLuint
    ib: GLuint
  
  MeshEntry = object
    numIndices: int
    materialIndex: int
    baseVertex: int
    baseIndex: int
  
  Vertex = object
    pos: Vec3[GLfloat]
    texCoord: Vec2[GLfloat]
    normal: Vec3[GLfloat]
    
const ASSIMP_LOAD_FLAGS = aiProcess_Triangulate or aiProcess_GenSmoothNormals or aiProcess_FlipUVs or aiProcess_JoinIdenticalVertices

proc offset*[A](some: ptr A; b: int): ptr A =
  result = cast[ptr A](cast[int](some) + (b * sizeof(A)))

proc newVertex(position: Vec3[GLfloat], texCoord: Vec2[GLfloat], normal: Vec3[GLfloat]) : Vertex =
  result = Vertex()
  result.pos = position
  result.texCoord = texCoord
  result.normal = normal

proc newMeshEntry(materialIndex: int) : MeshEntry =
  result = MeshEntry()
  result.materialIndex = materialIndex

proc hasUVCords*(some: PMesh): bool {.inline.} = (some.vertexCount > 0 and
  not some.texCoords[0].isNil)

#[
proc initMeshEntry(meshEntry: var MeshEntry, vertices: var seq[Vertex], indices: var seq[GLushort]) =
  meshEntry.numIndices = indices.len

  glGenBuffers(1, addr meshEntry.vb)
  glBindBuffer(GL_ARRAY_BUFFER, meshEntry.vb)
  glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex) * vertices.len, vertices[0].addr, GL_STATIC_DRAW)

  glGenBuffers(1, addr meshEntry.ib)
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, meshEntry.ib)
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLushort) * indices.len, indices[0].addr, GL_STATIC_DRAW)
]#

proc initMeshEntry(model: Model) =
  glGenBuffers(1, addr model.vb)
  glBindBuffer(GL_ARRAY_BUFFER, model.vb)
  glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex) * model.vertices.len, model.vertices[0].addr, GL_STATIC_DRAW)
  glEnableVertexAttribArray(0)
  glEnableVertexAttribArray(1)
  glEnableVertexAttribArray(2)
  glVertexAttribPointer(0, 3, cGL_FLOAT, GL_FALSE, GLsizei sizeof(Vertex), nil)
  glVertexAttribPointer(1, 2, cGL_FLOAT, GL_FALSE, GLsizei sizeof(Vertex), cast[pointer](sizeof(Vec3f)))
  glVertexAttribPointer(2, 3, cGL_FLOAT, GL_FALSE, GLsizei sizeof(Vertex), cast[pointer](sizeof(Vec2f) + sizeof(Vec3f)))

  glGenBuffers(1, addr model.ib)
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, model.ib)
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLushort) * model.indices.len, model.indices[0].addr, GL_STATIC_DRAW)

proc initMesh(model: var Model, index: int, mesh: PMesh, currentVertex: int, currentIndex: int) : tuple[vertexCount: int, indexCount: int] =
  var newMeshEntry = newMeshEntry(mesh.materialIndex)
  newMeshEntry.baseVertex = currentVertex
  newMeshEntry.baseIndex = currentIndex

  var vertices : seq[Vertex] = @[]
  var indices : seq[GLushort] = @[]
  
  for i in 0..<mesh.vertexCount:
    let pos = mesh.vertices.offset(i)[]
    let normal = mesh.normals.offset(i)[]
    var texCoord : TVector3d
    if mesh.hasUVCords:
      texCoord = mesh.texCoords[0].offset(i)[]
    else:
      texCoord = (x: 0.0.cfloat, y: 0.0.cfloat, z: 0.0.cfloat)
    
    vertices.add(
      newVertex(
        vec3[GLfloat](pos.x, pos.y, pos.z)
        , vec2[GLfloat](texCoord.x, texCoord.y)
        , vec3[GLfloat](normal.x, normal.y, normal.z)
      )
    )

    model.vertices.add(
      newVertex(
        vec3[GLfloat](pos.x, pos.y, pos.z)
        , vec2[GLfloat](texCoord.x, texCoord.y)
        , vec3[GLfloat](normal.x, normal.y, normal.z)
      )
    )
  
  for i in 0..<mesh.faceCount:
    let face = mesh.faces[i]
    assert face.indexCount == 3
    indices.add(GLushort face.indices[0])
    indices.add(GLushort face.indices[1])
    indices.add(GLushort face.indices[2])

  for i in 0..<mesh.faceCount:
    let face = mesh.faces[i]
    assert face.indexCount == 3
    model.indices.add(GLushort face.indices[0])
    model.indices.add(GLushort face.indices[1])
    model.indices.add(GLushort face.indices[2])
  
  newMeshEntry.numIndices = mesh.faceCount * 3

  model.entries.add(
    newMeshEntry
  )

  (model.vertices.len, model.indices.len)

proc initMaterials*(model: var Model, scene: PScene, filename: string) : Model =
  for i in 0..<scene.materialCount:
    var path : AIString
    var material = scene.materials[i]
    if getTexture(material, TexDiffuse, 0, addr path) == ReturnSuccess:
      let filename = splitPath(filename).head & DirSep & $path
      load(filename)
      model.textures.add(Texture(get(filename)))

  return model

proc initModel*(model: var Asset, scene: PScene, filename: string) : Model =
  var m = Model(model)
  glGenVertexArrays(1, addr m.vao)
  glBindVertexArray(m.vao)
  m.entries = @[]
  m.textures = @[]
  m.vertices = @[]
  m.indices = @[]

  var currentVertex = 0
  var currentIndex = 0
  for i in 0..<scene.meshCount:
    (currentVertex, currentIndex) = initMesh(m, i, scene.meshes[i], currentVertex, currentIndex)
  
  initMeshEntry(m)

  glBindVertexArray(0)

  initMaterials(m, scene, filename)


proc loadModel*(filename: string) : Asset {.procvar.} =
  if not fileExists(filename):
    logError "Unable to load model with filename : " & filename & " file does not exist!"
    return
 
  let scene = aiImportFile(filename, ASSIMP_LOAD_FLAGS)
  if not scene.isNil:
    if scene.meshCount > 0:
      result = Model()
      return initModel(result, scene, filename)
    else:
      logWarn "No meshes found in filename : " & filename 
      aiReleaseImport(scene)
  else:
    logError "Assimp error loading model with filename : " & filename & " : " & $getError()

proc render*(model: Model) =
  glBindVertexArray(model.vao)

  for entry in model.entries:
    if model.textures.len > 0:
      model.textures[entry.materialIndex - 1].`bind`()

    glDrawElementsBaseVertex(
      GL_TRIANGLES,
      GLsizei entry.numIndices,
      GL_UNSIGNED_SHORT,
      cast[pointer](sizeof(GLushort) * int entry.baseIndex),
      GLint entry.baseVertex
    )

  glBindVertexArray(0)