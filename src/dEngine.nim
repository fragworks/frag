import
  logging

import
  sdl2 as sdl

import
  assets,
  assets/asset,
  config,
  debug,
  event_bus,
  events/event,
  events/event_handlers,
  framerate/framerate,
  globals,
  graphics

type
  dEngine* = ref object
    assets*: AssetManager
    debug*: Debug
    events: EventBus
    graphics*: Graphics

var consoleLogger : ConsoleLogger
var fileLogger : FileLogger

proc shutdown(ctx: dEngine, exitCode: int) =
  info "Shutting down dEngine..."
  
  debug "Shutting down graphics subsystem..."
  ctx.graphics.shutdown()
  debug "Graphics subsystem shutdown."
  
  debug "Shutting down asset management subsystem..."
  ctx.assets.shutdown()
  debug "Asset management subsystem shutdown."

  info "dEngine shut down. Goodbye."
  quit(exitCode)

proc registerEventHandlers(ctx: dEngine) = 
  ctx.events.registerEventHandler(handleLoadAssetEvent, LOAD_ASSET)

proc init(ctx: dEngine, config: dEngineConfig) =
  echo "Initializing dEngine - " & globals.version & "..."

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

  debug "Initializing debug subsystem..."
  ctx.debug = Debug()
  ctx.debug.init(ctx.events)
  debug "Debug subsystem initialized."

  info "dEngine initialized."

var last = 0'u64
var deltaTime = 0'f64
var now = sdl.getPerformanceCounter()

proc startdEngine*[App](config: dEngineConfig) =
  var ctx = dEngine()

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
        ctx.events.dispatch(event)

    app.render(ctx)

    ctx.graphics.swap()

    limitFramerate()
  
  app.shutdown(ctx)
  
  ctx.shutdown(QUIT_SUCCESS)
