import
  graphics,
  graphics/debug,
  graphics/window

type
  Config* = object
    rootWindowTitle*: string
    rootWindowPosX*, rootWindowPosY*: int
    rootWindowWidth*, rootWindowHeight*: int
    resetFlags*: graphics.ResetFlag
    rootWindowFlags*: uint32
    logFileName*: string
    assetRoot*: string
    debugMode*: graphics.DebugMode
