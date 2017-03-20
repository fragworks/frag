import
  system

import
  sdl2 as sdl except EventType

import
  frag/config,
  frag/framerate/framerate,
  frag/globals,
  frag/logger,
  frag/modules/assets,
  frag/modules/event_bus as events,
  frag/modules/graphics,
  frag/modules/input,
  frag/modules/module

export
  assets,
  config,
  events,
  globals,
  graphics,
  input,
  logger,
  module

type
  Frag* = ref object
    assets*: AssetManager
    events: EventBus
    graphics*: Graphics
    input*: Input

proc shutdown(ctx: Frag, exitCode: int) =
  logInfo "Shutting down Frag..."

  logDebug "Shutting down graphics subsystem..."
  graphics.shutdown(ctx.graphics)
  logDebug "Graphics subsystem shut down."

  logDebug "Shutting down asset management subsystem..."
  assets.shutdown(ctx.assets)
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

  ctx.events = EventBus(moduleType: ModuleType.EventBus)
  if not events.init(ctx.events, config):
    logError "Error initializing events subsystem."
    ctx.shutdown(QUIT_FAILURE)

  ctx.input = Input(moduleType: ModuleType.Input)
  if not input.init(ctx.input, config):
    logError "Error initializing input subsystem."
    ctx.shutdown(QUIT_FAILURE)

  ctx.graphics = Graphics(moduleType: ModuleType.Graphics)
  if not graphics.init(ctx.graphics, config):
    logError "Error initializing graphics subsystem."
    ctx.shutdown(QUIT_FAILURE)

  ctx.assets = AssetManager(moduleType: ModuleType.Assets)
  if not assets.init(ctx.assets, config):
    logError "Error initializing assets subsystem."
    ctx.shutdown(QUIT_FAILURE)

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
    deltaTime = float64(now - last) / float64(sdl.getPerformanceFrequency())

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

    app.updateApp(ctx, deltaTime)
    app.renderApp(ctx)
    ctx.graphics.render()

    #limitFramerate()

  app.shutdownApp(ctx)

  ctx.shutdown(QUIT_SUCCESS)
