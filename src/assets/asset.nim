import
  tables

import
  freetype,
  glm,
  opengl,
  sdl2 as sdl

type
  AssetType* = enum
    TEXTURE, TTF
  
  Character* = object
    textureID*: GLuint
    size*: Vec2i
    bearing*: Vec2i
    advance*: GLuint

  Asset* = object
    case assetType*: AssetType
    of TEXTURE:
      handle*: GLuint
      filename*: string
      data*: sdl.SurfacePtr
      width*: int
      height*: int
    of TTF:
      fontFace*: Face
      characters*: Table[GLchar, Character]