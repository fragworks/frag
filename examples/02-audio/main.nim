import
  hashes,
  logging,
  tables

import
  solouddotnim

import
  ../../src/frag/config,
  ../../src/frag,
  ../../src/frag/assets,
  ../../src/frag/assets/asset,
  ../../src/frag/assets/asset_types,
  ../../src/frag/graphics,
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
    blendSrcFunc: graphics.BlendFunc.SrcAlpha,
    blendDstFunc: graphics.BlendFunc.InvSrcAlpha,
    blendingEnabled: true
  )
  app.batch.init(1000, 0)


  var sl : ptr Soloud

  sl = Soloud_create()

  echo Soloud_init(sl)

  Soloud_setGlobalVolume(sl, 1)


  var stream = WavStream_create()
  echo WavStream_load(cast[ptr Wav](stream), "examples/assets/sounds/test.ogg")


  discard Soloud_play(cast[ptr Soloud](sl), cast[ptr Wav](stream))

  debug "App initialized."

proc shutdown*(app: App, ctx: Frag) =
  debug "Shutting down app..."

  debug "Unloading assets..."
  for _, assetId in app.assetIds:
    ctx.assets.unload(assetId)
  debug "Assets unloaded."

  debug "App shut down..."

proc render*(app: App, ctx: Frag) =
  ctx.graphics.clearView(0, graphics.ClearMode.Color.ord or graphics.ClearMode.Depth.ord, 0x303030ff, 1.0, 0)

  let tex = assets.get[Texture](ctx.assets, app.assetIds["textures/test01.png"])

  let texHalfW = tex.width / 2
  let texHalfH = tex.height / 2

  app.batch.begin()
  app.batch.draw(tex, HALF_WIDTH - texHalfW, HALF_HEIGHT - texHalfH, float tex.width, float tex.height)
  app.batch.`end`()

startFrag[App](Config(
  rootWindowTitle: "Frag Example 01-sprite-batch",
  rootWindowPosX: window.posUndefined, rootWindowPosY: window.posUndefined,
  rootWindowWidth: 960, rootWindowHeight: 540,
  resetFlags: graphics.ResetFlag.None,
  logFileName: "example-01.log",
  assetRoot: "../assets",
  debugMode: graphics.DebugMode.Text
))
