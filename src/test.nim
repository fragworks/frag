import bgfx, glm

import 
  asset
  , dEngine
  , app
  , log
  , spritebatch
  , texture

type
  Derelict = ref object of AbstractApp
    batch: SpriteBatch

var derelict : Derelict

proc init*(derelict: Derelict) =
  logInfo("Initializing derelict...")
  load("assets/textures/spritesheet.png")
 # load("assets/textures/megaman.png")

  derelict.batch = newSpriteBatch(1000, 0)
  
proc update(derelict: Derelict, deltaTime: float) =
  discard

proc render(derelict: Derelict, deltaTime: float) =
  var textureRegion = newTextureRegion(Texture(get("assets/textures/spritesheet.png")), 0, 0, 24, 24)

  #let texture = Texture(get("assets/textures/megaman.png"))

  derelict.batch.begin()
  #derelict.batch.draw(textureRegion, 100.0, 100.0, 0xffffffff'u32)
  derelict.batch.draw(Texture(get("assets/textures/spritesheet.png")), 100.0, 100.0, 24, 48, 0xffffffff'u32)
  #derelict.batch.draw(texture, 0.0, 0.0, float texture.width, float texture.height, 0xffffffff'u32, [0.2'f32, 0.2'f32 , 1.0'f32])
  derelict.batch.`end`()

proc dispose(derelict: Derelict) =
  unload("assets/textures/spritesheet.png")
  #unload("assets/textures/megaman.png")
  destroy(derelict.batch)
  

proc newGame() : Derelict =
  result = Derelict()

proc toDerelict*(derelict: Derelict) : IApp =
  return (
    init:      proc() = derelict.init()
    , update:  proc(deltaTime: float) = derelict.update(deltaTime)
    , render:  proc(deltaTime: float) = derelict.render(deltaTime)
    , dispose: proc() = derelict.dispose()
  )

derelict = newGame()
let engine = newDEngine(toDerelict(derelict), false)
engine.start()