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
  ../../../src/frag/math/fpu_math as math,
  ../../../src/frag/modules/assets

type
  App = ref object
    batch: SpriteBatch
    camera: Camera
    assetIds: Table[string, Hash]
    player: Player

  Player = ref object
    texture: Texture
    position: Vec2

const WIDTH = 960
const HEIGHT = 540
const HALF_WIDTH = WIDTH / 2
const HALF_HEIGHT = HEIGHT / 2
const PLAYER_SPEED = 100.0

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

  app.camera = Camera()
  app.camera.init(0)
  app.camera.ortho(1.0, WIDTH, HEIGHT)

  app.player = Player()
  app.player.texture = assets.get[Texture](ctx.assets, app.assetIds["textures/test01.png"])

  app.player.position = [float32 HALF_WIDTH - (app.player.texture.data.w / 2), HALF_HEIGHT - (app.player.texture.data.h / 2)]

  logDebug "App initialized."

proc shutdownApp(app: App, ctx: Frag) =
  logDebug "Shutting down app..."

  logDebug "Unloading assets..."
  for _, assetId in app.assetIds:
    ctx.assets.unload(assetId)
  logDebug "Assets unloaded."

  app.batch.dispose()

  logDebug "App shut down..."

proc updateApp(app: App, ctx: Frag, deltaTime: float) =
  app.camera.update()
  app.batch.setProjectionMatrix(app.camera.combined)

  if ctx.input.down("w", true): app.player.position[1] += PLAYER_SPEED * deltaTime
  if ctx.input.down("s", true): app.player.position[1] -= PLAYER_SPEED * deltaTime
  if ctx.input.down("d", true): app.player.position[0] += PLAYER_SPEED * deltaTime
  if ctx.input.down("a", true): app.player.position[0] -= PLAYER_SPEED * deltaTime

proc renderApp(app: App, ctx: Frag, deltaTime: float) =
  ctx.graphics.clearView(0, ClearMode.Color.ord or ClearMode.Depth.ord, 0x303030ff, 1.0, 0)

  app.batch.begin()
  app.batch.draw(app.player.texture, app.player.position[0], app.player.position[1], float32 app.player.texture.data.w, float32 app.player.texture.data.h)
  app.batch.`end`()

startFrag[App](Config(
  rootWindowTitle: "Frag Example 01-sprite-batch",
  rootWindowPosX: window.posUndefined, rootWindowPosY: window.posUndefined,
  rootWindowWidth: 960, rootWindowHeight: 540,
  resetFlags: ResetFlag.VSync,
  logFileName: "example-01.log",
  assetRoot: "../assets",
  debugMode: BGFX_DEBUG_TEXT
))
