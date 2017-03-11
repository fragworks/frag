import assimp, glm, math, opengl, os, tables

import asset, log, texture, util

type
  Model* = ref object of Asset
    vao: GLuint
    entries: seq[MeshEntry]
    textures: seq[Texture]
    vertices: seq[Vertex]
    indices: seq[GLushort]
    bones: seq[Bone]
    boneInfo: seq[BoneInfo]
    boneMapping: Table[string, int]
    vb: GLuint
    ib: GLuint
    bb: GLuint
    numBones: uint
    scene: PScene
    globalInverseTransform: Mat4f
  
  MeshEntry = object
    numIndices: int
    materialIndex: int
    baseVertex: int
    baseIndex: int
  
  Vertex = object
    pos: Vec3[GLfloat]
    texCoord: Vec2[GLfloat]
    normal: Vec3[GLfloat]

  Bone = object
    ids: array[4, GLint]
    weights: array[4, GLfloat]

  BoneInfo = object
    boneOffset: Mat4f
    finalTransformation: Mat4f
    
const ASSIMP_LOAD_FLAGS = aiProcess_Triangulate or aiProcess_GenSmoothNormals or aiProcess_FlipUVs or aiProcess_JoinIdenticalVertices

proc offset*[A](some: ptr A; b: int): ptr A =
  result = cast[ptr A](cast[int](some) + (b * sizeof(A)))

proc newVertex(position: Vec3[GLfloat], texCoord: Vec2[GLfloat], normal: Vec3[GLfloat]) : Vertex =
  result = Vertex()
  result.pos = position
  result.texCoord = texCoord
  result.normal = normal

proc hasUVCords*(some: PMesh): bool {.inline.} = (some.vertexCount > 0 and
  not some.texCoords[0].isNil)

proc findNodeAnim(animation: PAnimation, nodeName: string) : PNodeAnim =
  for i in 0..<animation.channelCount:
    let anim = animation.channels.offset(i)[]

    if $anim.nodeName.data == nodeName:
      return anim
  return nil

proc findScaling(animationTime: float, nodeAnim: PNodeAnim) : int =
  for i in 0..<nodeAnim.scalingKeyCount - 1:
    if animationTime < nodeAnim.scalingKeys.offset(i + 1).time:
      return i
  
  assert false
  return 0

proc calcInterpolatedScaling(scaling: var Vec3f, animationTime: float, nodeAnim: PNodeAnim) =
  if nodeAnim.scalingKeyCount == 1:
    let value = nodeAnim.scalingKeys.offset(0)[].value
    scaling = vec3f(value.x, value.y, value.z)
    return
  
  let scalingIndex = findScaling(animationTime, nodeAnim)
  let nextScalingIndex = scalingIndex + 1
  let deltaTime = nodeAnim.scalingKeys.offset(nextScalingIndex)[].time - nodeAnim.scalingKeys.offset(scalingIndex).time
  let factor = (animationTime - nodeAnim.scalingKeys.offset(scalingIndex)[].time) / deltaTime
  let start = nodeAnim.scalingKeys.offset(scalingIndex)[].value
  let `end` = nodeAnim.scalingKeys.offset(nextScalingIndex)[].value
  scaling = mix(vec3f(start.x, start.y, start.z), vec3f(`end`.x, `end`.y, `end`.z), factor)

proc findRotation(animationTime: float, nodeAnim: PNodeAnim) : int =
  for i in 0..<nodeAnim.rotationKeyCount - 1:
    if animationTime < nodeAnim.rotationKeys.offset(i + 1)[].time:
      return i
  
  assert false
  return 0


proc calcInterpolatedRotation(rotation: var Quatf, animationTime: float, nodeAnim: PNodeAnim) =
  if nodeAnim.rotationKeyCount == 1:
    let value = nodeAnim.rotationKeys.offset(0)[].value
    rotation = quatf(value.x, value.y, value.z, value.w)
    return

  let rotationIndex = findRotation(animationTime, nodeAnim)
  let nextRotationIndex = rotationIndex + 1
  let deltaTime = nodeAnim.rotationKeys.offset(nextRotationIndex)[].time - nodeAnim.rotationKeys.offset(rotationIndex).time
  let factor = (animationTime - nodeAnim.rotationKeys.offset(rotationIndex).time) / deltaTime
  let startRotationQ = nodeAnim.rotationKeys.offset(rotationIndex)[].value
  let endRotationQ = nodeAnim.rotationKeys.offset(nextRotationIndex)[].value
  rotation = fastMix(
    quatf(startRotationQ.x, startRotationQ.y, startRotationQ.z, startRotationQ.w), 
    quatf(endRotationQ.x, endRotationQ.y, endRotationQ.z, endRotationQ.w), factor)

