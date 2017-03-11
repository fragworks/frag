import opengl

type
  IBO* = object
    indexBuffer: seq[GLushort]
    bufferHandle: GLuint
    dirty: bool
    dynamic: bool

proc handle*(ibo: IBO) : GLuint =
  return ibo.bufferHandle

proc newIBO*(dynamic: bool) : IBO =
  result = IBO()
  result.indexBuffer = @[]
  glGenBuffers(1, addr result.bufferHandle)
  result.dynamic = dynamic
  result.dirty = true

proc size*(ibo: var IBO) : int =
  return ibo.indexBuffer.len

proc add*(ibo: var IBO, indices: seq[GLushort]) =
  ibo.indexBuffer.add(indices)
  ibo.dirty = true

proc `bind`*(ibo: var IBO) =
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo.bufferHandle)
  if ibo.dirty:
    if ibo.dynamic:
      glBufferData(GL_ELEMENT_ARRAY_BUFFER, GLsizeiptr(ibo.indexBuffer.len * sizeof(GLushort)), ibo.indexBuffer[0].addr, GL_DYNAMIC_DRAW)
    else:
     glBufferData(GL_ELEMENT_ARRAY_BUFFER, GLsizeiptr(ibo.indexBuffer.len * sizeof(GLushort)), ibo.indexBuffer[0].addr, GL_STATIC_DRAW)
    ibo.dirty = false

proc clear*(ibo: var IBO) =
  ibo.indexBuffer.setLen(0)
  ibo.dirty = true

proc setIndices*(ibo: var IBO, indices: seq[GLushort]) =
  ibo.indexBuffer = indices
  ibo.dirty = true