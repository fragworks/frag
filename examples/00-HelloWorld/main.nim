import
  opengl

import
  ../../src/config
  , ../../src/dEngine
  , ../../src/graphics
  , ../../src/graphics/window

type
  App = ref object

proc initialize*(app: App, ctx: dEngine) =
  echo "Initializing app."

proc render*(app: App, ctx: dEngine) =
  ctx.graphics.clearColor((0.18, 0.18, 0.18, 1.0))
  ctx.graphics.clear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

startdEngine[App]((
  rootWindowTitle: "dEngine Example 00-HelloWorld", 
  rootWindowPosX: window.posUndefined, rootWindowPosY: window.posUndefined,
  rootWindowWidth: 960, rootWindowHeight: 540,
  rootWindowFlags: window.WindowFlags.Default,
  logFileName: "example-00.log"
))