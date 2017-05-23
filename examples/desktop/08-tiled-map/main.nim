import
  colors

when defined(js):
  import 
    jsconsole

when not defined(js):
  import
    events,
    os

  import 
    bgfxdotnim,
    sdl2 as sdl

import
  hashes,
  tables

import
  ../../../src/frag,
  ../../../src/frag/graphics/camera,
  ../../../src/frag/graphics/two_d/spritebatch,
  ../../../src/frag/graphics/two_d/texture,
  ../../../src/frag/graphics/window,
  ../../../src/frag/maps/tiled_map,
  ../../../src/frag/modules/assets

type
  App = ref object
    batch: SpriteBatch
    camera: Camera
    assetIds: Table[string, Hash]
    map: TiledMap
    loading: bool

const WIDTH = 960
const HEIGHT = 540
const HALF_WIDTH = WIDTH / 2
const HALF_HEIGHT = HEIGHT / 2

var assetsLoaded = false

when not defined(js):
  proc resize*(e: EventArgs) =
    let event = SDLEventMessage(e).event
    let sdlEventData = event.sdlEventData
    let app = cast[App](event.userData)
    app.camera.updateViewport(sdlEventData.window.data1.float, sdlEventData.window.data2.float)

proc initApp(app: App, ctx: Frag) =
  logDebug "Initializing app..."

  app.assetIds = initTable[string, Hash]()

  let filename = "maps/map.json"

  logDebug "Loading assets..."
  app.assetIds.add(filename, ctx.assets.load(filename, AssetType.TiledMap))


  app.batch = SpriteBatch(
    blendSrcFunc: BlendFunc.SrcAlpha,
    blendDstFunc: BlendFunc.InvSrcAlpha,
    blendingEnabled: true
  )
  app.batch.init(1000, 0)

  when not defined(js):
    ctx.events.on(SDLEventType.WindowResize, resize)

    app.camera = Camera()
    app.camera.init(0)
    app.camera.ortho(1.0, WIDTH, HEIGHT)
    app.camera.zoom = 2.0

    logDebug "App initialized."

proc shutdownApp(app: App, ctx: Frag) =
  logDebug "Shutting down app..."

  when not defined(js):

    logDebug "Unloading assets..."
    for _, assetId in app.assetIds:
      ctx.assets.unload(assetId)
    logDebug "Assets unloaded."

    app.batch.dispose()

  logDebug "App shut down..."

proc updateApp(app:App, ctx: Frag, deltaTime: float) =
  when not defined(js):
    app.camera.update()

  if ctx.input.down("w", true): app.camera.position[1] += 1
  if ctx.input.down("s", true): app.camera.position[1] -= 1
  if ctx.input.down("d", true): app.camera.position[0] += 1
  if ctx.input.down("a", true): app.camera.position[0] -= 1
  if ctx.input.down("q", true): app.camera.zoomIn()
  if ctx.input.down("e", true): app.camera.zoomOut()
  if ctx.input.pressed("f"):
    app.loading = true
    assetsLoaded = false

  if app.loading:
    while not assetsLoaded and not assets.update(ctx.assets):
      return
    assetsLoaded = true
    app.loading = false

proc renderApp(app: App, ctx: Frag, deltaTime: float) =
  ctx.graphics.clearView(0, ClearMode.Color.ord or ClearMode.Depth.ord, colors.Color(0x303030ff), 1.0, 0)

  if assetsLoaded and app.map.isNil:
    app.map = assets.get[TiledMap](ctx.assets, app.assetIds["maps/map.json"])
  elif assetsLoaded:
    app.map.render(app.batch, app.camera)
    

var conf: Config

when defined js:
  conf = Config(
    rootWindowTitle: "Frag Example 01-sprite-batch",
    assetRoot: "desktop/assets"
  )

else:
  conf = Config(
    rootWindowTitle: "Frag Example 01-sprite-batch",
    rootWindowPosX: window.posUndefined, rootWindowPosY: window.posUndefined,
    rootWindowWidth: 960, rootWindowHeight: 540,
    resetFlags: ResetFlag.VSync,
    logFileName: "example-01.log",
    assetRoot: "../assets",
    debugMode: BGFX_DEBUG_TEXT
  )

startFrag(App(), conf)