import
  hashes,
  logging,
  tables

import
  sdl2 as sdl

import
  ../../../src/frag/config,
  ../../../src/frag,
  ../../../src/frag/assets,
  ../../../src/frag/assets/asset,
  ../../../src/frag/assets/asset_types,
  ../../../src/frag/graphics,
  ../../../src/frag/graphics/two_d/spritebatch,
  ../../../src/frag/graphics/two_d/texture,
  ../../../src/frag/graphics/window,
  ../../../src/frag/input,
  ../../../src/frag/math/fpu_math as math

type
  App = ref object
    batch: SpriteBatch
    assetIds: Table[string, Hash]
    player: Player

  Player = ref object
    texture: Texture
    position: Vec2

const WIDTH = 960
const HEIGHT = 540
const HALF_WIDTH = WIDTH / 2
const HALF_HEIGHT = HEIGHT / 2

proc initializeApp(app: App, ctx: Frag) =
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

  app.player = Player()
  app.player.texture = assets.get[Texture](ctx.assets, app.assetIds["textures/test01.png"])

  app.player.position = [float32 HALF_WIDTH - (app.player.texture.width / 2), HALF_HEIGHT - (app.player.texture.height / 2)]

  debug "App initialized."

proc shutdownApp(app: App, ctx: Frag) =
  debug "Shutting down app..."

  debug "Unloading assets..."
  for _, assetId in app.assetIds:
    ctx.assets.unload(assetId)
  debug "Assets unloaded."

  debug "App shut down..."

proc updateApp(app: App, ctx: Frag, deltaTime: float) =
  if ctx.input.down("w", true): app.player.position[1] += 1
  if ctx.input.down("s", true): app.player.position[1] -= 1
  if ctx.input.down("d", true): app.player.position[0] += 1
  if ctx.input.down("a", true): app.player.position[0] -= 1

proc renderApp(app: App, ctx: Frag) =
  ctx.graphics.clearView(0, graphics.ClearMode.Color.ord or graphics.ClearMode.Depth.ord, 0x303030ff, 1.0, 0)

  app.batch.begin()
  app.batch.draw(app.player.texture, app.player.position[0], app.player.position[1], float32 app.player.texture.width, float32 app.player.texture.height)
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
