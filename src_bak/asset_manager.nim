import hashes, tables

import log

type 
  Asset* {.pure, inheritable.} = ref object of RootObj
    name: string

  AssetManager = object
    assets*: Table[Hash, Asset]
    assetLoaders*: seq[AssetLoader]

  LoadFunc* = proc(filename: string) : Asset
  UnloadFunc* = proc(filename: string)

  AssetLoader* = object
    load*: LoadFunc
    unload*: UnloadFunc
    extension*: string

var assetManager* : AssetManager = AssetManager(
    assets: initTable[Hash, Asset](),
    assetLoaders: @[]
  )

proc addAssetLoader*(assetLoader: AssetLoader) =
  assetManager.assetLoaders.add(assetLoader)

proc contains*(filename: string) : bool =
  if not contains(assetManager.assets, hash(filename)):
    return false
  return true
    
proc get*(filename: string) : Asset =
  return assetManager.assets[hash(filename)]

proc load*(filename, extension: string) =
  for assetLoader in assetManager.assetLoaders:
    if extension == assetLoader.extension:
      let asset = assetLoader.load(filename)
      add(assetManager.assets, hash(filename), asset)
      return
  logWarn("Asset loader not registered for file extension : " & extension)

proc unload*(filename, extension: string) =
  for assetLoader in assetManager.assetLoaders:
    if extension == assetLoader.extension:
      assetLoader.unload(filename)
      del(assetManager.assets, hash(filename))
      return
  logWarn("Asset loader not registered for file extension : " & extension)