import
  graphics/debug,
  graphics/window

type
  Config* = object
    rootWindowTitle*: string
    rootWindowPosX*, rootWindowPosY*: int
    rootWindowWidth*, rootWindowHeight*: int
    rootWindowFlags*: window.WindowFlags
    logFileName*: string
    assetRoot*: string
    debugMode*: DebugMode
