# TODO: (ZC) BMPs MipMaps
import
  os

import
  bgfxdotnim as bgfx,
  sdl2 as sdl,
  stb_image/read as stbi

when defined(android):
  import
    sdl2/image as sdl_image

import
  ../../assets/asset_types,
  ../../assets/asset,
  ../../logger

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

proc init*(texture: Texture) =
  when defined(android):
    if texture.data.format.BytesPerPixel == 4:
      texture.handle = bgfx_create_texture_2d(uint16 texture.data.w, uint16 texture.data.h, false, 1, BGFX_TEXTURE_FORMAT_RGBA8, 0, bgfx_copy(texture.data.pixels, uint32 texture.data.w * texture.data.h * 4))
    else:
      texture.handle = bgfx.bgfx_create_texture_2d(uint16 texture.data.w, uint16 texture.data.h, false, 1, BGFX_TEXTURE_FORMAT_RGB8, 0, bgfx_copy(texture.data.pixels, uint32 texture.data.w * texture.data.h * 3))
  else:
    if texture.channels == 4:
      texture.handle = bgfx_create_texture_2d(uint16 texture.width, uint16 texture.height, false, 1, BGFX_TEXTURE_FORMAT_RGBA8, 0, bgfx_copy(addr texture.data[0], uint32 texture.width * texture.height * 4))
    else:
      texture.handle = bgfx.bgfx_create_texture_2d(uint16 texture.width, uint16 texture.height, false, 1, BGFX_TEXTURE_FORMAT_RGB8, 0, bgfx_copy(addr texture.data[0], uint32 texture.width * texture.height * 3))

proc loadPNG*(filename: string) : Texture {.procvar.} =
  var texture = Texture(assetType: AssetType.Texture)
  texture.filename = filename

  when defined(android):
    texture.data = sdl_image.load(filename)

  else:
    if not fileExists(filename):
      logError "Unable to load PNG with filename : " & filename & " file does not exist!"
      return

    if not verifyPNG(filename):
      logError "Unable to load PNG with filename : " & filename & " not a PNG file!"

    texture.data = stbi.load(filename, texture.width, texture.height, texture.channels, stbi.Default)

  if texture.data.isNil:
    logError "Error loading Texture! " & filename
    return

  return texture

proc load*(filename: string): Texture =
  let ext = splitFile(filename).ext
  case ext
  of ".png":
    return loadPNG(filename)
  else:
    logWarn "Extension : " & ext & " not recognized."

proc unload*(texture: Texture) =
  bgfx_destroy_texture(texture.handle)
