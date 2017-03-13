import
  freetype

import
  ../../assets/asset

type
  TTF* = ref Asset

proc load*(fontFace: Face): TTF =
  result = TTF(assetType: AssetType.TTF)
  result.fontFace = fontFace

proc unload*(ttf: TTF) =
  discard freetype.doneFace(ttf.fontFace)