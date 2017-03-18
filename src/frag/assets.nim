import
  events,
  hashes,
  logging,
  os,
  tables

import
  assets/asset,
  assets/asset_types,
  assets/vector_font_loader,
  globals,
  graphics/two_d/texture,
  graphics/two_d/texture_region

type
  AssetManager* = ref object
    assetSearchPath: string
    internalSearchPath: string
    assets: Table[Hash, ref Asset]

proc get*[T](this: AssetManager, id: Hash): T =
  if not this.assets.contains(id):
    warn "Asset with filename : " & $id & " not loaded."
    return

  return cast[T](this.assets[id])

proc dispose(this: AssetManager, id: Hash) =
  case this.assets[id].assetType
    of AssetType.Texture:
      texture.unload(this.assets[id])
      this.assets.del(id)
    else:
      warn "Unable to unload asset with unknown type."

proc unload*(this: AssetManager, id: Hash) =
  if not this.assets.contains(id):
    warn "Asset with filename : " & $id & " not loaded."
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
    warn "Asset with filepath : " & filepath & " not loaded."
    return

  this.dispose(id)

proc load*(this: AssetManager, filename: string, assetType: AssetType, internal: bool = false) : Hash =
  var filepath : string
  if not internal:
    filepath = this.assetSearchPath & filename
  else:
    filepath = this.internalSearchPath & filename

  if not fileExists(filepath):
    warn "File with filepath : " & filepath & " does not exist."
    return

  let id = hash(filepath)
  if this.assets.contains(id):
    warn "Asset with filepath : " & filepath & " already loaded."
    return

  case assetType
    of AssetType.Texture:
      var texture = texture.load(filepath)
      this.assets.add(id, texture)
    of AssetType.TextureRegion:
      warn "Cannot load a texture region... Try loading a texture and creating a texture region."
  return id

proc init*(this: AssetManager, assetRoot: string) =
  this.assets = initTable[Hash, ref Asset]()
  this.assetSearchPath = getAppDir() & DirSep & assetRoot & DirSep
  this.internalSearchPath = getAppDir() & DirSep & engineAssetRoot & DirSep

proc shutdown*(this: AssetManager) =
  for id, _ in this.assets:
    this.dispose(id)
