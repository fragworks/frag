import
  deques,
  events,
  hashes,
  strutils,
  tables

when defined(js):
  import
    dom,
    jsconsole,
    jsffi,
    ../js/res

when not defined(js):
  import
    os,
    threadpool,
    times

template benchmark(benchmarkName: string, code: stmt) =
  let t0 = epochTime()
  code
  let elapsed = epochTime() - t0
  let elapsedStr = elapsed.formatFloat(format = ffDecimal, precision = 3)
  echo "CPU Time [", benchmarkName, "] ", elapsedStr, "s"

import
  ../assets/asset,
  ../assets/asset_types,
  ../config,
  ../globals,
  ../graphics/two_d/texture,
  ../graphics/two_d/texture_atlas,
  ../graphics/two_d/texture_region,
  ../logger,
  ../maps/tiled_map,
  module,
  ../sound/sound

export
  asset,
  asset_types

const maxWorkers = 4

proc init*(self: AssetManager, config: Config): bool =
  let appAssetRoot = if config.assetRoot.isNil: globals.defaultAppAssetRoot
    else: config.assetRoot
  self.assets = initTable[Hash, ref Asset]()
  when defined(js):
    self.loader = newLoader()
    self.assetSearchPath = appAssetRoot & "/"
    return true
  else:
    self.assetLoadsInProgress = initTable[Hash, FlowVarBase]()
    self.assetLoadRequests = initDeque[AssetLoadRequest]()
    self.assetSearchPath = getAppDir() & $DirSep & appAssetRoot & $DirSep
    self.internalSearchPath = getAppDir() & $DirSep & globals.engineAssetRoot & $DirSep
    return true

proc dispose(self: AssetManager, id: Hash) =
  when not defined(js):
    case self.assets[id].assetType
      of AssetType.Texture:
        texture.unload(self.assets[id])
        self.assets.del(id)
      else:
        logWarn "Unable to unload asset with unknown type."

proc shutdown*(self: AssetManager) =
  when not defined(js):
    for id, _ in self.assets:
      self.dispose(id)

proc get*[T](self: AssetManager, filename: string): T =
  let id = hash(filename)
  if not self.assets.contains(id):
    logWarn "Asset with filename : " & filename & " not loaded."
    return

  return cast[T](self.assets[id])

proc get*[T](self: AssetManager, id: Hash): T =
  if not self.assets.contains(id):
    logWarn "Asset with id : " & $id & " not loaded."
    return

  return cast[T](self.assets[id])

proc unload*(self: AssetManager, id: Hash) =
  when not defined(js):
    if not self.assets.contains(id):
      logWarn "Asset with filename : " & $id & " not loaded."
      return

  self.dispose(id)

proc unload*(self: AssetManager, filename: string, internal: bool = false) =
  when not defined(js):
    var filepath : string
    if not internal:
      filepath = self.assetSearchPath & filepath
    else:
      filepath = self.internalSearchPath & filename

    let id = hash(filepath)
    if not self.assets.contains(id):
      logWarn "Asset with filepath : " & filepath & " not loaded."
      return

    self.dispose(id)

proc checkLoadingFinished(self: AssetManager): bool =
  when defined(js):
    discard
  else:
    if self.assetLoadsInProgress.len > 0 or self.assetLoadRequests.len > 0:
      return false

    return true

proc getProgress*(self: AssetManager): float =
  when defined(js):
    discard
  else:
    if self.assetLoadRequests.len == 0:
      return 1.0
    
    var fractionalLoaded = self.loaded.float #0
    if self.peakLoadsInProgress > 0u:
      fractionalLoaded += ((self.peakLoadsInProgress - self.assetLoadsInProgress.len.uint).float / self.peakLoadsInProgress.float)
    return min(1.0, fractionalLoaded / self.assetLoadRequests.len.float)

proc load*(self: AssetManager, filename: string, assetType: AssetType, internal: bool = false, ignoreSearchPath: bool = false): Hash =
  when defined(js):
    var filepath = self.assetSearchPath & filename
    result = hash(filepath)

    discard self.loader.add($result, filepath)
  else:
    var filepath : string
    
    if ignoreSearchPath:
      filepath = filename
    else:
      if not internal:
        filepath = self.assetSearchPath & filename
      else:
        filepath = self.internalSearchPath & filename

    if not fileExists(filepath):
      logWarn "File with filepath : " & filepath & " does not exist."
      return

    let newAssetId = hash(filepath)
    if self.assets.contains(newAssetId):
      logWarn "Asset with filepath : " & filepath & " already loaded."
      return

    if self.assetLoadRequests.len == 0:
      self.loaded = 0
      self.peakLoadsInProgress = 0

    self.assetLoadRequests.addLast(
      AssetLoadRequest(
        filename: filename,
        filepath: filepath,
        assetId: newAssetId,
        assetType: assetType
      )
    )

    return newAssetId

proc atlasInfoReady(self: AssetManager, assetId: Hash, assetLoadInProgress: FlowVarBase) =
  let atlasInfo = cast[FlowVar[AtlasInfo]](assetLoadInProgress).`^`()
          
  let atlasDir = splitFile(atlasInfo.atlas.atlasShortPath).dir
  let texturePath = atlasDir & DirSep &  atlasInfo.atlas.textureFilename

  let atlasTexture = get[Texture](self, hash(texturePath))
  if atlasTexture.isNil:
    discard self.load(texturePath, AssetType.Texture)

  self.assets.add(assetId, atlasInfo.atlas)
  self.assetLoadsInProgress.del(assetId)

