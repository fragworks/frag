import
  events

import
  hashes,
  tables

import 
  bgfxdotnim,
  sdl2 as sdl

import
  ../../../src/frag,
  ../../../src/frag/graphics/camera,
  ../../../src/frag/graphics/two_d/spritebatch,
  ../../../src/frag/graphics/two_d/texture,
  ../../../src/frag/graphics/window,
  ../../../src/frag/modules/assets

type
  App = ref object
    batch: SpriteBatch
    camera: Camera
    assetIds: Table[string, Hash]

const WIDTH = 960
const HEIGHT = 540
const HALF_WIDTH = WIDTH / 2
const HALF_HEIGHT = HEIGHT / 2

var assetsLoaded = false

proc resize*(e: EventArgs) =
  let event = SDLEventMessage(e).event
  let sdlEventData = event.sdlEventData
  let app = cast[App](event.userData)
  app.camera.updateViewport(sdlEventData.window.data1.float, sdlEventData.window.data2.float)

proc initApp(app: App, ctx: Frag) =
  logDebug "Initializing app..."
  ctx.events.on(SDLEventType.WindowResize, resize)

  app.assetIds = initTable[string, Hash]()

  let filename = "textures/test01.png"
  let filename2 = "textures/test02.png"

  logDebug "Loading assets..."
  app.assetIds.add(filename, ctx.assets.load(filename, AssetType.Texture))
  app.assetIds.add(filename2, ctx.assets.load(filename2, AssetType.Texture))

  app.batch = SpriteBatch(
    blendSrcFunc: BlendFunc.SrcAlpha,
    blendDstFunc: BlendFunc.InvSrcAlpha,
    blendingEnabled: true
  )
  app.batch.init(1000, 0)

  app.camera = Camera()
  app.camera.init(0)
  app.camera.ortho(1.0, WIDTH, HEIGHT)

  logDebug "App initialized."

proc shutdownApp(app: App, ctx: Frag) =
  logDebug "Shutting down app..."

  logDebug "Unloading assets..."
  for _, assetId in app.assetIds:
    ctx.assets.unload(assetId)
  logDebug "Assets unloaded."

  app.batch.dispose()

  logDebug "App shut down..."

proc updateApp(app:App, ctx: Frag, deltaTime: float) =
  app.camera.update()
  app.batch.setProjectionMatrix(app.camera.combined)

  while not assetsLoaded and not assets.update(ctx.assets):
    discard
  assetsLoaded = true

proc renderApp(app: App, ctx: Frag, deltaTime: float) =
  ctx.graphics.clearView(0, ClearMode.Color.ord or ClearMode.Depth.ord, 0x303030ff, 1.0, 0)

  if assetsLoaded:
    let tex = assets.get[Texture](ctx.assets, app.assetIds["textures/test01.png"])
    let tex2 = assets.get[Texture](ctx.assets, app.assetIds["textures/test02.png"])

    let texHalfW = tex.width / 2
    let texHalfH = tex.height / 2

    app.batch.begin()
    app.batch.draw(tex, HALF_WIDTH - texHalfW, HALF_HEIGHT - texHalfH, float tex.width, float tex.height)
    app.batch.draw(tex2, HALF_WIDTH + texHalfW, HALF_HEIGHT - texHalfH, float tex.width, float tex.height)
    app.batch.`end`()

startFrag(App(), Config(
  rootWindowTitle: "Frag Example 01-sprite-batch",
  rootWindowPosX: window.posUndefined, rootWindowPosY: window.posUndefined,
  rootWindowWidth: 960, rootWindowHeight: 540,
  resetFlags: ResetFlag.VSync,
  logFileName: "example-01.log",
  assetRoot: "../assets",
  debugMode: BGFX_DEBUG_TEXT
))
