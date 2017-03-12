import
  logging

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
  debug "Initializing app..."

  debug "Loading assets..."
  debug "Assets loaded."

  debug "App initialized."

proc shutdown*(app: App, ctx: dEngine) =
  debug "Shutting down app..."

  debug "Unloading assets..."
  debug "Assets unloaded."

  debug "App shut down..."

proc render*(app: App, ctx: dEngine) =
  ctx.graphics.clearColor((0.18, 0.18, 0.18, 1.0))
  ctx.graphics.clear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

startdEngine[App](dEngineConfig(
  rootWindowTitle: "dEngine Example 01-SpriteBatch", 
  rootWindowPosX: window.posUndefined, rootWindowPosY: window.posUndefined,
  rootWindowWidth: 960, rootWindowHeight: 540,
  rootWindowFlags: window.WindowFlags.Default,
  logFileName: "example-01.log",
  assetRoot: "../assets"
))