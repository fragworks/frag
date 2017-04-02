import
  events,
  hashes,
  tables

import 
  bgfxdotnim,
  sdl2 as sdl

import
  ../../../src/frag,
  ../../../src/frag/graphics/camera,
  ../../../src/frag/graphics/two_d/animation,
  ../../../src/frag/graphics/two_d/spritebatch,
  ../../../src/frag/graphics/two_d/texture,
  ../../../src/frag/graphics/two_d/texture_atlas,
  ../../../src/frag/graphics/two_d/texture_region,
  ../../../src/frag/graphics/window,
  ../../../src/frag/modules/assets

type
  App = ref object
    batch: SpriteBatch
    camera: Camera
    assetIds: Table[string, Hash]
    stateTime: float
    anim: Animation

const WIDTH = 960
const HEIGHT = 540
const HALF_WIDTH = WIDTH / 2
const HALF_HEIGHT = HEIGHT / 2

proc resize*(e: EventArgs) =
  let event = SDLEventMessage(e).event
  let sdlEventData = event.sdlEventData
  let app = cast[App](event.userData)
  app.camera.updateViewport(sdlEventData.window.data1.float, sdlEventData.window.data2.float)

proc initApp(app: App, ctx: Frag) =
  logDebug "Initializing app..."

  ctx.events.on(SDLEventType.WindowResize, resize)

  app.assetIds = initTable[string, Hash]()

  let filename = "textures/spritesheet.atlas"

  logDebug "Loading assets..."
  app.assetIds.add(filename, ctx.assets.load(filename, AssetType.TextureAtlas))
  logDebug "Assets loaded."

  let atlas = assets.get[TextureAtlas](ctx.assets, app.assetIds[filename])

  app.anim = animation.fromTextureRegions(
    @[
        atlas.getRegion("p1_walk01")
        , atlas.getRegion("p1_walk02")
        , atlas.getRegion("p1_walk03")
        , atlas.getRegion("p1_walk04")
        , atlas.getRegion("p1_walk05")
        , atlas.getRegion("p1_walk06")
        , atlas.getRegion("p1_walk07")
        , atlas.getRegion("p1_walk08")
        , atlas.getRegion("p1_walk09")
        , atlas.getRegion("p1_walk10")
        , atlas.getRegion("p1_walk11")
    ]
    , 0.1
  )

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
  #for _, assetId in app.assetIds:
    #ctx.assets.unload(assetId)
  logDebug "Assets unloaded."

  app.batch.dispose()

  logDebug "App shut down..."

proc updateApp(app:App, ctx: Frag, deltaTime: float) =
  app.camera.update()
  app.batch.setProjectionMatrix(app.camera.combined)

proc renderApp(app: App, ctx: Frag, deltaTime: float) =
  ctx.graphics.clearView(0, ClearMode.Color.ord or ClearMode.Depth.ord, 0x303030ff, 1.0, 0)

  let region = app.anim.getFrame(app.stateTime)
  app.batch.begin()
  app.batch.drawRegion(region, HALF_WIDTH - region.regionWidth / 2, HALF_HEIGHT - region.regionHeight / 2)
  app.batch.`end`()

  app.stateTime += deltaTime

startFrag(App(), Config(
  rootWindowTitle: "Frag Example 04-sprite-animation",
  rootWindowPosX: window.posUndefined, rootWindowPosY: window.posUndefined,
  rootWindowWidth: 960, rootWindowHeight: 540,
  resetFlags: ResetFlag.VSync,
  logFileName: "example-04.log",
  assetRoot: "../assets",
  debugMode: BGFX_DEBUG_TEXT
))
