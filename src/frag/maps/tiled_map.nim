import
  tables

when not defined(js):
  import
    os, streams, json
  
  import
    ../logger,
    ../assets/asset,
    ../assets/asset_types,
    ../graphics/camera,
    ../graphics/two_d/spritebatch,
    ../graphics/two_d/texture_region,
    ../graphics/two_d/vertex,
    ../math/rectangle

var vertices: seq[PosUVColorVertex] = @[]

proc getViewBounds*(tiledMap: TiledMap, spriteBatch: SpriteBatch, camera: Camera): Rectangle =
  spriteBatch.setProjectionMatrix(camera.combined)
  let width = camera.viewportWidth * camera.zoom
  let height = camera.viewportHeight * camera.zoom
  let w = width * abs(camera.up[1]) + height * abs(camera.up[0])
  let h = height * abs(camera.up[1]) + width * abs(camera.up[0])
  result = Rectangle(
    x: camera.position[0] - w / 2,
    y: camera.position[1] - h / 2,
    width: w,
    height: h
  )

proc getCell*(tiledMapLayer: TiledMapLayer, x, y: int): TiledMapCell =
  if x < 0 or x >= tiledMapLayer.width:
    return nil
  elif y < 0 or y >= tiledMapLayer.height:
    return nil
  
  return tiledMapLayer.cells[tiledMapLayer.width * y + x]

proc render*(tiledMapLayer: TiledMapLayer, tiledMap: TiledMap, spriteBatch: SpriteBatch, viewBounds: Rectangle, color: uint32, unitScale: float = 1.0) =
  let layerWidth = tiledMapLayer.width
  let layerHeight = tiledMapLayer.height

  let layerTileWidth = tiledMapLayer.tileWidth.float * unitScale
  let layerTileHeight = tiledMapLayer.tileHeight.float * unitScale
  
  var y = layerHeight.float * layerTileHeight

  for row in 0..<layerHeight:
    var x = 0.0
    for col in 0..<layerWidth:
      let cell = tiledMapLayer.getCell(col, row)
      if cell.isNil:
        x += layerTileWidth
        continue
      
      let tile = cell.tile
      if not tile.textureRegion.isNil:
        let region = tile.textureRegion

        let x1 = x.float * unitScale
        let y1 = y.float * unitScale
        let x2 = x1 + region.regionWidth.float * unitScale
        let y2 = y1 + region.regionHeight.float * unitScale

        let u1 = region.u
        let v1 = region.v2
        let u2 = region.u2
        let v2 = region.v

        vertices.add(
          PosUVColorVertex(
            x: x1,
            y: y1,
            z: 0,
            u: u1,
            v: v1,
            abgr: color
          )
        )

        vertices.add(
          PosUVColorVertex(
            x: x1,
            y: y2,
            z: 0,
            u: u1,
            v: v2,
            abgr: color
          )
        )

        vertices.add(
          PosUVColorVertex(
            x: x2,
            y: y2,
            z: 0,
            u: u2,
            v: v2,
            abgr: color
          )
        )

        vertices.add(
          PosUVColorVertex(
            x: x2,
            y: y1,
            z: 0,
            u: u2,
            v: v1,
            abgr: color
          )
        )


        spriteBatch.draw(region.texture, vertices)
        vertices.setLen(0)
      x += layerTileWidth
    y -= layerTileHeight

proc render*(tiledMap: TiledMap, spriteBatch: SpriteBatch, camera: Camera, color: uint32 = 0xffffffff'u32) =
  let viewBounds = getViewBounds(tiledMap, spriteBatch, camera)
  
  for layer in tiledMap.layers:
    layer.render(tiledMap, spriteBatch, viewBounds, color)

proc findTile*(tiledMap: TiledMap, tileId: int): Tile =
  for tileset in tiledMap.tilesets:
    if tileset.tiles.contains(tileId):
      return tileset.tiles[tileId]

proc assignTiles*(tiledMap: TiledMap) =
  for i in 0..<tiledMap.layers.len:
    var layer = tiledMap.layers[i]
    for c in 0..<layer.cells.len:
      var cell = layer.cells[c]
      cell.tile = tiledMap.findTile(cell.tileId)

proc initTilesets*(tiledMap: TiledMap) =
  for i in 0..<tiledMap.tilesets.len:
    var tileset = tiledMap.tilesets[i]
    let stopWidth = tileset.texture.width - tileset.tileWidth
    let stopHeight = tileset.texture.height - tileset.tileHeight

    var id = tileset.firstGid
    var x, y = tileset.margin

    while y <= stopHeight:
      while x <= stopWidth:
        let tileRegion = texture_region.fromTexture(tileset.texture, x, y, tileset.tileWidth, tileset.tileHeight)

        tileset.tiles.add(
          id,
          Tile(
            textureRegion: tileRegion
          )
        )
        inc(id)

        inc(x, tileset.tileWidth + tileset.spacing)
      x = tileset.margin
      inc(y, tileset.tileHeight + tileset.spacing)
    tiledMap.tilesets[i] = tileset

proc init*(tiledMap: TiledMap) =
  initTilesets(tiledMap)
  assignTiles(tiledMap)
  tiledMap.initialized = true

proc load*(filename: string): TiledMap =
  let s = newFileStream(filename, fmRead)

  if s.isNil:
    logError "Unable to open file with filename: " & filename
    return
  
  let parsed = parseJson(s, filename)
  if parsed.isNil:
    logError "Unable to parse file with filename: " & filename
    return


  result = TiledMap(
    mapInfo: to(parsed, MapInfo),
    filename: filename,
    tilesets: @[],
    layers: @[],
    assetType: AssetType.TiledMap
  )