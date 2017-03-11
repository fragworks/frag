import opengl

import vertex, vertexattribute

type
  VBO* = object
    vertexBuffer: seq[Vertex]
    bufferHandle: GLuint
    dirty: bool
    dynamic: bool

proc newVBO*(dynamic: bool) : VBO =
  result = VBO()
  result.vertexBuffer = @[]
  glGenBuffers(1, addr result.bufferHandle)
  result.dirty = true
  result.dynamic = dynamic

proc size*(vbo: VBO) : int =
  return vbo.vertexBuffer.len

proc add*(vbo: var VBO, vertices: seq[Vertex]) =
  vbo.vertexBuffer.add(vertices)
  vbo.dirty = true

proc `bind`*(vbo: var VBO) =
  glBindBuffer(GL_ARRAY_BUFFER, vbo.bufferHandle)
  if vbo.dirty:
    if vbo.dynamic:
      glBufferData(GL_ARRAY_BUFFER, GLsizeiptr(vbo.vertexBuffer.len * sizeof(Vertex)), vbo.vertexBuffer[0].addr, GL_DYNAMIC_DRAW)
    else:
     glBufferData(GL_ARRAY_BUFFER, GLsizeiptr(vbo.vertexBuffer.len * sizeof(Vertex)), vbo.vertexBuffer[0].addr, GL_STATIC_DRAW)
    vbo.dirty = false

proc clear*(vbo: var VBO) =
  vbo.vertexBuffer.setLen(0)
  vbo.dirty = true