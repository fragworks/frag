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
  frag/modules/gui,
  frag/modules/input,
  frag/modules/module

type
  Frag* = ref object
    assets*: AssetManager
    events*: EventBus
    graphics*: Graphics
    gui*: GUI
    input*: Input

export
  assets,
  config,
  events,
  globals,
  graphics,
  gui,
  input,
  logger,
  module

proc registerEventHandlers(ctx: Frag) =
  ctx.events.on(EventType.LoadAsset, handleLoadAssetEvent)
  ctx.events.on(EventType.UnloadAsset, handleUnloadAssetEvent)
  ctx.events.on(EventType.GetAsset, handleGetAssetEvent)
  
  ctx.events.on(SDLEventType.KeyDown, handleKeyDown)
  ctx.events.on(SDLEventType.KeyUp, handleKeyUp)

  ctx.events.on(SDLEventType.MouseButtonDown, handleMouseButtonDown)
  ctx.events.on(SDLEventType.MouseButtonUp, handleMouseButtonUp)

  ctx.events.on(SDLEventType.MouseMotion, handleMouseMotionEvent)
  
  ctx.events.on(SDLEventType.WindowResize, handleWindowResizeEvent)

proc shutdown(ctx: Frag, exitCode: int, shutdownIMGUI: bool) =
  logInfo "Shutting down Frag..."

  if shutdownIMGUI:
    logDebug "Shutting down IMGUI subsystem..."
    gui.shutdown(ctx.gui)
    logDebug "IMGUI subsystem shut down."

  logDebug "Shutting down asset management subsystem..."
  assets.shutdown(ctx.assets)
  logDebug "Asset management subsystem shut down."

  logDebug "Shutting down graphics subsystem..."
  graphics.shutdown(ctx.graphics)
  logDebug "Graphics subsystem shut down."

  logInfo "Frag shut down. Goodbye."
  quit(exitCode)

proc init[App](ctx: Frag, config: Config, app: App) =
  if not defined(android):
    echo "Initializing Frag - " & globals.version & "..."
    
    echo "Initializing logging subsystem..."
    logger.init(config.logFileName)
    log "Logging subsystem initialized."
  
  else:
    logInfo "Initializing Frag - " & globals.version & "..."

  log "Initializing events subsystem..."
  ctx.events = EventBus(moduleType: ModuleType.EventBus)
  if not events.init(ctx.events):
    logError "Error initializing events subsystem."
    ctx.shutdown(QUIT_FAILURE, config.imgui)
  log "Events subsystem initialized."

  log "Initializing input subsystem..."
  ctx.input = Input(moduleType: ModuleType.Input)
  if not input.init(ctx.input):
    logError "Error initializing input subsystem."
    ctx.shutdown(QUIT_FAILURE, config.imgui)
  log "Input subsystem initialized."

  log "Initializing graphics subsystem..."
  ctx.graphics = Graphics(moduleType: ModuleType.Graphics)
  if not graphics.init(ctx.graphics,
    config.rootWindowTitle,
    config.rootWindowPosX, config.rootWindowPosY,
    config.rootWindowWidth, config.rootWindowHeight,
    config.resetFlags,
    config.debugMode
  ):
    logError "Error initializing graphics subsystem."
    ctx.shutdown(QUIT_FAILURE, config.imgui)
  log "Graphics subsystem initialized."

  when not defined(android): # This breaks android and prevents app from starting
    log "Initializing asset management subsystem..."
    ctx.assets = AssetManager(moduleType: ModuleType.Assets)
    if not assets.init(ctx.assets, config):
      logError "Error initializing assets subsystem."
      ctx.shutdown(QUIT_FAILURE, config.imgui)
    log "Asset management subsystem initialized."

  ctx.events.registerAssetManager(ctx.assets)

  if config.imgui:
    log "Initializing IMGUI subsystem..."
    ctx.gui = GUI(moduleType: ModuleType.GUI)
    if not gui.init(ctx.gui, config.imguiViewId):
      logError "Error initializing IMGUI subsystem."
      ctx.shutdown(QUIT_FAILURE, config.imgui)
    log "IMGUI susbsystem initialized."

  ctx.registerEventHandlers()

  logInfo "Frag initialized."

var last = 0'u64
var deltaTime = 0'f64
var now = sdl.getPerformanceCounter()

proc startFrag*[T](app: T, config: Config) =
  var ctx = Frag()

  ctx.init(config, app)

  app.initApp(ctx)

  var
    event = sdl.defaultEvent
    runGame = true

  while runGame:
     # Calculate Delta Time
    last = now
    now = sdl.getPerformanceCounter()
    deltaTime = float64(now - last) / float64(sdl.getPerformanceFrequency())

    input.update(ctx.input)

    if config.imgui:
      gui.startUpdate(ctx.gui)
    while bool sdl.pollEvent(event):
      case event.kind
      of sdl.QuitEvent:
        runGame = false
        break
      else:
        #TODO: FIX THIS - Do something with it, anything...
        var sdlEvent = SDLEvent(sdlEventData: event)
        if event.kind == sdl.KeyUp:
          sdlEvent.sdlEventType = SDLEventType.KeyUp
          sdlEvent.input = ctx.input
          sdlEvent.gui = ctx.gui
        elif event.kind == sdl.KeyDown:
          sdlEvent.sdlEventType = SDLEventType.KeyDown
          sdlEvent.input = ctx.input
          sdlEvent.gui = ctx.gui
        elif event.kind == sdl.MouseButtonDown:
          sdlEvent.sdlEventType = SDLEventType.MouseButtonDown
          sdlEvent.input = ctx.input
          sdlEvent.gui = ctx.gui
        elif event.kind == sdl.MouseButtonUp:
          sdlEvent.sdlEventType = SDLEventType.MouseButtonUp
          sdlEvent.input = ctx.input
          sdlEvent.gui = ctx.gui
        elif event.kind == sdl.MouseMotion:
          sdlEvent.sdlEventType = SDLEventType.MouseMotion
          sdlEvent.input = ctx.input
          sdlEvent.gui = ctx.gui
        elif event.kind == sdl.WindowEvent:
          case event.window.event
          of WINDOWEVENT_RESIZED:
            sdlEvent.sdlEventType = SDLEventType.WindowResize
            sdlEvent.graphics = ctx.graphics
            sdlEvent.gui = ctx.gui
            sdlEvent.userData = cast[pointer](app)
          else:
            discard
        ctx.events.emit(sdlEvent)
    
    if config.imgui:
      gui.finishUpdate(ctx.gui)

    ctx.graphics.startFrame()
    app.updateApp(ctx, deltaTime)
    app.renderApp(ctx, deltaTime)
    graphics.render(ctx.graphics)

    if config.imgui:
      gui.render(ctx.gui)

    limitFramerate()

  app.shutdownApp(ctx)

  ctx.shutdown(QUIT_SUCCESS, config.imgui)