proc findPosition(animationTime: float, nodeAnim: PNodeAnim) : int =
  for i in 0..<nodeAnim.positionKeyCount - 1:
    if animationTime < nodeAnim.positionKeys.offset(i + 1)[].time:
      return i

  assert false
  return 0

proc calcInterpolatedPosition(translation: var Vec3f, animationTime: float, nodeAnim: PNodeAnim) =
  if nodeAnim.positionKeyCount == 1:
    let value = nodeAnim.positionKeys.offset(0)[].value
    translation = vec3f(value.x, value.y, value.z)
    return
  
  let positionIndex = findPosition(animationTime, nodeAnim)
  let nextPositionIndex = positionIndex + 1
  let deltaTime = nodeAnim.positionKeys.offset(nextPositionIndex)[].time - nodeAnim.positionKeys.offset(positionIndex)[].time
  let factor = (animationTime - nodeAnim.positionKeys.offset(positionIndex)[].time) / deltaTime
  let start = nodeAnim.positionKeys.offset(positionIndex).value
  let `end` = nodeAnim.positionKeys.offset(nextPositionIndex).value
  translation = mix(vec3f(start.x, start.y, start.z), vec3f(`end`.x, `end`.y, `end`.z), factor)


proc readNodeHierarchy(model: var Model, animationTime: float, node: PNode, parentTransform: Mat4f) =
  let nodeName = $node.name.data
  let animation = model.scene.animations[0]
  var nodeTransformation = toMat4f(node.transformation)
  let nodeAnim = findNodeAnim(animation, nodeName)

  if not nodeAnim.isNil:
    var rotation : Quatf
    calcInterpolatedRotation(rotation, animationTime, nodeAnim)

    var scaling : Vec3f
    calcInterpolatedScaling(scaling, animationTime, nodeAnim)

    var translation : Vec3f
    calcInterpolatedPosition(translation, animationTime, nodeAnim)
    
    nodeTransformation = mat4(rotation, vec4f(0,0,0,1))
    
    nodeTransformation[0][0] *= scaling.x
    nodeTransformation[0][1] *= scaling.y
    nodeTransformation[0][2] *= scaling.z
    nodeTransformation[0][3] = translation.x

    nodeTransformation[1][0] *= scaling.x
    nodeTransformation[1][1] *= scaling.y
    nodeTransformation[1][2] *= scaling.z
    nodeTransformation[1][3] = translation.y

    nodeTransformation[2][0] *= scaling.x
    nodeTransformation[2][1] *= scaling.y
    nodeTransformation[2][2] *= scaling.z
    nodeTransformation[2][3] = translation.z

  var globalTransformation = nodeTransformation * parentTransform

  if model.boneMapping.contains(nodeName):
    var boneIndex = model.boneMapping[nodeName]
    model.boneInfo[int boneIndex].finalTransformation =  model.boneInfo[int boneIndex].boneOffset * globalTransformation * model.globalInverseTransform
  
  for i in 0..<node.childrenCount:
    readNodeHierarchy(model, animationTime, node.children[i], globalTransformation)

proc boneTransform*(model: var Model, timeInSeconds: float, transforms: var seq[Mat4f]) =
  var ticksPerSecond : float
  if model.scene.animations[0].ticksPerSec != 0:
    ticksPerSecond = model.scene.animations[0].ticksPerSec
  else:
    ticksPerSecond = 25.0
  
  var timeInTicks = timeInSeconds * ticksPerSecond
  var animationTime = fmod(timeInTicks,  float(model.scene.animations[0].duration))

  readNodeHierarchy(model, animationTime, model.scene.rootNode, mat4f(1.0))

  transforms = newSeq[Mat4f](model.numBones)

  for i in 0..<model.numBones:
    transforms[int i] = model.boneInfo[int i].finalTransformation

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

  glGenBuffers(1, addr model.bb)
  glBindBuffer(GL_ARRAY_BUFFER, model.bb)
  glBufferData(GL_ARRAY_BUFFER, sizeof(Bone) * model.bones.len, model.bones[0].addr, GL_STATIC_DRAW)
  glEnableVertexAttribArray(3)
  glVertexAttribIPointer(3, 4, cGL_INT, GLsizei sizeof(Bone), nil)
  glEnableVertexAttribArray(4)
  glVertexAttribPointer(4, 4, cGL_FLOAT, GL_FALSE, GLsizei sizeof(Bone), cast[pointer](sizeof(array[4, GLint])))

  glGenBuffers(1, addr model.ib)
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, model.ib)
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLushort) * model.indices.len, model.indices[0].addr, GL_STATIC_DRAW)

