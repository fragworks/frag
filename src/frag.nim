import
  sdl2 as sdl except EventType

import
  frag/assets,
  frag/assets/asset,
  frag/config,
  frag/event_bus,
  frag/events/sdl_event,
  frag/framerate/framerate,
  frag/globals,
  frag/graphics,
  frag/input,
  frag/logger

type
  Frag* = ref object
    assets*: AssetManager
    events: EventBus
    graphics*: Graphics
    input*: Input

proc shutdown(ctx: Frag, exitCode: int) =
  logInfo "Shutting down Frag..."

  logDebug "Shutting down graphics subsystem..."
  ctx.graphics.shutdown()
  logDebug "Graphics subsystem shut down."

  logDebug "Shutting down asset management subsystem..."
  ctx.assets.shutdown()
  logDebug "Asset management subsystem shut down."

  logInfo "Frag shut down. Goodbye."
  quit(exitCode)

proc registerEventHandlers(ctx: Frag) =
  ctx.events.on(EventType.LoadAsset, handleLoadAssetEvent)
  ctx.events.on(EventType.UnloadAsset, handleUnloadAssetEvent)
  ctx.events.on(EventType.GetAsset, handleGetAssetEvent)
  ctx.events.on(SDLEventType.KeyDown, handleKeyDown)
  ctx.events.on(SDLEventType.KeyUp, handleKeyUp)
  ctx.events.on(SDLEventType.WindowResize, graphics.handleWindowResizedEvent)

proc init(ctx: Frag, config: Config) =
  echo "Initializing Frag - " & globals.version & "..."

  echo "Initializing logging subsystem..."
  logger.init(config.logFileName)
  logDebug "Logging subsystem initialized."

  logDebug "Initializing events subsystem..."
  ctx.events = EventBus()
  ctx.events.init()
  logDebug "Events subsystem initialized."

  logDebug "Initializing graphics subsystem..."
  ctx.graphics = Graphics()
  if not ctx.graphics.init(
    config.rootWindowTitle,
    config.rootWindowPosX, config.rootWindowPosY,
    config.rootWindowWidth, config.rootWindowHeight,
    config.resetFlags,
    config.debugMode
  ):
    logFatal "Error initializing graphics subsystem."
    ctx.shutdown(QUIT_FAILURE)
  logDebug "Graphics subsystem initialized."

  logDebug "Initializing input subsystem..."
  ctx.input = Input()
  if not ctx.input.init():
    logFatal "Error initializing graphics subsystem."
    ctx.shutdown(QUIT_FAILURE)
  logDebug "Input subsystem initialized."

  logDebug "Initializing asset management subsystem..."
  ctx.assets = AssetManager()
  ctx.assets.init(config.assetRoot)
  logDebug "Asset management subsystem initialized."

  ctx.events.registerAssetManager(ctx.assets)

  ctx.registerEventHandlers()

  logInfo "Frag initialized."

var last = 0'u64
var deltaTime = 0'f64
var now = sdl.getPerformanceCounter()

proc startFrag*[App](config: Config) =
  var ctx = Frag()

  ctx.init(config)

  var app = App()

  app.initializeApp(ctx)

  var
    event = sdl.defaultEvent
    runGame = true

  while runGame:
     # Calculate Delta Time
    last = now
    now = sdl.getPerformanceCounter()
    deltaTime = (float64(now - last) * 1000) / float64(sdl.getPerformanceFrequency())

    ctx.input.update()

    while bool sdl.pollEvent(event):
      case event.kind
      of sdl.QuitEvent:
        runGame = false
        break
      else:
        var sdlEvent = SDLEvent(sdlEventData: event)
        if event.kind == sdl.KeyUp:
          sdlEvent.sdlEventType = SDLEventType.KeyUp
          sdlEvent.input = ctx.input
        elif event.kind == sdl.KeyDown:
          sdlEvent.sdlEventType = SDLEventType.KeyDown
          sdlEvent.input = ctx.input
        ctx.events.emit(sdlEvent)

    app.updateApp(ctx, deltaTime * 0.001)
    app.renderApp(ctx)
    ctx.graphics.swap()

    limitFramerate()

  app.shutdownApp(ctx)

  ctx.shutdown(QUIT_SUCCESS)
