import
  math

import
  ../../assets/asset,
  texture

proc setRegionInternal(textureRegion: TextureRegion; u, v, u2, v2: var float) =
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

proc setRegion*(textureRegion: TextureRegion, x, y, width, height: float) =
  let invTexWidth = 1.0 / float textureRegion.texture.data.w
  let invTexHeight = 1.0 / float textureRegion.texture.data.h
  var u = x * invTexWidth
  var v = y * invTexHeight
  var u2 = (x + width) * invTexWidth
  var v2 = (y + height) * invTexHeight

  setRegionInternal(textureRegion, u, v, u2, v2)


proc init*(textureRegion: TextureRegion, texture: Texture, x, y, width, height: float) =
  textureRegion.texture = texture
  textureRegion.setRegion(x, y, width, height)