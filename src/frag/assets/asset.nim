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
  tables

import
  bgfxdotnim as bgfx,
  sdl2 as sdl,
  sound.sound as snd

import
  asset_types

type
  Asset* = object
    ## Variant type for all FRAG assets
    filename*: string
    case assetType*: AssetType
    of AssetType.Sound:
      snd*: snd.Sound
      when defined(js):
        media*: JsObject
    of AssetType.Texture:
      handle*: bgfx_texture_handle_t
      when defined(android):
        data*: sdl.SurfacePtr
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
    of AssetType.TiledMap:
      mapInfo*: MapInfo
      layers*: seq[TiledMapLayer]
      tilesets*: seq[Tileset]
      initialized*: bool
  
  Tileset* = object
    tiles*: Table[int, Tile]
    textureFilepath*: string
    texture*: Texture
    name*: string
    firstGid*: int
    margin*: int
    spacing*: int
    tileWidth*: int
    tileHeight*: int

  Tile* = object
    textureRegion*: TextureRegion

  TiledMapLayer* = object
    width*, height*: int
    tileWidth*, tileHeight*: int
    cells*: seq[TiledMapCell]

  TiledMapCell* = ref object
    tileId*: int
    tile*: Tile

  MapInfo* = object
    version*: float
    orientation*: string
    renderorder*: string
    tilewidth*: int
    tileheight*: int
    nextobjectid*: int
    tilesets*: seq[TilesetInfo]
    layers*: seq[LayerInfo]

  TilesetInfo* = object
    columns*: int
    firstgid*: int
    image*: string
    imageheight*: int
    imagewidth*: int
    margin*: int
    name*: string
    spacing*: int
    tilecount*: int
    tilewidth*: int
    tileheight*: int

  LayerInfo* = object
    data*: seq[int]
    width*, height*: int
    name*: string
    opacity*: float
    `type`*: string
    visible*: bool
    x*, y*: int

  RegionInfo* = object
    name*: string
    w*, h*: int
    u*, u2*, v*, v2*: float

  Sound* = ref Asset
  Texture* = ref Asset
  TextureRegion* = ref Asset
  TextureAtlas* = ref Asset
  TiledMap* = ref Asset