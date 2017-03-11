import sdl2

type
  Window* = ref object
    handle: WindowPtr

proc newWindow*(title: string = "dEngine", x: int, y: int, width: int, height: int, fullscreen: bool, vsync: bool) : Window =
  result = Window()
  
  var flags : cuint
  if fullscreen:
    flags = SDL_WINDOW_FULLSCREEN or SDL_WINDOW_OPENGL
  else:
    flags = SDL_WINDOW_RESIZABLE or SDL_WINDOW_OPENGL

  result.handle = createWindow(title, x.cint, y.cint, width.cint, height.cint, flags)

proc handle*(window: Window) : WindowPtr =
  return window.handle

proc dispose*(window: Window) =
  destroyWindow(window.handle)