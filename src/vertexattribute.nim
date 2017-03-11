import opengl

type
  Usage = enum
    USAGE_NB = 0, POSITION = 1, COLOR_UNPACKED = 2, COLOR_PACKED = 4, NORMAL = 8, TEXTURE_COORDINATES = 16
  
  VertexAttribute* = object
    usage: Usage
    numComponents*: int
    normalized*: bool
    `type`*: GLenum
    offset*: int
    alias*: string
    unit: int

  VertexAttributes* = object
    attributes: seq[VertexAttribute]
    vertexSize*: int

proc newVertexAttribute*(usage: Usage, numComponents: int, `type`: GLenum, normalized: bool, alias: string, unit: int) : VertexAttribute =
  result = VertexAttribute(usage:USAGE_NB)
  result.usage = usage
  result.numComponents = numComponents
  result.`type` = `type`
  result.normalized = normalized
  result.alias = alias
  result.unit = unit

proc newVertexAttribute*(usage: Usage, numComponents: int, alias: string, unit: int) : VertexAttribute =
  if usage == COLOR_PACKED:
    return newVertexAttribute(usage, numComponents, GL_UNSIGNED_BYTE, usage == COLOR_PACKED, alias, unit) 
  else:
    return newVertexAttribute(usage, numComponents, cGL_FLOAT, usage == COLOR_PACKED, alias, unit) 

proc newVertexAttribute*(usage: Usage, numComponents: int, alias: string) : VertexAttribute =
  newVertexAttribute(usage, numComponents, alias, 0)

proc getSizeInBytes(vertexAttribute: VertexAttribute) : int =
  case vertexAttribute.`type`
  of cGL_FLOAT:
    return 4 * vertexAttribute.numComponents
  of cGL_UNSIGNED_BYTE:
    return vertexAttribute.numComponents
  of cGL_UNSIGNED_SHORT:
    return 2 * vertexAttribute.numComponents
  else:
    return 0

proc calculateOffsets(vertexAttributes: var VertexAttributes) : int =
  var count = 0
  for attribute in vertexAttributes.attributes.mitems:
    attribute.offset = count
    count += getSizeInBytes(attribute)

  return count

proc get*(vertexAttributes: VertexAttributes, index: int) : VertexAttribute =
  return vertexAttributes.attributes[index]

proc size*(vertexAttributes: VertexAttributes) : int =
  return vertexAttributes.attributes.len
  
proc newVertexAttributes*(attributes: varargs[VertexAttribute]) : VertexAttributes =
  result = VertexAttributes()

  var list : seq[VertexAttribute] = @[]
  for attribute in attributes:
    add(list, attribute)

  result.attributes = list
  result.vertexSize = calculateOffsets(result)