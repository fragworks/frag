import
  logging

import
  opengl

import
  ../../src/frag/config,
  ../../src/frag/debug,
  ../../src/frag,
  ../../src/frag/graphics,
  ../../src/frag/graphics/color,
  ../../src/frag/graphics/window

type
  App = ref object

proc initialize*(app: App, ctx: Frag) =
  debug "Initializing app..."
  debug "App initialized."

proc render*(app: App, ctx: Frag) =
  ctx.graphics.clearColor((0.18, 0.18, 0.18, 1.0))
  ctx.graphics.clear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  ctx.debug.printText("This is sample text", 20.0, 20.0, 1.0, (1.0, 0.0, 0.0, 1.0))

proc shutdown*(app: App, ctx: Frag) =
  debug "Shutting down app..."
  debug "App shut down."

startFrag[App](FragConfig(
  rootWindowTitle: "Frag Example 00-hello-world",
  rootWindowPosX: window.posUndefined, rootWindowPosY: window.posUndefined,
  rootWindowWidth: 960, rootWindowHeight: 540,
  rootWindowFlags: window.WindowFlags.Default,
  logFileName: "example-00.log",
  assetRoot: "../assets",
  debugMode: DebugMode.TEXT
))
