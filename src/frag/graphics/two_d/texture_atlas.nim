import
  os,
  parsecfg,
  streams,
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
  var atlas = TextureAtlas(assetType: AssetType.TextureAtlas)
  atlas.filename = filename
  atlas.regions = @[]

  var regions : seq[RegionInfo] = @[]
  var f = newFileStream(filename, fmRead)
  if f != nil:
    var dict = loadConfig("config.ini")
    var p: CfgParser
    open(p, f, filename)
    while true:
      var e = next(p)
      case e.kind
      of cfgEof:
        break
      of cfgSectionStart:   ## a ``[section]`` has been parsed
        let region = RegionInfo(
          name: e.section,
          w: parseInt(p.next.value),
          h: parseInt(p.next.value),
          u: parseFloat(p.next.value),
          v: parseFloat(p.next.value),
          u2: parseFloat(p.next.value),
          v2: parseFloat(p.next.value)
        )
        regions.add(region)
      of cfgKeyValuePair:
        if e.key == "name":
          if atlas.textureFilename.isNil:
            atlas.textureFilename = e.value
      of cfgError:
        logError("Cfg parsing error : " & e.msg)
      else:
        discard
    close(p)
  else:
    logWarn "Cannot open texture atlas: " & filename
  
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
    