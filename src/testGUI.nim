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
  , modelbatch
  , spritebatch
  , texture

type
  Derelict = ref object of AbstractGame
    batch: SpriteBatch
    #batch: ModelBatch
    deltaTime: float

var label : Label

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
  discard

proc init*(derelict: Derelict) =
  logInfo("Initializing derelict...")
  derelict.batch = newSpriteBatch(1000, nil)
  #derelict.batch = newModelBatch(nil)
  #load("assets/textures/test.png")
  load("assets/textures/megaman.png")
  #discard loadModel("assets/models/cube.obj")

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

  let label2 = newLabel(
    "Label:"
    , "orbitron"
    , false
    , nvgRGBA(255, 255, 255, 255)
    , vec2f(0, 0)
    , 12.0
  )

  let label3 = newLabel(
    "Label2:"
    , "orbitron"
    , false
    , nvgRGBA(255, 255, 255, 255)
    , vec2f(0, 0)
    , 12.0
  )

  let label4 = newLabel(
    "Label3:"
    , "orbitron"
    , false
    , nvgRGBA(255, 255, 255, 255)
    , vec2f(0, 0)
    , 12.0
  )

  let label5 = newLabel(
    "Label4:"
    , "orbitron"
    , false
    , nvgRGBA(255, 255, 255, 255)
    , vec2f(0, 0)
    , 12.0
  )

  let label6 = newLabel(
    "Label5:"
    , "orbitron"
    , false
    , nvgRGBA(255, 255, 255, 255)
    , vec2f(0, 0)
    , 12.0
  )

  let panel = newPanel("example panel", vec2f(450 ,20), vec2f(250, 250), newBoxLayout(
    Vertical
    , Minimum
    , 5.0
    , 60.0
  ))

  let panel2 = newPanel("example panel 2", vec2f(100 ,100), vec2f(300, 300), newBoxLayout(
    Vertical
    , Minimum
    , 5.0
    , 5.0
  ))

  panel.addChild(label2)
  panel.addChild(label3)
  panel.addChild(label4)
  panel.addChild(label5)
  panel.addChild(label6)

  registerWidgets(Widget panel, Widget panel2)
  registerWidget(label)

  registerEventListener(gameWindowResized, @[WindowEvent])
  registerEventListener(listenForInputEvent, @[KeyDown, KeyUp])

  layoutGUI()

  originalWidth = getWidth()
  originalHeight = getHeight()
  
proc update(derelict: Derelict, deltaTime: float) =
  derelict.deltaTime = deltaTime

proc render(derelict: Derelict) =
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

  #let texture = Texture get("assets/textures/test.png")
  let texture = Texture get("assets/textures/megaman.png")
  #texture.setFilter(GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR)
  derelict.batch.begin()
  derelict.batch.draw(texture, 0, 0, float texture.data.w, float texture.data.h)
  #derelict.batch.draw(newTextureRegion(texture, 0, 0, 1024, 1024), 20, 20)
  #derelict.batch.draw()
  derelict.batch.`end`()

proc dispose(derelict: Derelict) =
  discard
  #unload("assets/textures/test.png")
  unload("assets/textures/megaman.png")
  

proc newGame() : Derelict =
  result = Derelict()

proc toDerelict*(derelict: Derelict) : IGame =
  return (
    init:      proc() = derelict.init()
    , update:  proc(deltaTime: float) = derelict.update(deltaTime)
    , render:  proc(deltaTime: float) = derelict.render()
    , dispose: proc() = derelict.dispose()
  )

derelict = newGame()
let engine = newDEngine(toDerelict(derelict), false)
engine.start()

