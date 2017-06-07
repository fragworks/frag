import
  colors,
  events,
  hashes,
  math,
  tables

import
  ../../../src/frag,
  ../../../src/frag/modules/assets,
  ../../../src/frag/config,
  ../../../src/frag/graphics/camera,
  ../../../src/frag/graphics/window,
  ../../../src/frag/math/fpu_math,
  ../../../src/frag/graphics/three_d/modelbatch,
  ../../../src/frag/logger,
  ../../../src/frag/modules/graphics

type
  App = ref object
    assetIds: Table[string, Hash]
    modelBatch: ModelBatch
    camera: Camera

var yaw = 90.0
var pitch = 0.0

proc resize*(e: EventArgs) =
  let event = SDLEventMessage(e).event
  let sdlEventData = event.sdlEventData
  let app = cast[App](event.userData)
  let graphics = event.graphics
  graphics.setViewRect(0, 0, 0, uint16 sdlEventData.window.data1, uint16 sdlEventData.window.data2)

proc mouseMoved*(e: EventArgs) =
  let event = SDLEventMessage(e).event
  let sdlEventData = event.sdlEventData

  if sdlEventData.motion.state == 1:
    let sensitivity = 0.1

    var xOffset = sdlEventData.motion.xrel.float * sensitivity
    var yOffset = sdlEventData.motion.yrel.float * sensitivity

    yaw += xoffset
    pitch += yoffset

    if pitch > 80.0:
      pitch = 89.0
    if pitch < -89.0:
      pitch = -89.0
    let app = cast[App](event.userData)
    var front: Vec3
    front[0] = -cos(degToRad(yaw)) * cos(degToRad(pitch))
    front[1] = -sin(degToRad(pitch))
    front[2] = sin(degToRad(yaw)) * cos(degToRad(pitch))
    vec3Norm(app.camera.direction, front)
  

proc initApp(app: App, ctx: Frag) =
  logDebug "Initializing app..."

  ctx.events.on(SDLEventType.WindowResize, resize)
  ctx.events.on(SDLEventType.MouseMotion, mouseMoved)

  app.assetIds = initTable[string, Hash]()

  var filename = "cyborg/cyborg.obj"

  app.assetIds.add(filename, ctx.assets.load(filename, AssetType.Model))

  app.camera = Camera()
  app.camera.init(0)
  app.camera.perspective(60.0, 960, 540)
  app.camera.position = [0f32, 0f32, -15f32]

  while not assets.update(ctx.assets):
    discard

  app.modelBatch = ModelBatch()
  app.modelBatch.init()

  logDebug "App initialized."

proc updateApp(app:App, ctx: Frag, deltaTime: float) =
  app.camera.update()

  if ctx.input.down("w", true): 
    vec3Add(app.camera.position, app.camera.position, vec3Mul(app.camera.direction, 10 * deltaTime))
  if ctx.input.down("s", true): 
    vec3Sub(app.camera.position, app.camera.position, vec3Mul(app.camera.direction, 10 * deltaTime))
  if ctx.input.down("a", true):
    var tmp: Vec3
    vec3Cross(tmp, app.camera.direction, app.camera.up)
    vec3Norm(tmp, tmp)
    vec3Add(app.camera.position, app.camera.position, vec3Mul(tmp, 10 * deltaTime))
  if ctx.input.down("d", true): 
    var tmp: Vec3
    vec3Cross(tmp, app.camera.direction, app.camera.up)
    vec3Norm(tmp, tmp)
    vec3Sub(app.camera.position, app.camera.position, vec3Mul(tmp, 10 * deltaTime))

proc renderApp(app: App, ctx: Frag, deltaTime: float) =
  ctx.graphics.clearView(0, ClearMode.Color.ord or ClearMode.Depth.ord, colors.Color(0x303030ff), 1.0, 0)

  let model = assets.get[Model](ctx.assets, app.assetIds["cyborg/cyborg.obj"])

  app.modelBatch.begin(960, 540, app.camera)
  app.modelBatch.render(model)
  app.modelBatch.`end`(960, 540, app.camera)

proc shutdownApp(app: App, ctx: Frag) =
  logDebug "Shutting down app..."
  logDebug "App shut down."

startFrag(App(), Config(
  rootWindowTitle: "Frag Example 00-hello-world",
  rootWindowPosX: window.posUndefined, rootWindowPosY: window.posUndefined,
  rootWindowWidth: 960, rootWindowHeight: 540,
  resetFlags: ResetFlag.VSync,
  logFileName: "example-00.log",
  assetRoot: "../assets",
  debugMode: BGFX_DEBUG_NONE
))