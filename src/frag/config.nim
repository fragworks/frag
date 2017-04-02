import
  graphics/types

type
  Config* = ref object
    rootWindowTitle*: string
    rootWindowPosX*, rootWindowPosY*: int32
    rootWindowWidth*, rootWindowHeight*: int32
    resetFlags*: ResetFlag
    logFileName*: string
    assetRoot*: string
    debugMode*: uint32