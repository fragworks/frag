import glm, opengl, nvg, sdl2, model

import 
  asset
  , dEngine
  , event
  , graphics
  , game
  , gui/types
  , gui/widgets
  , gui
  , log
  , lighting
  , model
  , skinned_model
  , modelbatch
  , spritebatch
  , texture

type
  Derelict = ref object of AbstractGame
    #batch: SpriteBatch
    batch: ModelBatch
    deltaTime: float
    timeElapsed: uint32

var label : Label
var firstMouse = true
var lastX, lastY : GLfloat
var dragActive = false
#var quad: model.Model
#var m: model.Model
var sm: skinned_model.Model
var tex: Texture

var originalWidth, originalHeight : int

proc gameWindowResized(event: Event) : bool =
  case event.window.event
  of WindowEvent_Resized:
    var bounds = @[cfloat 0.0, cfloat 0.0, cfloat 0.0, cfloat 0.0]
    nvgFontFace(getContext(), "orbitron")
    nvgFontSize(getContext(), 72.0)
    let labelWidth = nvgTextBounds(getContext(), label.position.x, label.position.y, label.text, nil, addr bounds[0])
    Widget(label).moveLabelTo(getWidth() / 2 - (labelWidth / 2), getHeight() / 2 + ((bounds[3] - bounds[1]) / 2))
  else:
    discard
  #[
    var bounds = @[cfloat 0.0, cfloat 0.0, cfloat 0.0, cfloat 0.0]
    nvgFontFace(getContext(), "orbitron")
    nvgFontSize(getContext(), 72.0)
    let labelWidth = nvgTextBounds(getContext(), label.bounds.left, label.bounds.top, label.text, nil, addr bounds[0])
    label.bounds.left = (getWidth() / 2) - (labelWidth/2)
    if event.window.data1 > originalWidth:
      label.bounds.top = (getHeight() / 2) + (bounds[3] - bounds[1] / 2)
    else:
      label.bounds.top = (getHeight() / 2) + (bounds[3] - bounds[1]) / 2
  else:
    discard
  ]#

var derelict : Derelict

proc listenForInputEvent(event: Event) : bool =
  case event.kind
  of KeyDown:
    case event.key.keysym.sym
    of K_Q:
      moveCameraUp(derelict.batch, derelict.deltaTime)
    of K_E:
      moveCameraDown(derelict.batch, derelict.deltaTime)
    of K_W:
      moveCameraForward(derelict.batch, derelict.deltaTime)
    of K_S:
      moveCameraBackward(derelict.batch, derelict.deltaTime)
    of K_A:
      moveCameraLeft(derelict.batch, derelict.deltaTime)
    of K_D:
      moveCameraRight(derelict.batch, derelict.deltaTime)
    else:
     discard
  of MouseMotion:
    if dragActive:
      adjustCameraYawAndPitch(derelict.batch, float(float(event.motion.xrel) * 0.25), float(float(event.motion.yrel) * 0.25))
  of MouseButtonDown:
    dragActive = true
  of MouseButtonUp:
    dragActive = false
  else:
    discard

proc init*(derelict: Derelict) =
  logInfo("Initializing derelict...")
  #derelict.batch = newSpriteBatch(1000, nil)
  var environment = newEnvironment()
  environment.lights.add(newDirectionalLight(vec3f(1.0, 0.0, 0.0), 0.75))
  environment.lights.add(newPointLight(vec3f(3.0, 10.0, 5.0), vec3f(1.0, 0.0, 0.0), (0.0, 0.1, 0.0)))
  environment.lights.add(newPointLight(vec3f(-3.0, 5.0, 5.0), vec3f(0.0, 0.0, 1.0), (0.0, 0.1, 0.0)))
  environment.lights.add(newSpotLight(vec3f(0,0,0), 20.0))
  derelict.batch = newModelBatch(environment)
  load("assets/textures/test.png")
  #load("assets/textures/megaman.png")
  #m = model.Model model.loadModel("assets/models/bob/boblampclean.md5mesh")
  sm = skinned_model.Model skinned_model.loadModel("assets/models/walking.dae")
  #m = model.Model model.loadModel("assets/models/nanosuit/nanosuit.obj")
  #quad = model.Model model.loadModel("assets/models/quad.obj")
  let position = vec2f(getWidth()/2, getHeight()/2)
  let text = "dEngine"

  discard registerFont("orbitron", "assets/fonts/orbitron/Orbitron Bold.ttf")

  var bounds = @[cfloat 0.0, cfloat 0.0, cfloat 0.0, cfloat 0.0]
  nvgFontFace(getContext(), "orbitron")
  nvgFontSize(getContext(), 72.0)
  let labelWidth = nvgTextBounds(getContext(), position.x, position.y, text, nil, addr bounds[0])

  label = newLabel(
    text
    , "orbitron"
    , true
    , nvgRGBA(255, 255, 255, 150)
    , vec2f(position.x - (labelWidth / 2), position.y  + ((bounds[3] - bounds[1]) / 2))
    , 72.0
  )

  
  registerWidget(label)

  registerEventListener(gameWindowResized, @[WindowEvent])
  registerEventListener(listenForInputEvent, @[KeyDown, KeyUp, MouseMotion, MouseButtonUp, MouseButtonDown])

  layoutGUI()

  originalWidth = getWidth()
  originalHeight = getHeight()
  
proc update(derelict: Derelict, deltaTime: float) =
  derelict.deltaTime = deltaTime

proc render(derelict: Derelict, deltaTime: float) =
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT)
  #glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

  #let texture = Texture get("assets/textures/test.png")
  #let texture = Texture get("assets/textures/megaman.png")
  #texture.setFilter(GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR)
  derelict.batch.begin()
  #derelict.batch.draw(texture, 0, 0, float texture.data.w, float texture.data.h)
  #derelict.batch.draw(newTextureRegion(texture, 0, 0, 1024, 1024), 20, 20)
  let texture = Texture get("assets/textures/test.png")
  texture.`bind`()
  
  glEnable(GL_DEPTH_TEST)

  #derelict.batch.draw(quad, vec3f(0,0,0), 1.5708, vec3f(1, 0, 0), vec3f(10, 10, 1))
  
  glDisable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glEnable(GL_CULL_FACE)
  glFrontFace(GL_CCW)
  glCullFace(GL_BACK)
  #derelict.batch.draw(m)
  derelict.batch.draw(sm)
  glDisable(GL_CULL_FACE)
  glDisable(GL_DEPTH_TEST)
  glDisable(GL_BLEND)

  derelict.batch.`end`()
  

proc dispose(derelict: Derelict) =
  discard
  unload("assets/textures/test.png")
  #unload("assets/textures/megaman.png")
  

proc newGame() : Derelict =
  result = Derelict()
  result.timeElapsed = 0

proc toDerelict*(derelict: Derelict) : IGame =
  return (
    init:      proc() = derelict.init()
    , update:  proc(deltaTime: float) = derelict.update(deltaTime)
    , render:  proc(deltaTime: float) = derelict.render(deltaTime)
    , dispose: proc() = derelict.dispose()
  )

derelict = newGame()
let engine = newDEngine(toDerelict(derelict), false)
engine.start()

