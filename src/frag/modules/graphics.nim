import
  events,
  strfmt

import
  bgfxdotnim as bgfx,
  bgfxdotnim.platform,
  sdl2 as sdl

import
  ../config,
  ../events/sdl_event,
  ../graphics/color,
  ../graphics/sdl2/version,
  ../graphics/types,
  ../graphics/window,
  ../logger,
  module

type
  Graphics* = ref object of Module
    rootWindow*: window.Window
    rootGLContext: sdl.GLContextPtr

when defined(macosx):
  type
    SysWMinfoCocoaObj = object
      window: pointer ## The Cocoa window

    SysWMinfoKindObj = object
      cocoa: SysWMinfoCocoaObj

when defined(linux):
  import x, xlib
  type
    SysWMmsgX11Obj* = object  ## when defined(SDL_VIDEO_DRIVER_X11)
      display*: ptr xlib.TXDisplay  ##  The X11 display
      window*: ptr x.TWindow            ##  The X11 window
    SysWMinfoKindObj* = object ## when defined(SDL_VIDEO_DRIVER_X11)
      x11*: SysWMMsgX11Obj

var lastTime {.global.} : uint64

proc linkSDL2BGFX(window: sdl.WindowPtr): bool =
    var pd: ptr bgfx_platform_data_t = create(bgfx_platform_data_t)
    var info: sdl.WMinfo
    version(info.version)
    assert sdl.getWMInfo(window, info)

    case(info.subsystem):
        of SysWM_Windows:
          when defined(windows):
            pd.nwh = cast[pointer](info.info.win.window)
          pd.ndt = nil
        of SysWM_X11:
          when defined(linux):
            let info = cast[ptr SysWMinfoKindObj](addr info.padding[0])
            pd.nwh = info.x11.window
            pd.ndt = info.x11.display
        of SysWM_Cocoa:
          when defined(macosx):
            let info = cast[ptr SysWMinfoKindObj](addr info.padding[0])
            pd.nwh = info.cocoa.window
          pd.ndt = nil
        else:
          logError "Error linking SDL2 and BGFX."
          return false

    pd.backBuffer = nil
    pd.backBufferDS = nil
    pd.context = nil
    bgfx_set_platform_data(pd)
    return true

method init*(this: Graphics, config: Config): bool =
  var rootWindowPosX = config.rootWindowPosX
  var rootWindowPosY = config.rootWindowPosY
  var rootWindowWidth = config.rootWindowWidth
  var rootWindowHeight = config.rootWindowHeight
  var resetFlags = config.resetFlags
  var debugMode = config.debugMode

  if sdl.init(INIT_VIDEO) != SdlSuccess:
    logError "Error initializing SDL : " & $getError()
    return false

  this.rootWindow = Window()
  this.rootWindow.init(
    config.rootWindowTitle,
    rootWindowPosX, rootWindowPosY,
    rootWindowWidth, rootWindowHeight,
    window.WindowFlag.WindowShown.ord or window.WindowFlag.WindowResizable.ord
  )

  if this.rootWindow.handle.isNil:
    logError "Error creating root application window."
    return false

  if not linkSDL2BGFX(this.rootWindow.handle):
    return false

  if not bgfx_init(BGFX_RENDERER_TYPE_NOOP, 0'u16, 0, nil, nil):
    logError("Error initializng BGFX.")

  bgfx_reset(rootWindowWidth.uint32, rootWindowHeight.uint32, uint32 resetFlags)

  bgfx_set_view_rect(0, 0, 0, rootWindowWidth.uint16, rootWindowHeight.uint16)

  if not(debugMode == DebugMode.None):
    bgfx_set_debug(uint32 debugMode)

  return true

proc clearView*(this: Graphics, viewId: uint8, flags: uint16, rgba: uint32, depth: float32, stencil: uint8) =
  bgfx_set_view_clear(viewID, flags, rgba, depth, stencil)

method render*(this: Graphics) =
  let current = sdl.getPerformanceCounter()
  let frameTime = float((current - lastTime) * 1000) / float sdl.getPerformanceFrequency()
  lastTime = current

  discard bgfx_touch(0)

  bgfx_dbg_text_clear(0, false)
  bgfx_dbg_text_printf(1, 1, 0x0f, "Frame: %7.3f[ms] FPS: %7.3f", float32(frameTime), (1.0 / frameTime) * 1000)

  discard bgfx_frame(false)

proc handleWindowResizedEvent*(e: EventArgs) {.procvar.} =
  let
    sdlEvent = SDLEventMessage(e).event
    width = uint16 sdlEvent.sdlEventData.window.data1
    height = uint16 sdlEvent.sdlEventData.window.data2

  bgfx_reset(width, height, ResetFlag.None.ord)
  bgfx_set_view_rect(0, 0, 0, width , height )

method shutdown*(this: Graphics) =
  if this.rootWindow.isNil:
    return
  elif this.rootWindow.handle.isNil:
    logDebug "Shutting down SDL..."
    sdl.quit()
    logDebug "SDL shut down."
  else:
    logDebug "Shutting down BGFX..."
    bgfx_shutdown()
    logDebug "BGFX shut down."

    logDebug "Destroying root window and shutting down SDL..."
    sdl.destroyWindow(this.rootWindow.handle)
    sdl.quit()
    logDebug "SDL shut down."
