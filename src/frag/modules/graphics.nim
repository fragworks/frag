import 
  colors,
  module,
  ../logger

when defined(js):
  import
    dom,
    ../graphics/colorsext,
    strutils,
    webgl

  proc init*(self: Graphics, canvasWidth = 960, canvasHeight = 540): bool =
    var canvas = dom.document.getElementById("glcanvas").Canvas;
    canvas.width = canvasWidth
    canvas.height = canvasHeight
    self.gl = canvas.getContext("webgl")
    if self.gl.isNil: self.gl = canvas.getContext("experimental-webgl")
    return true

  proc getGL*(): WebGLRenderingContext =
    var canvas = dom.document.getElementById("glcanvas").Canvas;
    result = canvas.getContext("webgl")
    if result.isNil: result = canvas.getContext("experimental-webgl")

else:
  import
    events,
    strfmt

  import
    bgfxdotnim as bgfx,
    bgfxdotnim.platform,
    sdl2 as sdl

  import
    ../events/sdl_event,
    ../graphics/sdl2/version,
    ../graphics/types,
    ../graphics/window,
    ../util

  export
    types,
    window

  when defined(windows) and not defined(android):
    type
      SysWMMsgWinObj* = object  ##  when defined(SDL_VIDEO_DRIVER_WINDOWS)
        hwnd*: pointer

      SysWMinfoKindObj* = object ##  when defined(SDL_VIDEO_DRIVER_WINDOWS)
        win*: SysWMMsgWinObj

  when defined(macosx) and not defined(android):
    type
      SysWMinfoCocoaObj = object
        window: pointer

      SysWMinfoKindObj = object
        cocoa: SysWMinfoCocoaObj

  when defined(linux) and not defined(android):
    import x, xlib
    type
      SysWMmsgX11Obj* = object
        display*: ptr xlib.TXDisplay
        window*: ptr x.TWindow
      SysWMinfoKindObj* = object
        x11*: SysWMMsgX11Obj

  when defined(android):
    import
      android.ndk.anative_window

    type
      SysWMinfoAndroidObj* = object
        window*: ANativeWindow
        surface*: pointer

      SysWMinfoKindObj* = object
        android*: SysWMinfoAndroidObj

  proc linkSDL2BGFX(window: sdl.WindowPtr): bool =
      var pd: ptr bgfx_platform_data_t = workaround_createShared[bgfx_platform_data_t]()
      var info: sdl.WMinfo
      version(info.version)

      when defined(android):
        pd.nwh = getNativeAndroidWindow()
      else:
        discard sdl.getWMInfo(window, info)
        
        case(info.subsystem):
            of SysWM_Windows:
              when defined(windows) and not defined(android):
                let info = cast[ptr SysWMinfoKindObj](addr info.padding[0])
                pd.nwh = info.win.hwnd
              pd.ndt = nil
            of SysWM_X11:
              when defined(linux) and not defined(android):
                let info = cast[ptr SysWMinfoKindObj](addr info.padding[0])
                pd.nwh = info.x11.window
                pd.ndt = info.x11.display
            of SysWM_Cocoa:
              when defined(macosx) and not defined(android):
                let info = cast[ptr SysWMinfoKindObj](addr info.padding[0])
                pd.nwh = info.cocoa.window
              pd.ndt = nil
            #of SysWM_Android:
              #when defined(android):
                #let info = cast[ptr SysWMinfoKindObj](addr info.padding[0])
                #pd.nwh = info.android.window
                #pd.nwh = getNativeAndroidWindow()
              #pd.ndt = nil
            else:
              logError "Error linking SDL2 and BGFX."
              return false

      pd.backBuffer = nil
      pd.backBufferDS = nil
      pd.context = nil
      bgfx_set_platform_data(pd)
      freeShared(pd)
      return true

  proc init*(
    self: Graphics,
    rootWindowTitle: string,
    rootWindowPosX = window.posUndefined, rootWindowPosY = window.posUndefined,
    rootWindowWidth = 960, rootWindowHeight = 540,
    resetFlags: ResetFlag = ResetFlag.None,
    debugMode: uint32 = BGFX_DEBUG_NONE
  ): bool =
    if sdl.init(INIT_VIDEO) != SdlSuccess:
      logError "Error initializing SDL : " & $getError()
      return false

    self.rootWindow = Window()

    when defined(android):
      self.rootWindow.init(
        rootWindowTitle,
        rootWindowPosX, rootWindowPosY,
        rootWindowWidth, rootWindowHeight,
        window.WindowFlag.WindowShown.ord or window.WindowFlag.WindowFullscreen.ord
      )

    else:
      self.rootWindow.init(
        rootWindowTitle,
        rootWindowPosX, rootWindowPosY,
        rootWindowWidth, rootWindowHeight,
        window.WindowFlag.WindowShown.ord or window.WindowFlag.WindowResizable.ord
      )

    if self.rootWindow.handle.isNil:
      logError "Error creating root application window."
      return false

    if not linkSDL2BGFX(self.rootWindow.handle):
      return false

    if not bgfx_init(BGFX_RENDERER_TYPE_COUNT, 0'u16, 0, nil, nil):
      logError("Error initializng BGFX.")

    let size = sdl.getSize(self.rootWindow.handle)
    bgfx_reset(size.x.uint32, size.y.uint32, BGFX_RESET_VSYNC)
    bgfx_set_view_rect(0, 0, 0, size.x.uint16, size.y.uint16)

    bgfx_set_debug(debugMode)

    return true

  proc drawDebugImage*(self: Graphics, image: var openarray[uint8], x, y, width, height, pitch: uint16) =
    bgfx_dbg_text_image(
      x, 
      y,
      width,
      height,
      image.addr,
      pitch
    )

  proc startFrame*(self: Graphics) =
    bgfx_dbg_text_clear(0, false)

  proc render*(self: Graphics) =
    var lastTime {.global.} : uint64
    let current = sdl.getPerformanceCounter()
    let frameTime = float((current - lastTime) * 1000) / float sdl.getPerformanceFrequency()
    lastTime = current

    discard bgfx_touch(0)

    bgfx_dbg_text_printf(1, 1, 0x0f, "Frame: %7.3f[ms] FPS: %7.3f", float32(frameTime), (1.0 / frameTime) * 1000)

    discard bgfx_frame(false)

  proc onWindowResize*(self: Graphics, event: sdl.Event) {.procvar.} =
    let
      width = uint16 event.window.data1
      height = uint16 event.window.data2

    when defined(android):
      discard linkSDL2BGFX(self.rootWindow.handle)
      
    bgfx_reset(width, height, BGFX_RESET_VSYNC)

  proc onUnpause*(self: Graphics, event: sdl.Event) {.procvar.} =
    when defined(android):
      discard linkSDL2BGFX(self.rootWindow.handle)
      let size = getSize(self.rootWindow.handle)
      bgfx_reset(size.x.uint32, size.y.uint32, BGFX_RESET_VSYNC)

  proc getSize*(self: Graphics): tuple =
    sdl.getSize(self.rootWindow.handle)

  proc setViewRect*(self: Graphics, viewId: uint8, x, y, width, height: uint16) =
    bgfx_set_view_rect(viewId, x, y, width, height)

  proc shutdown*(self: Graphics) =
    if self.rootWindow.isNil:
      return
    elif self.rootWindow.handle.isNil:
      logDebug "Shutting down SDL..."
      sdl.quit()
      logDebug "SDL shut down."
    else:
      logDebug "Shutting down BGFX..."
      bgfx_shutdown()
      logDebug "BGFX shut down."

      logDebug "Destroying root window and shutting down SDL..."
      sdl.destroyWindow(self.rootWindow.handle)
      sdl.quit()
      logDebug "SDL shut down."

proc clearView*(self: Graphics, viewId: uint8, flags: uint16, rgba: colors.Color, depth: float32, stencil: uint8) =
  when defined(js):
    let components = toFloats(extractRGBA(rgba))
    self.gl.clearColor(components.r, components.g, components.b, components.a)
    self.gl.clear(bbCOLOR.uint or bbDEPTH.uint)
  else:
    bgfx_set_view_clear(viewID, flags, rgba.uint32, depth, stencil)