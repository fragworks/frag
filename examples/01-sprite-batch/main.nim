import
  logging

import
  opengl

import
  ../../src/frag/config,
  ../../src/frag/debug,
  ../../src/frag,
  ../../src/frag/graphics,
  ../../src/frag/graphics/window

type
  App = ref object

proc initialize*(app: App, ctx: Frag) =
  debug "Initializing app..."

  debug "Loading assets..."
  debug "Assets loaded."

  debug "App initialized."

proc shutdown*(app: App, ctx: Frag) =
  debug "Shutting down app..."

  debug "Unloading assets..."
  debug "Assets unloaded."

  debug "App shut down..."

proc render*(app: App, ctx: Frag) =
  ctx.graphics.clearColor((0.18, 0.18, 0.18, 1.0))
  ctx.graphics.clear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

startFrag[App](FragConfig(
  rootWindowTitle: "Frag Example 01-sprite-batch",
  rootWindowPosX: window.posUndefined, rootWindowPosY: window.posUndefined,
  rootWindowWidth: 960, rootWindowHeight: 540,
  rootWindowFlags: window.WindowFlags.Default,
  logFileName: "example-01.log",
  assetRoot: "../assets",
  debugMode: DebugMode.TEXT
))
