import
  graphics/window

type
  dEngineConfig* = tuple[
    rootWindowTitle: string
    , rootWindowPosX, rootWindowPosY: int
    , rootWindowWidth, rootWindowHeight: int
    , rootWindowFlags: window.WindowFlags
    , logFileName: string
  ]