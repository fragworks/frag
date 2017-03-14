import 
    glm, 
    opengl

import 
    ibo, 
    vbo, 
    vertex

type
  Mesh* = object
    vao: GLuint
    vbo: VBO
    ibo: IBO
    dynamic: bool

proc newMesh*(dynamic: bool) : Mesh =
  result = Mesh()
  result.dynamic = dynamic
  result.vbo = newVBO(dynamic)
  result.ibo = newIBO(dynamic)
  glGenVertexArrays(1, addr result.vao)

proc setIndices*(mesh: var Mesh, indices: seq[GLushort]) =
  mesh.ibo.setIndices(indices)

proc addVertices*(mesh: var Mesh, vertices: seq[Vertex]) =
  mesh.vbo.add(vertices)

proc `bind`*(mesh: var Mesh) =
  glBindVertexArray(mesh.vao)
  mesh.vbo.`bind`()
  mesh.ibo.`bind`()

proc render*(mesh: var Mesh) =
  glEnableVertexAttribArray(0)
  glVertexAttribPointer(0, 3, cGL_FLOAT, GL_FALSE, GLsizei sizeof(Vertex), nil)

  glEnableVertexAttribArray(1)
  glVertexAttribPointer(1, 2, cGL_FLOAT, GL_FALSE, GLsizei sizeof(Vertex), cast[pointer](sizeof(Vec3f)))

  glEnableVertexAttribArray(2)
  glVertexAttribPointer(2, 4, cGL_FLOAT, GL_FALSE, GLsizei sizeof(Vertex), cast[pointer](sizeof(Vec2f) + sizeof(Vec3f)))
  
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, mesh.ibo.handle())
  glDrawElements(GL_TRIANGLES, GLsizei mesh.ibo.size(),GL_UNSIGNED_SHORT,nil)

  glDisableVertexAttribArray(0)
  glDisableVertexAttribArray(1)
  glDisableVertexAttribArray(2)
  glBindVertexArray(0)

  mesh.vbo.clear()

proc indexCount*(mesh: var Mesh) : int =
  return mesh.ibo.size()