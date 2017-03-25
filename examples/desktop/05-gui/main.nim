import
  hashes,
  tables

import bgfxdotnim

import
  ../../../src/frag,
  ../../../src/frag/modules/gui,
  ../../../src/frag/graphics/camera,
  ../../../src/frag/graphics/two_d/spritebatch,
  ../../../src/frag/graphics/two_d/texture,
  ../../../src/frag/graphics/window,
  ../../../src/frag/gui/themes/gui_themes,
  ../../../src/frag/modules/assets

type
  App = ref object
    batch: SpriteBatch
    batchCamera: Camera
    guiCamera: Camera
    assetIds: Table[string, Hash]

const WIDTH = 960
const HEIGHT = 540
const HALF_WIDTH = WIDTH / 2
const HALF_HEIGHT = HEIGHT / 2

proc initializeApp(app: App, ctx: Frag) =
  logDebug "Initializing app..."

  app.assetIds = initTable[string, Hash]()

  let filename = "textures/test01.png"

  logDebug "Loading assets..."
  app.assetIds.add(filename, ctx.assets.load(filename, AssetType.Texture))
  logDebug "Assets loaded."

  app.batch = SpriteBatch(
    blendSrcFunc: BlendFunc.SrcAlpha,
    blendDstFunc: BlendFunc.InvSrcAlpha,
    blendingEnabled: true
  )
  app.batch.init(1000, 0)

  app.batchCamera = Camera()
  app.guiCamera = Camera()

  app.batchCamera.init(0)
  app.guiCamera.init(1)

  app.batchCamera.ortho(1.0, WIDTH, HEIGHT)
  app.guiCamera.ortho(1.0, WIDTH, HEIGHT, true)

  gui.setTheme(ctx.gui, GUITheme.White)

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
  app.batchCamera.update()
  app.guiCamera.update()
  app.batch.setProjectionMatrix(app.batchCamera.combined)
  gui.setProjectionMatrix(ctx.gui, app.guiCamera.combined)

proc renderApp(app: App, ctx: Frag, deltaTime: float) =
  if ctx.input.pressed("q"): echo "quit"

  ctx.graphics.clearView(0, ClearMode.Color.ord or ClearMode.Depth.ord, 0x303030ff, 1.0, 0)

  let tex = assets.get[Texture](ctx.assets, app.assetIds["textures/test01.png"])

  let texHalfW = tex.data.w / 2
  let texHalfH = tex.data.h / 2

  app.batch.begin()
  app.batch.draw(tex, HALF_WIDTH - texHalfW, HALF_HEIGHT - texHalfH, float tex.data.w, float tex.data.h)
  app.batch.`end`()

  if ctx.gui.openWindow("Hello Nuklear IMGUI!", 225, 100, 250, 300, WINDOW_TITLE.ord or WINDOW_NO_SCROLLBAR.ord or WINDOW_CLOSABLE.ord):
    
    ctx.gui.closeWindow()

startFrag[App](Config(
  rootWindowTitle: "Frag Example 05-gui",
  rootWindowPosX: window.posUndefined, rootWindowPosY: window.posUndefined,
  rootWindowWidth: 960, rootWindowHeight: 540,
  resetFlags: ResetFlag.VSync,
  logFileName: "example-05.log",
  assetRoot: "../assets",
  debugMode: BGFX_DEBUG_TEXT
))
