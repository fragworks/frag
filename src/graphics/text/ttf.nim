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

    var texture : GLuint
    glGenTextures(1, addr texture)
    glBindTexture(GL_TEXTURE_2D, texture)
    glTexImage2D(
        GL_TEXTURE_2D,
        0,
        GL_RED.ord,
        GLsizei ttf.fontFace.glyph.bitmap.width,
        GLsizei ttf.fontFace.glyph.bitmap.rows,
        0,
        GL_RED,
        GL_UNSIGNED_BYTE,
        ttf.fontFace.glyph.bitmap.buffer
    )

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)

    echo repr GLchar c

    ttf.characters.add(
      GLchar c,
      Character(
        textureID: texture,
        size: vec2i(int32 ttf.fontFace.glyph.bitmap.width, int32 ttf.fontFace.glyph.bitmap.rows),
        bearing: vec2i(ttf.fontFace.glyph.bitmap_left, ttf.fontFace.glyph.bitmap_top),
        advance: uint32 ttf.fontFace.glyph.advance.x
      )
    )

  echo repr ttf.characters

proc load*(fontFace: Face, fontSize: FontSize = defaultFontSize): TTF =
  result = TTF(assetType: AssetType.TTF)
  result.fontFace = fontFace

  result.characters = initTable[GLchar, Character](128)

  initializeFont(result, fontSize)
  
proc unload*(ttf: TTF) =
  for character in ttf.characters.mvalues:
    glDeleteTextures(1, addr character.textureID)

  discard freetype.doneFace(ttf.fontFace)