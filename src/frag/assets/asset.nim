import
  tables

import
  freetype,
  bgfxdotnim as bgfx
  #sdl2 as sdl

import
  asset_types

type
  #[
  Character* = object
    textureID*: GLuint
    size*: Vec2i
    bearing*: Vec2i
    advance*: GLuint
    height*: GLuint]#

  Asset* = object
    case assetType*: AssetType
    of AssetType.Texture:
      handle*: bgfx_texture_handle_t
      filename*: string
      data*: seq[uint8]
      channels*: int
      #data*: sdl.SurfacePtr
      width*: int
      height*: int
    of AssetType.TextureRegion:
      texture*: ref Asset
      u*, v*, u2*, v2*: float
      regionWidth*, regionHeight*: int

  Texture* = ref Asset
  TextureRegion* = ref Asset