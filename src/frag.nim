import
  logging

import
  sdl2 as sdl

import
  frag/assets,
  frag/assets/asset,
  frag/config,
  frag/event_bus,
  frag/framerate/framerate,
  frag/globals,
  frag/graphics

type
  Frag* = ref object
    assets*: AssetManager
    events: EventBus
    graphics*: Graphics

var consoleLogger : ConsoleLogger
var fileLogger : FileLogger

proc shutdown(ctx: Frag, exitCode: int) =
  info "Shutting down Frag..."

  debug "Shutting down graphics subsystem..."
  ctx.graphics.shutdown(ctx.events)
  debug "Graphics subsystem shut down."

  debug "Shutting down asset management subsystem..."
  ctx.assets.shutdown()
  debug "Asset management subsystem shut down."

  info "Frag shut down. Goodbye."
  quit(exitCode)

proc registerEventHandlers(ctx: Frag) =
  ctx.events.on(handleLoadAssetEvent, FragEventType.LoadAsset)
  ctx.events.on(handleUnloadAssetEvent, FragEventType.UnloadAsset)
  ctx.events.on(handleGetAssetEvent, FragEventType.GetAsset)

proc init(ctx: Frag, config: FragConfig) =
  echo "Initializing Frag - " & globals.version & "..."

  echo "Initializing logging subsystem..."

  consoleLogger = newConsoleLogger()
  fileLogger = newFileLogger(config.logFileName)

  logging.addHandler(consoleLogger)
  logging.addHandler(fileLogger)

  debug "Logging subsystem initialized."

  debug "Initializing events subsystem..."
  ctx.events = EventBus()
  ctx.events.init()
  debug "Events subsystem initialized."

  debug "Initializing graphics subsystem..."
  ctx.graphics = Graphics()
  if not ctx.graphics.init(
    config.rootWindowTitle,
    config.rootWindowPosX, config.rootWindowPosY,
    config.rootWindowWidth, config.rootWindowHeight,
    uint32 config.rootWindowFlags
  ):
    fatal "Error initializing graphics subsystem."
    ctx.shutdown(QUIT_FAILURE)
  debug "Graphics subsystem initialized."

  debug "Initializing asset management subsystem..."
  ctx.assets = AssetManager()
  ctx.assets.init(config.assetRoot)
  debug "Asset management subsystem initialized."

  ctx.events.registerAssetManager(ctx.assets)

  ctx.registerEventHandlers()

  ctx.graphics.initializeDebug(ctx.events, config.rootWindowWidth, config.rootWindowHeight)

  info "Frag initialized."

var last = 0'u64
var deltaTime = 0'f64
var now = sdl.getPerformanceCounter()

proc startFrag*[App](config: FragConfig) =
  var ctx = Frag()

  ctx.init(config)

  var app = App()

  app.initialize(ctx)

  var
    event = sdl.defaultEvent
    runGame = true

  while runGame:
     # Calculate Delta Time
    last = now
    now = sdl.getPerformanceCounter()
    deltaTime = float64((now - last) * 1000 div sdl.getPerformanceFrequency())

    while bool sdl.pollEvent(event):
      case event.kind
      of sdl.QuitEvent:
        runGame = false
        break
      else:
        var event = SDLEvent(sdlEventData:event)
        ctx.events.emit(event)

    app.render(ctx)

    ctx.graphics.swap()

    limitFramerate()

  app.shutdown(ctx)

  ctx.shutdown(QUIT_SUCCESS)
