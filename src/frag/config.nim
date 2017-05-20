import
  graphics/types

export
  types

type
  Config* = ref object
    rootWindowTitle*: string
    rootWindowPosX*, rootWindowPosY*: int
    rootWindowWidth*, rootWindowHeight*: int
    resetFlags*: ResetFlag
    logFileName*: string
    assetRoot*: string
    debugMode*: uint32
    case imgui*: bool
    of true:
      imguiViewId*: uint8
    else:
      discard