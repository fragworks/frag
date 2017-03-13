import
  logging,
  tables

import
  freetype,
  glm,
  opengl

import
  ../../assets/asset

type
  TTF* = ref Asset

  FontSize* = tuple[
    width, height: uint32
  ]

const defaultFontSize : FontSize = (width: 24u32, height: 24u32)

proc setSize*(ttf: TTF, size: FontSize) =
  discard freetype.setPixelSizes(ttf.fontFace, size.width, size.height)

proc initializeFont(ttf: TTF, fontSize: FontSize) =
  ttf.setSize(fontSize)

  var c : GLubyte = 0
  for c in c..<128u:
    if freetype.loadChar(ttf.fontFace, c, freetype.LOAD_RENDER) != 0:
      warn "Failed to load TrueType font glyph."

proc load*(fontFace: Face, fontSize: FontSize = defaultFontSize): TTF =
  result = TTF(assetType: AssetType.TTF)
  result.fontFace = fontFace

  result.characters = initTable[GLchar, Character](128)

  initializeFont(result, fontSize)
  
proc unload*(ttf: TTF) =
  discard freetype.doneFace(ttf.fontFace)