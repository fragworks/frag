import
  hashes,
  tables

import
  sound.sound

import
  ../../../src/frag,
  ../../../src/frag/assets,
  ../../../src/frag/assets/asset,
  ../../../src/frag/assets/asset_types,
  ../../../src/frag/config,
  ../../../src/frag/graphics,
  ../../../src/frag/graphics/two_d/spritebatch,
  ../../../src/frag/graphics/two_d/texture,
  ../../../src/frag/graphics/window,
  ../../../src/frag/logger

type
  App = ref object
    batch: SpriteBatch
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
    blendSrcFunc: graphics.BlendFunc.SrcAlpha,
    blendDstFunc: graphics.BlendFunc.InvSrcAlpha,
    blendingEnabled: true
  )
  app.batch.init(1000, 0)


  var snd = sound.newSoundWithFile("examples/desktop/assets/sounds/test.ogg")
  snd.`gain=`(0.5)

  snd.play()

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
  discard

proc renderApp(app: App, ctx: Frag) =
  ctx.graphics.clearView(0, graphics.ClearMode.Color.ord or graphics.ClearMode.Depth.ord, 0x303030ff, 1.0, 0)

  let tex = assets.get[Texture](ctx.assets, app.assetIds["textures/test01.png"])

  let texHalfW = tex.width / 2
  let texHalfH = tex.height / 2

  app.batch.begin()
  app.batch.draw(tex, HALF_WIDTH - texHalfW, HALF_HEIGHT - texHalfH, float tex.width, float tex.height)
  app.batch.`end`()

startFrag[App](Config(
  rootWindowTitle: "Frag Example 02-audio",
  rootWindowPosX: window.posUndefined, rootWindowPosY: window.posUndefined,
  rootWindowWidth: 960, rootWindowHeight: 540,
  resetFlags: graphics.ResetFlag.None,
  logFileName: "example-01.log",
  assetRoot: "../assets",
  debugMode: graphics.DebugMode.Text
))
