# TODO: (ZC) BMPs MipMaps
import
  logging,
  os

import
  opengl,
  sdl2 as sdl,
  sdl2.image as sdl_img

import
  ../../assets/asset_types,
  ../../assets/asset

export Texture

const PNG_HEADER_BYTES : seq[uint8] = @[137'u8, 80'u8, 78'u8, 71'u8, 13'u8, 10'u8, 26'u8, 10'u8]

proc verifyImageHeader(filename: string, size: int, data: seq[uint8]) : bool =
  var i : int
  var tmp : array[128, uint8]

  var rwOps = sdl.rwFromFile(filename, "rb")
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

proc loadPNG*(filename: string) : Texture {.procvar.} =
  if not fileExists(filename):
    error "Unable to load PNG with filename : " & filename & " file does not exist!"
    return

  if not verifyPNG(filename):
    error "Unable to load PNG with filename : " & filename & " not a PNG file!"

  var texture = Texture(assetType: AssetType.Texture)
  texture.filename = filename
  texture.data = sdl_img.load(filename.cstring)

  if texture.data.isNil:
    error "Error loading PNG : " & $sdl.getError()
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

proc `bind`*(texture: Texture) =
  glBindTexture(GL_TEXTURE_2D, texture.handle)

proc load*(filename: string): Texture =
  let ext = splitFile(filename).ext
  case ext
  of ".png":
    return loadPNG(filename)
  else:
    warn "Extension : " & ext & " not recognized."

proc unload*(texture: Texture) =
  glDeleteTextures(1, addr texture.handle)

  sdl.destroy(texture.data)
