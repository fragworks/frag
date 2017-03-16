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

proc get*[T](assetManager: AssetManager, id: Hash): T =
  if not assetManager.assets.contains(id):
    warn "Asset with filename : " & $id & " not loaded."
    return

  return cast[T](assetManager.assets[id])

proc dispose(assetManager: AssetManager, id: Hash) =
  case assetManager.assets[id].assetType
    of AssetType.Texture:
      texture.unload(assetManager.assets[id])
      assetManager.assets.del(id)
    else:
      warn "Unable to unload asset with unknown type."

proc unload*(assetManager: AssetManager, id: Hash) =
  if not assetManager.assets.contains(id):
    warn "Asset with filename : " & $id & " not loaded."
    return

  assetManager.dispose(id)

proc unload*(assetManager: AssetManager, filename: string, internal: bool = false) =
  var filepath : string
  if not internal:
    filepath = assetManager.assetSearchPath & filepath
  else:
    filepath = assetManager.internalSearchPath & filename

  let id = hash(filepath)
  if not assetManager.assets.contains(id):
    warn "Asset with filepath : " & filepath & " not loaded."
    return

  assetManager.dispose(id)

proc load*(assetManager: AssetManager, filename: string, assetType: AssetType, internal: bool = false) : Hash =
  var filepath : string
  if not internal:
    filepath = assetManager.assetSearchPath & filename
  else:
    filepath = assetManager.internalSearchPath & filename

  if not fileExists(filepath):
    warn "File with filepath : " & filepath & " does not exist."
    return

  let id = hash(filepath)
  if assetManager.assets.contains(id):
    warn "Asset with filepath : " & filepath & " already loaded."
    return

  case assetType
    of AssetType.Texture:
      var texture = texture.load(filepath)
      assetManager.assets.add(id, texture)
    of AssetType.TextureRegion:
      warn "Cannot load a texture region... Try loading a texture and creating a texture region."
  return id

proc init*(assetManager: AssetManager, assetRoot: string) =
  assetManager.assets = initTable[Hash, ref Asset]()
  assetManager.assetSearchPath = getAppDir() & DirSep & assetRoot & DirSep
  assetManager.internalSearchPath = getAppDir() & DirSep & engineAssetRoot & DirSep

proc shutdown*(assetManager: AssetManager) =
  for id, _ in assetManager.assets:
    assetManager.dispose(id)
