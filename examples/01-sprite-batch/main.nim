import
  hashes,
  logging,
  tables

import
  opengl

import
  ../../src/frag/config,
  ../../src/frag,
  ../../src/frag/assets,
  ../../src/frag/assets/asset,
  ../../src/frag/graphics,
  ../../src/frag/graphics/debug,
  ../../src/frag/graphics/two_d/spritebatch,
  ../../src/frag/graphics/two_d/texture,
  ../../src/frag/graphics/window

type
  App = ref object
    batch: SpriteBatch
    assetIds: Table[string, Hash]

const WIDTH = 960
const HEIGHT = 540
const HALF_WIDTH = WIDTH / 2
const HALF_HEIGHT = HEIGHT / 2

proc initialize*(app: App, ctx: Frag) =
  debug "Initializing app..."

  app.assetIds = initTable[string, Hash]()

  let filename = "textures/test01.png"

  debug "Loading assets..."
  app.assetIds.add(filename, ctx.assets.load(filename, AssetType.Texture))
  debug "Assets loaded."

  app.batch = SpriteBatch(
    blendSrcFunc: BlendFunc.SrcAlpha,
    blendDstFunc: BlendFunc.OneMinusSrcAlpha,
    blendingEnabled: true
  )
  app.batch.init(1000, nil)

  debug "App initialized."

proc shutdown*(app: App, ctx: Frag) =
  debug "Shutting down app..."

  debug "Unloading assets..."
  for _, assetId in app.assetIds:
    ctx.assets.unload(assetId)
  debug "Assets unloaded."

  debug "App shut down..."

proc render*(app: App, ctx: Frag) =
  ctx.graphics.clearColor((0.18, 0.18, 0.18, 1.0))
  ctx.graphics.clear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

  let tex = Texture(ctx.assets.get(app.assetIds["textures/test01.png"]))

  let texHalfW = tex.data.w / 2
  let texHalfH = tex.data.h / 2

  app.batch.begin()
  app.batch.draw(tex, HALF_WIDTH - texHalfW, HALF_HEIGHT - texHalfH, float tex.data.w, float tex.data.h)
  app.batch.`end`()

startFrag[App](Config(
  rootWindowTitle: "Frag Example 01-sprite-batch",
  rootWindowPosX: window.posUndefined, rootWindowPosY: window.posUndefined,
  rootWindowWidth: WIDTH, rootWindowHeight: HEIGHT,
  rootWindowFlags: window.WindowFlags.Default,
  logFileName: "example-01.log",
  assetRoot: "../assets",
  debugMode: DebugMode.Text
))
