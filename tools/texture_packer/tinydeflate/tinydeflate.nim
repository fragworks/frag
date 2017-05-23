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
      "tile01"
      , "tile02"
      , "tile03"
      , "tile04"
      , "tile05"
      , "tile06"
      , "tile07"
      , "tile08"
      , "tile09"
      , "tile10"
      , "tile11"
      , "tile12"
      , "tile13"
      , "tile14"
      , "tile15"
      , "tile16"
      , "tile17"
      , "tile18"
      , "tile19"
      , "tile20"
      , "tile02"
      , "tile03"
      , "tile04"
      , "tile05"
      , "tile06"
      , "tile07"
      , "tile08"
      , "tile09"
      , "tile10"
      , "tile11"
      , "tile12"
      , "tile13"
      , "tile14"
      , "tile15"
      , "tile16"
      , "tile17"
      , "tile18"
      , "tile19"
      , "tile20"
      , "tile21"
      , "tile22"
      , "tile23"
      , "tile24"
      , "tile06"
      , "tile07"
      , "tile08"
      , "tile09"
      , "tile10"
      , "tile11"
      , "tile12"
      , "tile13"
      , "tile14"
      , "tile15"
      , "tile16"
      , "tile17"
      , "tile18"
      , "tile19"
      , "tile20"
      , "tile02"
      , "tile03"
      , "tile04"
      , "tile05"
      , "tile06"
      , "tile07"
      , "tile08"
      , "tile09"
      , "tile10"
      , "tile11"
      , "tile12"
      , "tile13"
      , "tile14"
      , "tile15"
      , "tile16"
      , "tile17"
      , "tile18"
      , "tile19"
      , "tile20"
      , "tile02"
      , "tile03"
      , "tile04"
      , "tile05"
      , "tile06"
      , "tile07"
      , "tile08"
      , "tile09"
      , "tile10"
      , "tile11"
      , "tile12"
      , "tile13"
      , "tile14"
      , "tile15"
      , "tile16"
      , "tile17"
      , "tile18"
      , "tile19"
      , "tile20"
    ]
  )
  var img = [
    tdLoadPNG("tile_01.png")
    , tdLoadPNG("tile_02.png")
    , tdLoadPNG("tile_03.png")
    , tdLoadPNG("tile_04.png")
    , tdLoadPNG("tile_05.png")
    , tdLoadPNG("tile_06.png")
    , tdLoadPNG("tile_07.png")
    , tdLoadPNG("tile_08.png")
    , tdLoadPNG("tile_09.png")
    , tdLoadPNG("tile_10.png")
    , tdLoadPNG("tile_11.png")
    , tdLoadPNG("tile_12.png")
    , tdLoadPNG("tile_13.png")
    , tdLoadPNG("tile_14.png")
    , tdLoadPNG("tile_15.png")
    , tdLoadPNG("tile_16.png")
    , tdLoadPNG("tile_17.png")
    , tdLoadPNG("tile_18.png")
    , tdLoadPNG("tile_19.png")
    , tdLoadPNG("tile_20.png")
    , tdLoadPNG("tile_21.png")
    , tdLoadPNG("tile_22.png")
    , tdLoadPNG("tile_23.png")
    , tdLoadPNG("tile_24.png")
    , tdLoadPNG("tile_25.png")
    , tdLoadPNG("tile_26.png")
    , tdLoadPNG("tile_27.png")
    , tdLoadPNG("tile_28.png")
    , tdLoadPNG("tile_29.png")
    , tdLoadPNG("tile_30.png")
    , tdLoadPNG("tile_31.png")
    , tdLoadPNG("tile_32.png")
    , tdLoadPNG("tile_33.png")
    , tdLoadPNG("tile_34.png")
    , tdLoadPNG("tile_35.png")
    , tdLoadPNG("tile_36.png")
    , tdLoadPNG("tile_37.png")
    , tdLoadPNG("tile_38.png")
    , tdLoadPNG("tile_39.png")
    , tdLoadPNG("tile_40.png")
    , tdLoadPNG("tile_41.png")
    , tdLoadPNG("tile_42.png")
    , tdLoadPNG("tile_43.png")
    , tdLoadPNG("tile_44.png")
    , tdLoadPNG("tile_45.png")
    , tdLoadPNG("tile_46.png")
    , tdLoadPNG("tile_47.png")
    , tdLoadPNG("tile_48.png")
    , tdLoadPNG("tile_49.png")
    , tdLoadPNG("tile_50.png")
    , tdLoadPNG("tile_51.png")
    , tdLoadPNG("tile_52.png")
    , tdLoadPNG("tile_53.png")
    , tdLoadPNG("tile_54.png")
    , tdLoadPNG("tile_55.png")
    , tdLoadPNG("tile_56.png")
    , tdLoadPNG("tile_57.png")
    , tdLoadPNG("tile_58.png")
    , tdLoadPNG("tile_59.png")
    , tdLoadPNG("tile_60.png")
    , tdLoadPNG("tile_61.png")
    , tdLoadPNG("tile_62.png")
    , tdLoadPNG("tile_63.png")
    , tdLoadPNG("tile_64.png")
    , tdLoadPNG("tile_65.png")
    , tdLoadPNG("tile_66.png")
    , tdLoadPNG("tile_67.png")
    , tdLoadPNG("tile_68.png")
    , tdLoadPNG("tile_69.png")
    , tdLoadPNG("tile_70.png")
    , tdLoadPNG("tile_71.png")
    , tdLoadPNG("tile_72.png")
    , tdLoadPNG("tile_73.png")
    , tdLoadPNG("tile_74.png")
    , tdLoadPNG("tile_75.png")
    , tdLoadPNG("tile_76.png")
    , tdLoadPNG("tile_77.png")
    , tdLoadPNG("tile_78.png")
    , tdLoadPNG("tile_79.png")
    , tdLoadPNG("tile_80.png")
    , tdLoadPNG("tile_81.png")
    , tdLoadPNG("tile_82.png")
    , tdLoadPNG("tile_83.png")
    , tdLoadPNG("tile_84.png")
    , tdLoadPNG("tile_85.png")
    , tdLoadPNG("tile_86.png")
    , tdLoadPNG("tile_87.png")
    , tdLoadPNG("tile_88.png")
    , tdLoadPNG("tile_89.png")
    , tdLoadPNG("tile_90.png")
    , tdLoadPNG("tile_91.png")
    , tdLoadPNG("tile_92.png")
    , tdLoadPNG("tile_93.png")
    , tdLoadPNG("tile_94.png")
    , tdLoadPNG("tile_95.png")
    , tdLoadPNG("tile_96.png")
  ]
  echo repr img
  echo tdMakeAtlas("tilesheet.png", "tilesheet.atlas", 2048, 2048, addr img[0], 96, nil)
  deallocCStringArray(names)