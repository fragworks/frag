import
  colors
  
when not defined(js):
  import
    events

import
  ../../../src/frag,
  ../../../src/frag/config,
  ../../../src/frag/graphics/window,
  ../../../src/frag/logger,
  ../../../src/frag/modules/graphics

when not defined(js):
  import
    logo

type
  App = ref object

when not defined(js):
  proc resize*(e: EventArgs) =
    let event = SDLEventMessage(e).event
    let sdlEventData = event.sdlEventData
    # let app = cast[App](event.userData)
    let graphics = event.graphics
    graphics.setViewRect(0, 0, 0, uint16 sdlEventData.window.data1, uint16 sdlEventData.window.data2)

proc initApp(app: App, ctx: Frag) =
  logDebug "Initializing app..."
  when not defined(js):
    ctx.events.on(SDLEventType.WindowResize, resize)
  logDebug "App initialized."

proc updateApp(app:App, ctx: Frag, deltaTime: float) =
  discard

proc renderApp(app: App, ctx: Frag, deltaTime: float) =
  ctx.graphics.clearView(0, ClearMode.Color.ord or ClearMode.Depth.ord, colors.Color(0x303030ff), 1.0, 0)
  when not defined(js):
    let size = ctx.graphics.getSize()

    ctx.graphics.drawDebugImage(
      logo.fragLogo,
      uint16 max(size[0] / 2 / 8, 40) - 40,
      uint16 max(size[1] / 2 / 16, 12.5) - 12.5,
      80,
      25,
      160
    )

proc shutdownApp(app: App, ctx: Frag) =
  logDebug "Shutting down app..."
  logDebug "App shut down."

var conf: Config

when defined js:
  conf = Config(rootWindowTitle: "Frag Example 00-hello-world")

else:
  conf = Config(
    rootWindowTitle: "Frag Example 00-hello-world",
    rootWindowPosX: window.posUndefined, rootWindowPosY: window.posUndefined,
    rootWindowWidth: 960, rootWindowHeight: 540,
    resetFlags: ResetFlag.VSync,
    logFileName: "example-00.log",
    assetRoot: "../assets",
    debugMode: BGFX_DEBUG_TEXT
  )

startFrag(App(), conf)