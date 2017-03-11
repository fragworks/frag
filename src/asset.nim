import hashes, os, tables

import asset_manager, log

export Asset, LoadFunc, UnloadFunc

proc assetInit*() : bool =
  return true

proc registerAssetLoader*(loadFunc: LoadFunc, unloadFunc: UnloadFunc, extension: string) =
  var loader = AssetLoader()
  loader.load = loadFunc
  loader.unload = unloadFunc
  loader.extension = extension
  assetManager.addAssetLoader(loader)

proc get*(filename: string) : Asset =
  if filename.isNil:
    logError "Cannot get asset with nil filename!"
    return
  
  if not contains(filename):
    logWarn "Asset with filename : " & filename & " not loaded!"
    return
  
  return assetManager.get(filename)


proc load*(filename: string) =
  if filename.isNil:
    logError "Cannot load asset with nil filename!"
    return
  
  var (_, _, extension) = splitFile(filename)

  assetManager.load(filename, extension)

proc unload*(filename: string) =
  if filename.isNil:
    logError "Cannot unload file with nil filename!"
    return
  
  var (_, _, extension) = splitFile(filename)

  assetManager.unload(filename, extension)