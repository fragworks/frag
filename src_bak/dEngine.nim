import sdl2

import asset, event, framerate, game, graphics, gui, log, shader, spritebatch, texture

type
  DEngine = ref TDEngine
  TDEngine* = object
    game: IGame
    initialized*: bool

proc newDEngine*(game: IGame, dbg: bool) : DEngine =
  result = DEngine()
  result.game = game
  result.initialized = false
  debug = dbg

proc initEngine(dEngine: DEngine) : bool =
  if dEngine.initialized:
    logWarn "Engine already initialized..."
    return

  logInfo("Initializing engine...")
  
  if init(INIT_TIMER) != SdlSuccess:
    logError("Error initializing SDL : " & $getError()) 
    return false

  if not assetInit():
    return false

  let loadPNG : LoadFunc = texture.loadPNG
  let loadBMP : LoadFunc = texture.loadBMP
  let unloadTexture : UnloadFunc = texture.unloadTexture
  registerAssetLoader(loadPNG, unloadTexture, ".png")
  registerAssetLoader(loadBMP, unloadTexture, ".bmp")
  
  if not eventInit():
    return false

  if not graphicsInit():
    return false

  if not guiInit(debug):
    return false
  
  logInfo("Engine initialized.")
  return true

var now : uint64 = getPerformanceCounter()
var last : uint64 = 0
var deltaTime : float64 = 0
var testLast = 0'u32
var testNow = getTicks()
var testDelta = 0'u32

proc runEngine(dEngine: DEngine) =
  var
    evt = sdl2.defaultEvent
    runGame = true

  while runGame:
    testLast = testNow
    testNow = getTicks()
    testDelta = testNow - testLast
    last = now
    now = getPerformanceCounter()
    deltaTime = float64(((now-last)*1000 div getPerformanceFrequency()))
    while pollEvent(evt):
      if evt.kind == QuitEvent:
        runGame = false
        break
      else:
        handleEvent(evt)

    dEngine.game.update(deltaTime)

    guiUpdate(deltaTime)

    dEngine.game.render(deltaTime)

    guiRender()

    graphicsSwap()

    limitFrameRate()

proc shutdownEngine() =
  logInfo("Shutting down engine...")
  guiShutdown()
  graphicsShutdown()
  sdl2.quit()
  logInfo("Engine shutdown. Goodbye.")
  quit(QUIT_SUCCESS)

proc start*(dEngine: DEngine) =
  logInfo("Starting engine...")

  if not initEngine(dEngine):
    logFatal("Error initializing engine.")
    quit(QUIT_FAILURE)

  dEngine.game.init()

  runEngine(dEngine)

  dEngine.game.dispose()

  shutdownEngine()