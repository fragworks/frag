import
  graphics/graphics_types

when defined(js):
  const 
    step* = 1/60


type
  Config* = ref object
    rootWindowTitle*: string
    rootWindowPosX*, rootWindowPosY*: int32
    rootWindowWidth*, rootWindowHeight*: int32
    resetFlags*: ResetFlag
    logFileName*: string
    assetRoot*: string
    debugMode*: uint32
    case imgui*: bool
    of true:
      imguiViewId*: uint8
    else:
      discard
    when defined(js):
      stats*: bool