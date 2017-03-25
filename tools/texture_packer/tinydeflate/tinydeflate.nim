{.compile: "bind.c".}

type
  TdPixel* = object
    r*: uint8
    g*: uint8
    b*: uint8
    a*: uint8
  
  TdImage* = object
    w*: cint
    h*: cint
    pix*: ptr TdPixel

proc tdLoadPNG*(fileName: cstring): TdImage {.importc: "tdLoadPNG".}

proc tdMakeAtlas*(out_path_image: cstring; out_path_atlas_txt: cstring;
                 atlasWidth: cint; atlasHeight: cint; pngs: ptr TdImage;
                 png_count: cint; names: cstringArray): cint {.importc: "tdMakeAtlas".}

when isMainModule:
  let names = allocCStringArray(
    [
      "test01.png"
      , "test02.png"
      , "test03.png"
      , "test04.png"
    ]
  )
  var img = [
    tdLoadPNG("test01.png")
    , tdLoadPNG("test02.png")
    , tdLoadPNG("test03.png")
    , tdLoadPNG("test04.png")
  ]
  echo repr img
  echo tdMakeAtlas("spritesheet.png", "spritesheet.atlas", 128, 128, addr img[0], 4, names)
  deallocCStringArray(names)