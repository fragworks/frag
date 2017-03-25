import
  nre,
  os,
  strutils

import
  ../../assets/asset_types,
  ../../assets/asset,
  ../../logger,
  texture,
  texture_region

export TextureAtlas

type
  AtlasInfo* = object
    atlas*: TextureAtlas
    regions*: seq[RegionInfo]

  RegionInfo* = object
    name*: string
    w*, h*: int
    u*, u2*, v*, v2*: float

proc getRegion*(atlas: TextureAtlas, regionName: string): TextureRegion =
  for region in atlas.regions:
    if(region.name == regionName):
      return region

proc loadTextureAtlas(filename: string): AtlasInfo =
  var 
    f: File
    atlas = TextureAtlas(assetType: AssetType.TextureAtlas)
  
  atlas.filename = filename
  atlas.regions = @[]
  var regions : seq[RegionInfo] = @[]

  if open(f, filename):
    defer: close(f)
    atlas.textureFilename = readLine(f)
    atlas.numRegions = parseInt(readLine(f))
    discard readLine(f)
    for i in 0..<atlas.numRegions:
      let regionInfo = readLine(f)
      let region = RegionInfo(
        name: regionInfo.split('"')[1].split('.')[0],
        w: parseInt(regionInfo.find(re"""w = (.+?(?=,))""").get.captures[0]),
        h: parseInt(regionInfo.find(re"""h = (.+?(?=,))""").get.captures[0]),
        u: parseFloat(regionInfo.find(re"""u = { (.+?(?=,))""").get.captures[0]),
        v: parseFloat(regionInfo.find(re""", (\d+[^ ]*)""").get.captures[0]),
        u2: parseFloat(regionInfo.find(re"""v = { (.+?(?=,))""").get.captures[0]),
        v2: parseFloat(regionInfo.find(re""", (\d+[^ ]*) } }""").get.captures[0])
      )
      regions.add(region)
  
  return AtlasInfo(
    atlas: atlas, 
    regions: regions
  )

proc load*(filename: string): auto =
  let ext = splitFile(filename).ext
  if not(ext == ".atlas"):
    logWarn "Extension : " & ext & " not recognized."
    return
  loadTextureAtlas(filename)
    