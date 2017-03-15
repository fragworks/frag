import
  logging

import
  opengl

import
  ../../src/frag/config,
  ../../src/frag,
  ../../src/frag/graphics,
  ../../src/frag/graphics/debug,
  ../../src/frag/graphics/color,
  ../../src/frag/graphics/window

type
  App = ref object

proc initialize*(app: App, ctx: Frag) =
  debug "Initializing app..."
  debug "App initialized."

proc render*(app: App, ctx: Frag) =
  ctx.graphics.clearView(0, graphics.ClearMode.Color.ord or graphics.ClearMode.Depth.ord, 0x303030ff, 1.0, 0)

proc shutdown*(app: App, ctx: Frag) =
  debug "Shutting down app..."
  debug "App shut down."

startFrag[App](Config(
  rootWindowTitle: "Frag Example 00-hello-world",
  rootWindowPosX: window.posUndefined, rootWindowPosY: window.posUndefined,
  rootWindowWidth: 960, rootWindowHeight: 540,
  rootWindowFlags: window.WindowFlag.WindowShown.ord or window.WindowFlag.WindowResizable.ord,
  resetFlags: graphics.ResetFlag.None,
  logFileName: "example-00.log",
  assetRoot: "../assets",
  debugMode: graphics.DebugMode.Text
))
