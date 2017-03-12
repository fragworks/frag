import 
  events,
  hashes,
  logging,
  os,
  tables

import 
  assets/asset,
  assets/ttf_loader,
  graphics/text/ttf,
  graphics/two_d/texture

type
  AssetManager* = ref object
    assetSearchPath: string
    assets: Table[Hash, ref Asset]
    ttfLoader: TTFLoader
    ttfSupport: bool

proc dispose(assetManager: AssetManager, id: Hash) =
  case assetManager.assets[id].assetType
    of AssetType.TEXTURE:
      texture.unload(assetManager.assets[id])
      assetManager.assets.del(id)
    else:
      warn "Unable to unload asset with unknown type."

proc unload*(assetManager: AssetManager, id: Hash) =
  if not assetManager.assets.contains(id):
    warn "Asset with filename : " & $id & " not loaded."
    return
    
  assetManager.dispose(id)

proc unload*(assetManager: AssetManager, filename: string) =
  let filepath = assetManager.assetSearchPath & filename
  let id = hash(filepath)
  if not assetManager.assets.contains(id):
    warn "Asset with filepath : " & filepath & " not loaded."
    return
    
  assetManager.dispose(id)
  
proc load*(assetManager: AssetManager, filename: string, assetType: AssetType) : Hash =
  let filepath = assetManager.assetSearchPath & filename
  if not fileExists(filepath):
    warn "File with filepath : " & filepath & " does not exist."
    return
  
  let id = hash(filepath)
  if assetManager.assets.contains(id):
    warn "Asset with filepath : " & filepath & " already loaded."
    return
    
  case assetType
    of AssetType.TEXTURE:
      var texture = texture.load(filepath)
      assetManager.assets.add(id, texture)
    of AssetType.TTF:
      if not assetManager.ttfSupport:
        warn "TrueType font loading is not enabled."
      let fontFace = assetManager.ttfLoader.loadFontFace(filepath)
      var ttf = ttf.load(fontFace)
  return id

proc init*(assetManager: AssetManager, assetRoot: string) =
  assetManager.assets = initTable[Hash, ref Asset]()
  assetManager.assetSearchPath = getAppDir() & DirSep & assetRoot & DirSep
  
  assetManager.ttfSupport = true
  assetManager.ttfLoader = TTFLoader()
  if not assetManager.ttfLoader.init():
    error "Error initializing TrueType font loader. TrueType font support disabled."
    assetManager.ttfSupport = false

proc shutdown*(assetManager: AssetManager) =
  for id, _ in assetManager.assets:
    assetManager.dispose(id)