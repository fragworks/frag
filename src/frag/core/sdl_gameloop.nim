import
  bgfxdotnim
  
import
  sdl2 as sdl except EventType

import
  ../types,
  ../config,
  ../framerate/framerate,
  ../globals,
  ../logger,
  ../modules/assets,
  ../modules/event_bus as events,
  ../modules/graphics,
  ../modules/gui,
  ../modules/input,
  ../modules/module

export
  assets,
  bgfxdotnim,
  config,
  events,
  globals,
  graphics,
  gui,
  input,
  logger,
  module,
  sdl

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

  ctx.events.on(SDLEventType.AppDidEnterForeground, handleAppDidEnterForegroundEvent)

proc shutdownFRAG*(ctx: Frag, exitCode: int, shutdownIMGUI: bool) =
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

proc initFRAG*[App](ctx: Frag, app: App, config: Config) =
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
    ctx.shutdownFRAG(QUIT_FAILURE, config.imgui)
  log "Events subsystem initialized."

  log "Initializing input subsystem..."
  ctx.input = Input(moduleType: ModuleType.Input)
  if not input.init(ctx.input):
    logError "Error initializing input subsystem."
    ctx.shutdownFRAG(QUIT_FAILURE, config.imgui)
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
    ctx.shutdownFRAG(QUIT_FAILURE, config.imgui)
  log "Graphics subsystem initialized."

  log "Initializing asset management subsystem..."
  ctx.assets = AssetManager(moduleType: ModuleType.Assets)
  if not assets.init(ctx.assets, config):
    logError "Error initializing assets subsystem."
    ctx.shutdownFRAG(QUIT_FAILURE, config.imgui)
  log "Asset management subsystem initialized."

  ctx.events.registerAssetManager(ctx.assets)

  if config.imgui:
    log "Initializing IMGUI subsystem..."
    ctx.gui = GUI(moduleType: ModuleType.GUI)
    if not gui.init(ctx.gui, config.imguiViewId):
      logError "Error initializing IMGUI subsystem."
      ctx.shutdownFRAG(QUIT_FAILURE, config.imgui)
    log "IMGUI susbsystem initialized."

  ctx.registerEventHandlers()

  logInfo "Frag initialized."

proc start*[T](ctx: Frag, app: T, config: Config) =
  var now = sdl.getPerformanceCounter()

  var
    event = sdl.defaultEvent
    runGame = true
    last = 0'u64
    deltaTime = 0'f64

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
        elif event.kind == sdl.AppDidEnterForeground:
          sdlEvent.sdlEventType = SDLEventType.AppDidEnterForeground
          sdlEvent.graphics = ctx.graphics
          sdlEvent.gui = ctx.gui
          sdlEvent.userData = cast[pointer](app)
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