import
  colors,
  events,
  hashes,
  tables

import
  ../../../src/frag,
  ../../../src/frag/modules/assets,
  ../../../src/frag/config,
  ../../../src/frag/graphics/camera,
  ../../../src/frag/graphics/window,
  ../../../src/frag/graphics/three_d/modelbatch,
  ../../../src/frag/logger,
  ../../../src/frag/modules/graphics

type
  App = ref object
    assetIds: Table[string, Hash]
    modelBatch: ModelBatch
    camera: Camera

proc resize*(e: EventArgs) =
  let event = SDLEventMessage(e).event
  let sdlEventData = event.sdlEventData
  # let app = cast[App](event.userData)
  let graphics = event.graphics
  graphics.setViewRect(0, 0, 0, uint16 sdlEventData.window.data1, uint16 sdlEventData.window.data2)

proc initApp(app: App, ctx: Frag) =
  logDebug "Initializing app..."
  ctx.events.on(SDLEventType.WindowResize, resize)

  app.assetIds = initTable[string, Hash]()

  var filename = "models/nanosuit/nanosuit.obj"

  app.assetIds.add(filename, ctx.assets.load(filename, AssetType.Model))

  app.modelBatch = ModelBatch()
  app.modelBatch.init()

  app.camera = Camera()
  app.camera.init(0)
  app.camera.perspective(1.0, WIDTH, HEIGHT)

  logDebug "App initialized."

  while not assets.update(ctx.assets):
    discard

proc updateApp(app:App, ctx: Frag, deltaTime: float) =
  discard

proc renderApp(app: App, ctx: Frag, deltaTime: float) =
  ctx.graphics.clearView(0, ClearMode.Color.ord or ClearMode.Depth.ord, colors.Color(0x303030ff), 1.0, 0)

  let model = assets.get[Model](ctx.assets, app.assetIds["models/nanosuit/nanosuit.obj"])

  app.modelBatch.begin()
  app.modelBatch.render(model)
  app.modelBatch.`end`()

proc shutdownApp(app: App, ctx: Frag) =
  logDebug "Shutting down app..."
  logDebug "App shut down."

startFrag(App(), Config(
  rootWindowTitle: "Frag Example 00-hello-world",
  rootWindowPosX: window.posUndefined, rootWindowPosY: window.posUndefined,
  rootWindowWidth: 960, rootWindowHeight: 540,
  resetFlags: ResetFlag.VSync,
  logFileName: "example-00.log",
  assetRoot: "../assets",
  debugMode: BGFX_DEBUG_NONE
))