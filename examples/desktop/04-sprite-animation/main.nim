import
  hashes,
  tables

import bgfxdotnim

import
  ../../../src/frag,
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
    assetIds: Table[string, Hash]
    stateTime: float
    anim: Animation

const WIDTH = 960
const HEIGHT = 540
const HALF_WIDTH = WIDTH / 2
const HALF_HEIGHT = HEIGHT / 2

proc initializeApp(app: App, ctx: Frag) =
  logDebug "Initializing app..."

  app.assetIds = initTable[string, Hash]()

  let filename = "textures/spritesheet.atlas"

  logDebug "Loading assets..."
  app.assetIds.add(filename, ctx.assets.load(filename, AssetType.TextureAtlas))
  logDebug "Assets loaded."

  let atlas = assets.get[TextureAtlas](ctx.assets, app.assetIds[filename])

  echo repr atlas

  app.anim = animation.fromTextureRegions(
    @[
        atlas.getRegion("test01")
        , atlas.getRegion("test02")
    ]
    , 0.5
  )

  app.batch = SpriteBatch(
    blendSrcFunc: BlendFunc.SrcAlpha,
    blendDstFunc: BlendFunc.InvSrcAlpha,
    blendingEnabled: true
  )
  app.batch.init(1000, 0)

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
  discard

proc renderApp(app: App, ctx: Frag, deltaTime: float) =
  if ctx.input.pressed("q"): echo "quit"

  ctx.graphics.clearView(0, ClearMode.Color.ord or ClearMode.Depth.ord, 0x303030ff, 1.0, 0)

  let region = app.anim.getFrame(app.stateTime)
  app.batch.begin()
  app.batch.draw(region, HALF_WIDTH - region.regionWidth / 2, HALF_HEIGHT - region.regionHeight / 2)
  app.batch.`end`()

  app.stateTime += deltaTime

startFrag[App](Config(
  rootWindowTitle: "Frag Example 01-sprite-batch",
  rootWindowPosX: window.posUndefined, rootWindowPosY: window.posUndefined,
  rootWindowWidth: 960, rootWindowHeight: 540,
  resetFlags: ResetFlag.VSync,
  logFileName: "example-01.log",
  assetRoot: "../assets",
  debugMode: BGFX_DEBUG_TEXT
))