proc addBoneData(bone: var Bone, boneIndex: int, weight: float) =
  for i in 0..<4:
    if bone.weights[i] == 0.0:
      bone.ids[i] = GLint boneIndex
      bone.weights[i] = weight
      return
  
  assert(false)

proc initBones*(index: int, model: var Model, mesh: PMesh) =
  for i in 0..<mesh.boneCount:
    var boneIndex = 0
    let boneName = $mesh.bones[i].name.data
    if not model.boneMapping.contains(boneName):
      boneIndex = int model.numBones
      inc(model.numBones)
      var bi : BoneInfo
      model.boneInfo.add(bi)
      model.boneInfo[int boneIndex].boneOffset = toMat4f(mesh.bones[i].offsetMatrix)
      model.boneMapping.add(boneName, boneIndex)
    else:
      boneIndex = model.boneMapping[boneName]

    for j in 0..<mesh.bones[i].numWeights:
      let vertexId = model.entries[index].baseVertex + int mesh.bones[i].weights[j].vertexID
      let weight = mesh.bones[i].weights[j].weight
      model.bones[vertexId].addBoneData(boneIndex, weight)

proc initMesh(model: var Model, index: int, mesh: PMesh) =
  for i in 0..<mesh.vertexCount:
    let pos = mesh.vertices.offset(i)[]
    let normal = mesh.normals.offset(i)[]
    var texCoord : TVector3d
    if mesh.hasUVCords:
      texCoord = mesh.texCoords[0].offset(i)[]
    else:
      texCoord = (x: 0.0.cfloat, y: 0.0.cfloat, z: 0.0.cfloat)

    model.vertices.add(
      newVertex(
        vec3[GLfloat](pos.x, pos.y, pos.z)
        , vec2[GLfloat](texCoord.x, texCoord.y)
        , vec3[GLfloat](normal.x, normal.y, normal.z)
      )
    )

  initBones(index, model, mesh)

  for i in 0..<mesh.faceCount:
    let face = mesh.faces[i]
    assert face.indexCount == 3
    model.indices.add(GLushort face.indices[0])
    model.indices.add(GLushort face.indices[1])
    model.indices.add(GLushort face.indices[2])

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
  m.entries = newSeq[MeshEntry](scene.meshCount)
  glGenVertexArrays(1, addr m.vao)
  glBindVertexArray(m.vao)
  m.textures = @[]
  m.vertices = @[]
  m.indices = @[]
  m.boneMapping = initTable[string, int]()
  m.numBones = 0
  m.scene = scene
  m.boneInfo = @[]

  

  m.globalInverseTransform = toMat4f(scene.rootNode.transformation)
  m.globalInverseTransform = inverse(m.globalInverseTransform)

  var numVertices = 0
  var numIndices = 0

  for i in 0..<scene.meshCount: 
    m.entries[i].materialIndex = scene.meshes[i].materialIndex
    m.entries[i].numIndices = scene.meshes[i].faceCount * 3
    m.entries[i].baseVertex = numVertices
    m.entries[i].baseIndex = numIndices

    numVertices += scene.meshes[i].vertexCount
    numIndices += m.entries[i].numIndices

  m.bones = newSeq[Bone](numVertices)

  for i in 0..<scene.meshCount:
    initMesh(m, i, scene.meshes[i])

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
    #if model.textures.len > 0:
      #model.textures[entry.materialIndex - 1].`bind`()

    glDrawElementsBaseVertex(
      GL_TRIANGLES,
      GLsizei entry.numIndices,
      GL_UNSIGNED_SHORT,
      cast[pointer](sizeof(GLushort) * int entry.baseIndex),
      GLint entry.baseVertex
    )

  glBindVertexArray(0)