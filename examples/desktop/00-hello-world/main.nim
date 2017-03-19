import
  ../../../src/frag,
  ../../../src/frag/config,
  ../../../src/frag/graphics,
  ../../../src/frag/graphics/color,
  ../../../src/frag/graphics/window,
  ../../../src/frag/logger

type
  App = ref object

proc initializeApp(app: App, ctx: Frag) =
  logDebug "Initializing app..."
  logDebug "App initialized."

proc updateApp(app:App, ctx: Frag, deltaTime: float) =
  discard

proc renderApp(app: App, ctx: Frag) =
  ctx.graphics.clearView(0, graphics.ClearMode.Color.ord or graphics.ClearMode.Depth.ord, 0x303030ff, 1.0, 0)

proc shutdownApp(app: App, ctx: Frag) =
  logDebug "Shutting down app..."
  logDebug "App shut down."

startFrag[App](Config(
  rootWindowTitle: "Frag Example 00-hello-world",
  rootWindowPosX: window.posUndefined, rootWindowPosY: window.posUndefined,
  rootWindowWidth: 960, rootWindowHeight: 540,
  resetFlags: graphics.ResetFlag.None,
  logFileName: "example-00.log",
  assetRoot: "../assets",
  debugMode: graphics.DebugMode.Text
))
