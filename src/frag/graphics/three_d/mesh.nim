import
  pos_tex_vertex

type
  Mesh* = object
    vertexCount*, indexCount*: int
    vertices*: seq[PosTexVertex]
    indices*: seq[uint16]
    firstVertex*, firstIndex*: int