import
  events,
  hashes,
  os,
  tables

import
  ../assets/asset,
  ../assets/asset_types,
  ../config,
  ../globals,
  ../graphics/two_d/texture,
  ../graphics/two_d/texture_atlas,
  ../graphics/two_d/texture_region,
  ../logger,
  module,
  ../sound/sound

export
  asset,
  asset_types

proc init*(this: AssetManager, config: Config): bool =
  this.assets = initTable[Hash, ref Asset]()
  this.assetSearchPath = getAppDir() & DirSep & config.assetRoot & DirSep
  this.internalSearchPath = getAppDir() & DirSep & engineAssetRoot & DirSep
  return true

proc dispose(this: AssetManager, id: Hash) =
  case this.assets[id].assetType
    of AssetType.Texture:
      if not this.assets[id].isNil:
        texture.unload(this.assets[id])
      this.assets.del(id)
    else:
      logWarn "Unable to unload asset with unknown type."

proc shutdown*(this: AssetManager) =
  for id, _ in this.assets:
    this.dispose(id)

proc get*[T](this: AssetManager, filename: string): T =
  let id = hash(filename)
  if not this.assets.contains(id):
    logWarn "Asset with filename : " & filename & " not loaded."
    return

  return cast[T](this.assets[id])

proc get*[T](this: AssetManager, id: Hash): T =
  if not this.assets.contains(id):
    logWarn "Asset with id : " & $id & " not loaded."
    return

  return cast[T](this.assets[id])

proc unload*(this: AssetManager, id: Hash) =
  if not this.assets.contains(id):
    logWarn "Asset with filename : " & $id & " not loaded."
    return

  this.dispose(id)

proc unload*(this: AssetManager, filename: string, internal: bool = false) =
  var filepath : string
  if not internal:
    filepath = this.assetSearchPath & filepath
  else:
    filepath = this.internalSearchPath & filename

  let id = hash(filepath)
  if not this.assets.contains(id):
    logWarn "Asset with filepath : " & filepath & " not loaded."
    return

  this.dispose(id)

proc load*(this: AssetManager, filename: string, assetType: AssetType, internal: bool = false) : Hash =
  var filepath : string
  if not internal:
    filepath = this.assetSearchPath & filename
  else:
    filepath = this.internalSearchPath & filename

  if not fileExists(filepath):
    logWarn "File with filepath : " & filepath & " does not exist."
    return

  let newAssetId = hash(filepath)
  if this.assets.contains(newAssetId):
    logWarn "Asset with filepath : " & filepath & " already loaded."
    return

  case assetType
    of AssetType.Sound:
      var sound = sound.load(filepath)
      this.assets.add(newAssetId, sound)
      return newAssetId
    of AssetType.Texture:
      var texture = texture.load(filepath)
      this.assets.add(newAssetId, texture)
      return newAssetId
    of AssetType.TextureRegion:
      logWarn "Cannot load a texture region... Try loading a texture and creating a texture region."
      return
    of AssetType.TextureAtlas:
      var atlasInfo = texture_atlas.load(filepath)
      
      let atlasDir = splitFile(filename).dir
      let texturePath = atlasDir & DirSep &  atlasInfo.atlas.textureFilename
      
      var textureId = hash(texturePath)
      var atlasTexture = get[Texture](this, textureId)
      if atlasTexture.isNil:
        textureId = this.load(texturePath, AssetType.Texture, false)
        atlasTexture = get[Texture](this, textureId)


        for regionInfo in atlasInfo.regions:
          atlasInfo.atlas.regions.add(texture_region.fromTexture(
            atlasTexture,
            regionInfo.name,
            regionInfo.w,
            regionInfo.h,
            regionInfo.u,
            regionInfo.u2,
            regionInfo.v,
            regionInfo.v2
          ))
        
        this.assets.add(newAssetId, atlasInfo.atlas)
        return newAssetId
      else:
        logWarn "Texture with " & texturePath & " does not exist."