proc tiledMapReady(self: AssetManager, tiledMap: TiledMap) =
  let tiledMapDir = splitFile(tiledMap.filename).dir

  for tileset in tiledMap.mapInfo.tilesets:
    let tilesetTexturePath = tiledMapDir & DirSep & tileset.image
    let tilesetTexture = get[Texture](self, hash(tilesetTexturePath))

    if tilesetTexture.isNil:
      discard self.load(tilesetTexturePath, AssetType.Texture, false, true)
      
    tiledMap.tilesets.add(Tileset(
      tiles: initTable[int, Tile](),
      textureFilepath: tileset.image,
      name: tileset.name,
      firstGid: tileset.firstgid,
      margin: tileset.margin,
      spacing: tileset.spacing,
      tileWidth: tileset.tilewidth,
      tileHeight: tileset.tileheight
    ))

  var mapCells: seq[TiledMapCell] = @[]
  for layer in tiledMap.mapInfo.layers:
    mapCells.setLen(0)
    for tileId in layer.data:
      mapCells.add(TiledMapCell(
        tileId: tileId
      ))
    
    tiledMap.layers.add(TiledMapLayer(
      width: layer.width,
      height: layer.height,
      tileWidth: tiledMap.mapInfo.tilewidth,
      tileHeight: tiledMap.mapInfo.tileheight,
      cells: mapCells
    ))

proc textureReady(self: AssetManager, tex: Texture) =
  texture.init(tex)

  for assetId, asset in self.assets:
    if asset.assetType == AssetType.TextureAtlas:
      if asset.textureFilepath == tex.filename:
        for regionInfo in asset.regionInfos:
          asset.regions.add(
            texture_region.fromTexture(
              tex,
              regionInfo.name,
              regionInfo.w,
              regionInfo.h,
              regionInfo.u + 0.001f,
              regionInfo.u2 - 0.001f,
              regionInfo.v - 0.001f,
              regionInfo.v2 + 0.001f
            )
          )
    elif asset.assetType == AssetType.TiledMap:
      for i in 0..<asset.tilesets.len:
        if tex.filename.contains(asset.tilesets[i].textureFilepath):
          asset.tilesets[i].texture = tex

      if not asset.initialized:
        var allTilesetsLoaded = true
        for tileset in asset.tilesets:
          if tileset.texture.isNil:
            allTilesetsLoaded = false
        
        if allTilesetsLoaded:
          tiled_map.init(asset)
          asset.initialized = true

proc updateLoadsInProgress(self: AssetManager) =
  when defined(js):
    discard
  else:
    var asset: ref Asset
    for assetId, assetLoadInProgress in self.assetLoadsInProgress:
      if assetLoadInProgress.isReady:
        inc(self.loaded)
        if self.assetLoadsInProgress.len == 1:
          self.peakLoadsInProgress = 0
        if assetLoadInProgress of FlowVar[AtlasInfo]:
          self.atlasInfoReady(assetId, assetLoadInProgress)
        else:
          asset = cast[FlowVar[ref Asset]](assetLoadInProgress).`^`()
          
          self.assets.add(assetId, asset)
          self.assetLoadsInProgress.del(assetId)

          case asset.assetType
          of AssetType.Texture:
            let tex = cast[Texture](asset)
            self.textureReady(tex)
          of AssetType.Sound:
            discard
          of AssetType.TextureRegion:
            discard
          of AssetType.TiledMap:
            let map = cast[TiledMap](asset)
            self.tiledMapReady(map)
          else:
            discard

proc update*(self: AssetManager): bool =
  when defined(js):
    console.log(self.loader)
    console.log(self.loader.queueLength())
    if self.loader.resourceCount() > 0 and not self.loader.loading and self.loader.progress == 100 or self.loader.queueLength() == 0:
      for key, value in self.loader.resources.pairs:
        var asset: ref Asset
        let res = cast[Resource](value)
        case $res.extension
        of "png":
          asset = Texture(
            assetType: AssetType.Texture,
            filename: res.url,
            data: cast[ImageElement](res.data),
            width: cast[int](res.data.width),
            height: cast[int](res.data.height)
          )
          asset.init()
        of "ogg":
          asset = newSoundFromMediaElement(res.data)
        self.assets.add(cast[Hash](key), asset)
      self.loader.reset()
      return true
    elif not self.loader.loading and self.loader.queueLength() > 0:
      self.loader.load()
      return false
    else:
      return false
  else:
    while self.assetLoadRequests.len > 0 and self.assetLoadsInProgress.len < maxWorkers:
      let nextLoadRequest = self.assetLoadRequests.popFirst()

      case nextLoadRequest.assetType
      of AssetType.Sound:
        self.assetLoadsInProgress.add(nextLoadRequest.assetId, spawn sound.load(nextLoadRequest.filepath))
      of AssetType.Texture:
        self.assetLoadsInProgress.add(nextLoadRequest.assetId, spawn texture.load(nextLoadRequest.filepath))
      of AssetType.TextureRegion:
        logWarn "Cannot load a texture region... Try loading a texture and creating a texture region from it."
        return
      of AssetType.TextureAtlas:
        self.assetLoadsInProgress.add(nextLoadRequest.assetId, spawn texture_atlas.load(nextLoadRequest.filename, nextLoadRequest.filepath))
      of AssetType.TiledMap:
        self.assetLoadsInProgress.add(nextLoadRequest.assetId, spawn tiled_map.load(nextLoadRequest.filepath))
    
      inc(self.peakLoadsInProgress)
      
    self.updateLoadsInProgress()
    self.checkLoadingFinished()