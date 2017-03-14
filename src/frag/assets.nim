import
  events,
  hashes,
  logging,
  os,
  tables

import
  assets/asset,
  assets/vector_font_loader,
  globals,
  graphics/text/vector_font,
  graphics/two_d/texture

type
  AssetManager* = ref object
    assetSearchPath: string
    internalSearchPath: string
    assets: Table[Hash, ref Asset]
    vectorFontLoader: VectorFontLoader
    vectorFontSupport: bool

proc get*(assetManager: AssetManager, id: Hash): ref Asset =
  if not assetManager.assets.contains(id):
    warn "Asset with filename : " & $id & " not loaded."
    return

  return assetManager.assets[id]

proc dispose(assetManager: AssetManager, id: Hash) =
  case assetManager.assets[id].assetType
    of AssetType.Texture:
      texture.unload(assetManager.assets[id])
      assetManager.assets.del(id)
    of AssetType.VectorFont:
      vectorFont.unload(assetManager.assets[id])
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
    of AssetType.VectorFont:
      if not assetManager.vectorFontSupport:
        warn "TrueType font loading is not enabled."
      let fontFace = assetManager.vectorFontLoader.loadFontFace(filepath)
      var font = vectorFont.load(fontFace)
      assetManager.assets.add(id, font)
  return id

proc init*(assetManager: AssetManager, assetRoot: string) =
  assetManager.assets = initTable[Hash, ref Asset]()
  assetManager.assetSearchPath = getAppDir() & DirSep & assetRoot & DirSep
  assetManager.internalSearchPath = getAppDir() & DirSep & engineAssetRoot & DirSep

  assetManager.vectorFontSupport = true
  assetManager.vectorFontLoader = VectorFontLoader()
  if not assetManager.vectorFontLoader.init():
    error "Error initializing TrueType font loader. TrueType font support disabled."
    assetManager.vectorFontSupport = false

proc shutdown*(assetManager: AssetManager) =
  for id, _ in assetManager.assets:
    assetManager.dispose(id)

  assetManager.vectorFontLoader.shutdown()
