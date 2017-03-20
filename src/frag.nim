import
  sdl2 as sdl except EventType

import
  frag/config,
  frag/framerate/framerate,
  frag/globals,
  frag/logger,
  frag/modules/assets,
  frag/modules/event_bus,
  frag/modules/graphics,
  frag/modules/input,
  frag/modules/module

export
  assets,
  config,
  event_bus,
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
    modules*: seq[Module]

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

proc addModule(ctx: Frag, module: Module, name: string = ""): void =
  logDebug "Adding $1 subsystem..." % name
  if name != "": module.name = name
  ctx.modules.add(module)

proc init(ctx: Frag, config: Config) =
  echo "Initializing Frag - " & globals.version & "..."

  ctx.modules = @[]

  echo "Initializing logging subsystem..."
  logger.init(config.logFileName)
  logDebug "Logging subsystem initialized."

  ctx.events = EventBus()
  ctx.addModule(ctx.events, "events")

  ctx.input = Input()
  ctx.addModule(ctx.input, "input")

  ctx.graphics = Graphics()
  ctx.addModule(ctx.graphics, "graphics")

  ctx.assets = AssetManager()
  ctx.addModule(ctx.assets, "assets")
  ctx.events.registerAssetManager(ctx.assets)

  for module in ctx.modules:
    logDebug "Initializing $1 subsystem..." % module.name
    if not module.init(config):
      logFatal "Error initializing $1 subsystem." % module.name
      ctx.shutdown(QUIT_FAILURE)
    logDebug "Initialized $1 subsystem." % module.name

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
    ctx.graphics.render()

    limitFramerate()

  app.shutdownApp(ctx)

  ctx.shutdown(QUIT_SUCCESS)
