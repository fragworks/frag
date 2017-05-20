#   FRAG - Framework for Rather Awesome Games
#   (c) Copyright 2017 Fragworks
#
#   See the file "LICENSE", included in this
#   distribution, for details about the copyright.

## ===============
## Module frag.assets.asset
## ===============
##
## Contains variant type ``Asset`` which defines fields for
## the various asset types FRAG supports. See ``frag.assets.asset.AssetType`` for
## an enumeration of asset types supported by FRAG.

import
  tables,
  sound.sound as snd

when defined(js):
  import 
    dom,
    jsffi,
    webgl

when not defined(js):
  import
    bgfxdotnim as bgfx,
    sdl2 as sdl

import
  asset_types

type
  Asset* = object
    ## Variant type for all FRAG assets
    when defined(js):
      filename*: cstring
    else:
      filename*: string
    case assetType*: AssetType
    of AssetType.Sound:
      snd*: snd.Sound
    of AssetType.Texture:
      when not defined(js):
        handle*: bgfx_texture_handle_t
      when defined(android):
        data*: sdl.SurfacePtr
      elif defined(js):
        data*: ImageElement
        handle*: JsObject
      else:
        data*: seq[uint8]
      width*, height*, channels*: int
    of AssetType.TextureRegion:
      texture*: ref Asset
      u*, v*, u2*, v2*: float
      regionWidth*, regionHeight*: int
      name*: string
    of AssetType.TextureAtlas:
      regions*: seq[TextureRegion]
      numRegions*: int
      textureFilename*: string
      textureFilepath*: string
      atlasShortPath*: string
      regionInfos*: seq[RegionInfo]

  RegionInfo* = object
    name*: string
    w*, h*: int
    u*, u2*, v*, v2*: float

  BoxedAsset* = object
    value: ref Asset

  Sound* = ref Asset
  Texture* = ref Asset
  TextureRegion* = ref Asset
  TextureAtlas* = ref Asset