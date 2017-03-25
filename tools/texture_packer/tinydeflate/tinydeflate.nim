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
      "p1_walk01"
      , "p1_walk02"
      , "p1_walk03"
      , "p1_walk04"
      , "p1_walk05"
      , "p1_walk06"
      , "p1_walk07"
      , "p1_walk08"
      , "p1_walk09"
      , "p1_walk10"
      , "p1_walk11"
    ]
  )
  var img = [
    tdLoadPNG("p1_walk01.png")
    , tdLoadPNG("p1_walk02.png")
    , tdLoadPNG("p1_walk03.png")
    , tdLoadPNG("p1_walk04.png")
    , tdLoadPNG("p1_walk05.png")
    , tdLoadPNG("p1_walk06.png")
    , tdLoadPNG("p1_walk07.png")
    , tdLoadPNG("p1_walk08.png")
    , tdLoadPNG("p1_walk09.png")
    , tdLoadPNG("p1_walk10.png")
    , tdLoadPNG("p1_walk11.png")
  ]
  echo repr img
  echo tdMakeAtlas("spritesheet.png", "spritesheet.atlas", 512, 512, addr img[0], 11, names)
  deallocCStringArray(names)