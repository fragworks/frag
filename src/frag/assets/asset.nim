import
  tables

import
  freetype,
  glm,
  opengl,
  sdl2 as sdl

import
  asset_types,
  ../graphics/shader

type
  Character* = object
    textureID*: GLuint
    size*: Vec2i
    bearing*: Vec2i
    advance*: GLuint
    height*: GLuint

  Asset* = object
    case assetType*: AssetType
    of AssetType.Texture:
      handle*: GLuint
      filename*: string
      data*: sdl.SurfacePtr
      width*: int
      height*: int
    of AssetType.TextureRegion:
      texture*: ref Asset
      u*, v*, u2*, v2*: float
      regionWidth*, regionHeight*: int
    of AssetType.VectorFont:
      fontFace*: Face
      characters*: Table[GLchar, Character]
      vao*, backgroundVAO*, vbo*, backgroundVBO*: GLuint
      shaderProgram*, backgroundProgram*: ShaderProgram

  Texture* = ref Asset
  TextureRegion* = ref Asset