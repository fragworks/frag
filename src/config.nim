import
  debug,
  graphics/window

type
  FragConfig* = object
    rootWindowTitle*: string
    rootWindowPosX*, rootWindowPosY*: int
    rootWindowWidth*, rootWindowHeight*: int
    rootWindowFlags*: window.WindowFlags
    logFileName*: string
    assetRoot*: string
    engineAssetRoot*: string
    debugMode*: DebugMode