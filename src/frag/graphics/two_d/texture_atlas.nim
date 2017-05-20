import
  strutils

when defined(js):
  discard

else:
  import
    os,
    parsecfg,
    streams

import
  ../../assets/asset_types,
  ../../assets/asset,
  ../../logger,
  texture,
  texture_region

export TextureAtlas

type
  AtlasInfo* = ref object
    atlas*: TextureAtlas
    

proc getRegion*(atlas: TextureAtlas, regionName: string): TextureRegion =
  for region in atlas.regions:
    if(region.name == regionName):
      return region

proc loadTextureAtlas(shortPath: string, filename: string): AtlasInfo =
  var atlas = TextureAtlas(assetType: AssetType.TextureAtlas)
  atlas.atlasShortPath = shortPath
  atlas.filename = filename
  atlas.regions = @[]
  atlas.regionInfos = @[]
  
  when defined(js):
    discard
  
  else:
    var f = newFileStream(filename, fmRead)
    if f != nil:
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
          atlas.regionInfos.add(region)
        of cfgKeyValuePair:
          if e.key == "name":
            if atlas.textureFilename.isNil:
              atlas.textureFilename = e.value
        of cfgError:
          logError("Cfg parsing error : " & e.msg)
        else:
          discard
      close(p)
      atlas.textureFilepath = splitFile(filename).dir & DirSep & atlas.textureFilename
    else:
      logWarn "Cannot open texture atlas: " & filename
    
    return AtlasInfo(
      atlas: atlas, 
    )

proc load*(shortPath: string, filename: string): auto =
  when defined(js):
    discard
  else:
    let ext = splitFile(filename).ext
    if not(ext == ".atlas"):
      logWarn "Extension : " & ext & " not recognized."
      return
    loadTextureAtlas(shortPath, filename)
    