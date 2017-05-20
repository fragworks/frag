import
  colors,
  events,
  hashes,
  tables

when not defined(js):
  import 
    bgfxdotnim,
    sdl2 as sdl,

    ../../../src/frag/gui/themes/gui_themes

import
  ../../../src/frag,
  ../../../src/frag/modules/gui,
  ../../../src/frag/graphics/camera,
  ../../../src/frag/graphics/two_d/spritebatch,
  ../../../src/frag/graphics/two_d/texture,
  ../../../src/frag/graphics/window,
  ../../../src/frag/modules/assets

type
  App = ref object
    batch: SpriteBatch
    batchCamera: Camera
    guiCamera: Camera
    assetIds: Table[string, Hash]

const WIDTH = 960
const HEIGHT = 540
var HALF_WIDTH = WIDTH / 2
var HALF_HEIGHT = HEIGHT / 2

when not defined(js):
  proc resize*(e: EventArgs) =
    let event = SDLEventMessage(e).event
    let sdlEventData = event.sdlEventData
    
    let app = cast[App](event.userData)
    
    let w = sdlEventData.window.data1.float
    let h = sdlEventData.window.data2.float

    app.guiCamera.ortho(1.0, w, h, true)
    app.batchCamera.ortho(1.0, w, h)

    HALF_WIDTH = w / 2
    HALF_HEIGHT = h / 2

proc initApp(app: App, ctx: Frag) =
  logDebug "Initializing app..."

  when not defined(js):
    ctx.events.on(SDLEventType.WindowResize, resize)

  app.assetIds = initTable[string, Hash]()

  let filename = "textures/test01.png"

  logDebug "Loading assets..."
  app.assetIds.add(filename, ctx.assets.load(filename, AssetType.Texture))
  
  while not assets.update(ctx.assets):
    discard
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

  when not defined(js):
    gui.setCamera(ctx.gui, app.guiCamera)
    gui.setTheme(ctx.gui, GUITheme.White)

  logDebug "App initialized."

proc shutdownApp(app: App, ctx: Frag) =
  logDebug "Shutting down app..."

  logDebug "Unloading assets..."
  for _, assetId in app.assetIds:
    ctx.assets.unload(assetId)
  logDebug "Assets unloaded."

  when not defined(js):
    app.batch.dispose()

  logDebug "App shut down..."

proc updateApp(app:App, ctx: Frag, deltaTime: float) =
  app.batchCamera.update()
  app.guiCamera.update()
  when not defined(js):
    app.batch.setProjectionMatrix(app.batchCamera.combined)
    gui.setProjectionMatrix(ctx.gui, app.guiCamera.combined, 1)

proc renderApp(app: App, ctx: Frag, deltaTime: float) =
  ctx.graphics.clearView(0, ClearMode.Color.ord or ClearMode.Depth.ord, colors.Color(0x303030ff), 1.0, 0)

  let tex = assets.get[Texture](ctx.assets, app.assetIds["textures/test01.png"])

  let texHalfW = tex.width / 2
  let texHalfH = tex.height / 2

  app.batch.begin()
  app.batch.draw(tex, HALF_WIDTH - texHalfW, HALF_HEIGHT - texHalfH, float tex.width, float tex.height)
  app.batch.`end`()

  when not defined(js):
    if ctx.gui.openWindow("Hello Nuklear IMGUI!", 225, 100, 250, 300, WINDOW_TITLE.ord or WINDOW_NO_SCROLLBAR.ord or WINDOW_CLOSABLE.ord):
    
      ctx.gui.closeWindow()


when defined(js):
  startFrag(App(), Config(
    rootWindowTitle: "Frag Example 05-gui",
    assetRoot: "desktop/assets",
    imgui: true
  ))

else:
  startFrag(App(), Config(
    rootWindowTitle: "Frag Example 05-gui",
    rootWindowPosX: window.posUndefined, rootWindowPosY: window.posUndefined,
    rootWindowWidth: 960, rootWindowHeight: 540,
    resetFlags: ResetFlag.VSync,
    logFileName: "example-05.log",
    assetRoot: "../assets",
    debugMode: BGFX_DEBUG_TEXT,
    imgui: true,
    imguiViewId: 1
  ))
