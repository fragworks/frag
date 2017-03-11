import glm

type
  Vertex* = object
    position: Vec3f
    texCoord: Vec2f
    color: Vec4f

proc newVertex*(position: Vec3f, texCoord: Vec2f, color: Vec4f) : Vertex =
  result = Vertex()
  result.position = position
  result.texCoord = texCoord
  result.color = color
