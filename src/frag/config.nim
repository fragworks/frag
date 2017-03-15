import
  graphics,
  graphics/window

type
  Config* = object
    rootWindowTitle*: string
    rootWindowPosX*, rootWindowPosY*: int
    rootWindowWidth*, rootWindowHeight*: int
    resetFlags*: graphics.ResetFlag
    logFileName*: string
    assetRoot*: string
    debugMode*: graphics.DebugMode
