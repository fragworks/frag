import
  graphics/types

type
  Config* = object
    rootWindowTitle*: string
    rootWindowPosX*, rootWindowPosY*: int
    rootWindowWidth*, rootWindowHeight*: int
    resetFlags*: ResetFlag
    logFileName*: string
    assetRoot*: string
    debugMode*: uint32