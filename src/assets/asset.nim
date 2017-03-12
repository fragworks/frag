import
  opengl,
  sdl2 as sdl

type
  AssetType* = enum
    TEXTURE, TTF
  
  Asset* = object
    case assetType*: AssetType
    of TEXTURE:
      handle*: GLuint
      filename*: string
      data*: sdl.SurfacePtr
      width*: int
      height*: int
    of TTF:
      discard