import
  tables

import
  bgfxdotnim as bgfx,
  sdl2 as sdl,
  sound.sound as snd

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
    filename*: string
    case assetType*: AssetType
    of AssetType.Sound:
      snd*: snd.Sound
    of AssetType.Texture:
      handle*: bgfx_texture_handle_t
      data*: sdl.SurfacePtr
    of AssetType.TextureRegion:
      texture*: ref Asset
      u*, v*, u2*, v2*: float
      regionWidth*, regionHeight*: int
      name*: string
    of AssetType.TextureAtlas:
      regions*: seq[TextureRegion]
      numRegions*: int
      textureFilename*: string

  Sound* = ref Asset
  Texture* = ref Asset
  TextureRegion* = ref Asset
  TextureAtlas* = ref Asset