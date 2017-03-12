import
  sdl2 as sdl

import
  ../globals

type
  Window* = ref object
    handle*: sdl.WindowPtr

type
  WindowFlags* = enum
    WindowFullscreen = sdl.SDL_WINDOW_FULLSCREEN # Start window in fullscreen mode
    WindowOpenGL = sdl.SDL_WINDOW_OPENGL # Create window with OpenGL support
    WindowShown = sdl.SDL_WINDOW_SHOWN # Window will start out visible
    WindowHidden = sdl.SDL_WINDOW_HIDDEN # Window will start out hidden
    WindowResizable = sdl.SDL_WINDOW_RESIZABLE # Window will be resizable
    Default = WindowShown.ord or WindowResizable.ord or WindowOpenGL.ord
    WindowFullscreenDesktop = sdl.SDL_WINDOW_FULLSCREEN_DESKTOP # Start window in fullscreen mode w/ same resolution as desktop


const posUndefined* = sdl.SDL_WINDOWPOS_UNDEFINED

proc init*(
  window: Window,
  title: string = "dEngine - " & globals.version,
  windowPosX, windowPosY: int,
  width, height: int,
  flags: uint32
) =
  window.handle = sdl.createWindow(
    title,
    windowPosX.cint, windowPosY.cint,
    width.cint, height.cint,
    flags
  )

proc destroy*(window: Window) =
  sdl.destroyWindow(window.handle)