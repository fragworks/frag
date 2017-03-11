import math, opengl, os, sdl2, sdl2.image

import asset, log

const PNG_HEADER_BYTES : seq[uint8] = @[137'u8, 80'u8, 78'u8, 71'u8, 13'u8, 10'u8, 26'u8, 10'u8]

type
  Texture* = ref object of Asset
    handle: GLuint
    filename: string
    data*: SurfacePtr
  
  TextureRegion* = ref object of Asset
    texture*: Texture
    u*, v*, u2*, v2*: float
    regionWidth*, regionHeight*: int

proc setRegion*(textureRegion: var TextureRegion; u, v, u2, v2: var float) =
  var
    texWidth: int = textureRegion.texture.data.w
    texHeight: int = textureRegion.texture.data.h
  textureRegion.regionWidth = int round(abs(u2 - u) * float texWidth)
  textureRegion.regionHeight = int round(abs(v2 - v) * float texHeight)
  ##  For a 1x1 region, adjust UVs toward pixel center to avoid filtering artifacts on AMD GPUs when drawing very stretched.
  if textureRegion.regionWidth == 1 and textureRegion.regionHeight == 1:
    var adjustX: float = 0.25 / float texWidth
    u = u + adjustX
    u2 = u2 - adjustX
    var adjustY: float = 0.25 / float texHeight
    v = v + adjustY
    v2 = v2 - adjustY
  textureRegion.u = u
  textureRegion.v = v2
  textureRegion.u2 = u2
  textureRegion.v2 = v

proc setRegion(textureRegion: var TextureRegion, x, y, width, height: int) =
  var invTexWidth = 1.0 / float textureRegion.texture.data.w
  var invTexHeight = 1.0 / float textureRegion.texture.data.h
  var u = float(x) * invTexWidth
  var v = float(y) * invTexHeight
  var u2 = float(x + width) * invTexWidth
  var v2 = float(y + height) * invTexHeight
  setRegion(textureRegion, u, v, u2, v2)

proc newTextureRegion*(texture: Texture, x, y, width, height: int) : TextureRegion =
  result = TextureRegion()
  result.texture = texture
  setRegion(result, x, y, width, height)

proc newTextureRegion*(texture: Texture) : TextureRegion =
  result = TextureRegion()
  result.texture = texture
  setRegion(result, 0, 0, texture.data.w, texture.data.h)

proc `bind`*(texture: Texture) =
  glBindTexture(GL_TEXTURE_2D, texture.handle)

proc verifyImageHeader(filename: string, size: int, data: seq[uint8]) : bool =
  var i : int
  var tmp : array[128, uint8]
  
  var rwOps = rwFromFile(filename, "rb")
  if rwOps.isNil:
    return false
  
  i = rwOps.read(rwOps, addr tmp, size, 1)
  
  if i != 1:
    discard rwOps.close(rwOps)
    return false
  
  discard rwOps.close(rwOps)

  for i in 0..<size:
    if tmp[i] != data[i]:
      return false
  
  return true

proc verifyPNG*(filename: string) : bool =
  return verifyImageHeader(filename, sizeof(PNG_HEADER_BYTES), PNG_HEADER_BYTES)

proc loadBMP*(filename: string) : Asset {.procvar.} =
  if not fileExists(filename):
    logError "Unable to load PNG with filename : " & filename & " file does not exist!"
    return

  #if not verifyPNG(filename):
    #logError "Unable to load PNG with filename : " & filename & " not a PNG file!"

  var texture = Texture()
  texture.filename = filename
  texture.data = load(filename.cstring)

  if texture.data.isNil:
    logError "Error loading BMP : " & $getError()
    return
    
  glGenTextures(1, addr texture.handle)

  glBindTexture(GL_TEXTURE_2D, texture.handle)
  
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB.ord, texture.data.w, texture.data.h, 0, GL_RGB, GL_UNSIGNED_BYTE, texture.data.pixels)
  #glGenerateMipmap(GL_TEXTURE_2D)

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)

  glBindTexture(GL_TEXTURE_2D, 0)

  return texture

proc loadPNG*(filename: string) : Asset {.procvar.} =
  if not fileExists(filename):
    logError "Unable to load PNG with filename : " & filename & " file does not exist!"
    return

  if not verifyPNG(filename):
    logError "Unable to load PNG with filename : " & filename & " not a PNG file!"

  var texture = Texture()
  texture.filename = filename
  texture.data = load(filename.cstring)

  if texture.data.isNil:
    logError "Error loading PNG : " & $getError()
    return
    
  glGenTextures(1, addr texture.handle)

  glBindTexture(GL_TEXTURE_2D, texture.handle)
  
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA.ord, texture.data.w, texture.data.h, 0, GL_RGBA, GL_UNSIGNED_BYTE, texture.data.pixels)
  #glGenerateMipmap(GL_TEXTURE_2D)

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)

  glBindTexture(GL_TEXTURE_2D, 0)

  return texture

proc unloadTexture*(filename: string) {.procvar.} =
  let texture = Texture get(filename)
  if texture.isNil:
    logError "Unable to unload PNG with filename : " & filename
    return
  
  glDeleteTextures(1, addr texture.handle)
  destroy(texture.data)

proc setFilter*(texture: Texture, minFilter: GLint, maxFilter: GLint) =
  texture.`bind`()
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, minFilter)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, maxFilter)