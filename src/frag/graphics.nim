import
  events,
  logging,
  strfmt

import
  bgfxdotnim as bgfx,
  bgfxdotnim.platform,
  sdl2 as sdl

import
  event_bus,
  graphics/color,
  graphics/sdl2/version,
  graphics/window

type
  Graphics* = ref object
    rootWindow*: window.Window
    rootGLContext: sdl.GLContextPtr

when defined(macosx):
  type
    SysWMinfoCocoaObj = object
      window: pointer ## The Cocoa window

    SysWMinfoKindObj = object
      cocoa: SysWMinfoCocoaObj

when defined(linux):
  import 
    x, 
    xlib

  type
    SysWMmsgX11Obj* = object  ## when defined(SDL_VIDEO_DRIVER_X11)
      display*: ptr xlib.TXDisplay  ##  The X11 display
      window*: ptr x.TWindow            ##  The X11 window


    SysWMinfoKindObj* = object ## when defined(SDL_VIDEO_DRIVER_X11)
      x11*: SysWMMsgX11Obj

type
  ResetFlag* {.pure.} = enum
    None = BGFX_RESET_NONE
    Fullscreen = BGFX_RESET_FULLSCREEN
    MSAAx2 = BGFX_RESET_MSAA_X2
    MSAAx4 = BGFX_RESET_MSAA_X4
    MSAAx8 = BGFX_RESET_MSAA_X8
    MSAAx16 = BGFX_RESET_MSAA_X16
    VSync = BGFX_RESET_VSYNC
    MaxAnisotropy = BGFX_RESET_MAXANISOTROPY
    Capture = BGFX_RESET_CAPTURE
    HMD = BGFX_RESET_HMD
    DEUBG = BGFX_RESET_HMD_DEBUG
    HMDRecenter = BGFX_RESET_HMD_RECENTER
    FlushAfterRender = BGFX_RESET_FLUSH_AFTER_RENDER
    FlipAfterRender = BGFX_RESET_FLIP_AFTER_RENDER
    sRGBBackbuffer = BGFX_RESET_SRGB_BACKBUFFER

  DebugMode* {.pure.} = enum
    None = 0u32
    Wireframe = BGFX_DEBUG_WIREFRAME
    IFH = BGFX_DEBUG_IFH
    Stats = BGFX_DEBUG_STATS
    Text = BGFX_DEBUG_TEXT

  ClearMode* {.pure.} = enum
    Color = BGFX_CLEAR_COLOR
    Depth = BGFX_CLEAR_DEPTH

  BlendFunc* {.pure.} = enum
    SrcAlpha = BGFX_STATE_BLEND_SRC_ALPHA
    InvSrcAlpha = BGFX_STATE_BLEND_INV_SRC_ALPHA

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
          error "Error linking SDL2 and BGFX."
          return false

    pd.backBuffer = nil
    pd.backBufferDS = nil
    pd.context = nil
    bgfx_set_platform_data(pd)
    return true

proc init*(
  graphics: Graphics,
  rootWindowTitle: string = nil,
  rootWindowPosX, rootWindowPosY: int = window.posUndefined,
  rootWindowWidth = 960, rootWindowHeight = 540,
  resetFlags: ResetFlag = ResetFlag.None,
  debugMode: DebugMode = DebugMode.None
): bool =
  if sdl.init(INIT_VIDEO) != SdlSuccess:
    error "Error initializing SDL : " & $getError()
    return false

  graphics.rootWindow = Window()
  graphics.rootWindow.init(
    rootWindowTitle,
    rootWindowPosX, rootWindowPosY,
    rootWindowWidth, rootWindowHeight,
    window.WindowFlag.WindowShown.ord or window.WindowFlag.WindowResizable.ord
  )

  if graphics.rootWindow.handle.isNil:
    error "Error creating root application window."
    return false

  if not linkSDL2BGFX(graphics.rootWindow.handle):
    return false

  if not bgfx_init(BGFX_RENDERER_TYPE_NOOP, 0'u16, 0, nil, nil):
    error("Error initializng BGFX.")

  bgfx_reset(rootWindowWidth.uint32, rootWindowHeight.uint32, uint32 resetFlags)

  bgfx_set_view_rect(0, 0, 0, rootWindowWidth.uint16, rootWindowHeight.uint16)

  if not(debugMode == DebugMode.None):
    bgfx_set_debug(uint32 debugMode)

  return true

proc clearView*(graphics: Graphics, viewId: uint8, flags: uint16, rgba: uint32, depth: float32, stencil: uint8) =
  bgfx_set_view_clear(viewID, flags, rgba, depth, stencil)

proc swap*(graphics: Graphics) =
  let current = sdl.getPerformanceCounter()
  let frameTime = float((current - lastTime) * 1000) / float sdl.getPerformanceFrequency()
  lastTime = current

  discard bgfx_touch(0)

  bgfx_dbg_text_clear(0, false)
  bgfx_dbg_text_printf(1, 1, 0x0f, "Frame: %7.3f[ms] FPS: %7.3f", float32(frameTime), (1.0 / frameTime) * 1000)

  discard bgfx_frame(false)

proc handleWindowResizedEvent*(e: EventArgs) {.procvar.} =
  let 
    eventMessage = SDLEventMessage(e)
    width = uint16 eventMessage.event.window.data1 
    height = uint16 eventMessage.event.window.data2

  bgfx_reset(width, height, ResetFlag.None.ord)
  bgfx_set_view_rect(0, 0, 0, width , height )


proc shutdown*(graphics: Graphics, events: EventBus) =
  if graphics.rootWindow.isNil:
    return
  elif graphics.rootWindow.handle.isNil:
    debug "Shutting down SDL..."
    sdl.quit()
    debug "SDL shut down."
  else:
    debug "Shutting down BGFX..."
    bgfx_shutdown()
    debug "BGFX shut down."

    debug "Destroying root window and shutting down SDL..."
    sdl.destroyWindow(graphics.rootWindow.handle)
    sdl.quit()
    debug "SDL shut down."
