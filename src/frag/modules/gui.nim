{.experimental.}
import
  events

import
  nuklear,
  sdl2 as sdl

export panel_flags

import
  ../graphics/camera,
  ../graphics/window,
  ../gui/imgui,
  ../gui/themes/gui_themes,
  ../math/fpu_math as fpumath,
  module,
  ../utils/viewport

proc init*(gui: GUI, viewId: uint8): bool =
  gui.imgui = IMGUI()
  return gui.imgui.init(viewId)

proc setCamera*(gui: GUI, camera: Camera) =
  gui.camera = camera

proc setViewport*(gui: GUI, viewport: Viewport) =
  gui.viewport = viewport

proc setWindow*(gui: GUI, window: Window) =
  gui.window = window

proc openWindow*(gui: GUI, title: string, x, y, w, h: float, flags: uint32): bool =
  gui.imgui.ctx.open(title, newRect(x, y, w, h), flags)

proc closeWindow*(gui: GUI) =
  gui.imgui.ctx[].close()

proc startUpdate*(gui: GUI) =
  gui.imgui.startUpdate()

proc finishUpdate*(gui: GUI) =
  gui.imgui.finishUpdate()

proc render*(gui: GUI) =
  gui.imgui.render()

proc setTheme*(gui: GUI, theme: GUITheme) =
  gui_themes.setTheme(gui.imgui, theme)

proc setProjectionMatrix*(gui: GUI, projection: Mat4, viewId: uint8) =
  gui.imgui.setProjectionMatrix(projection, viewId)

proc shutdown*(gui: GUI) =
  gui.imgui.dispose()

proc layoutDynamicRow*(gui: GUI, height: float32, cols: int32) =
  gui.imgui.ctx.layoutDynamicRow(height, cols)

proc buttonLabel*(gui: GUI, label: string): bool =
  gui.imgui.ctx.buttonLabel(label)

proc progressBar*(gui: GUI, currentProgress: var uint, maxProgress: uint, modifiable: bool): bool =
  gui.imgui.ctx.progress(currentProgress, maxProgress, modifiable)

proc handleKeyPress(gui: GUI, modState: sdl.Keymod, sym: cint, down: bool) =
  case sym
  of sdl.K_RSHIFT, sdl.K_LSHIFT:
    inputKey(gui.imgui.ctx, keys.KEY_SHIFT, down)
  of sdl.K_DELETE:
    inputKey(gui.imgui.ctx, keys.KEY_DEL, down)
  of sdl.K_RETURN:
    inputKey(gui.imgui.ctx, keys.KEY_ENTER, down)
  of sdl.K_TAB:
    inputKey(gui.imgui.ctx, keys.KEY_TAB, down)
  of sdl.K_BACKSPACE:
    inputKey(gui.imgui.ctx, keys.KEY_BACKSPACE, down)
  of sdl.K_HOME:
    inputKey(gui.imgui.ctx, keys.KEY_TEXT_START, down)
    inputKey(gui.imgui.ctx, keys.KEY_SCROLL_START, down)
  of sdl.K_END:
    inputKey(gui.imgui.ctx, keys.KEY_TEXT_END, down)
    inputKey(gui.imgui.ctx, keys.KEY_SCROLL_END, down)
  of sdl.K_PAGEDOWN:
    inputKey(gui.imgui.ctx, keys.KEY_SCROLL_UP, down)
  of sdl.K_PAGEUP:
    inputKey(gui.imgui.ctx, keys.KEY_SCROLL_DOWN, down)
  of sdl.K_Z:
    inputKey(gui.imgui.ctx, keys.KEY_TEXT_UNDO, down and modState == sdl.KMOD_LCTRL)
  of sdl.K_R:
    inputKey(gui.imgui.ctx, keys.KEY_TEXT_REDO, down and modState == sdl.KMOD_LCTRL)
  of sdl.K_C:
    inputKey(gui.imgui.ctx, keys.KEY_COPY, down and modState == sdl.KMOD_LCTRL)
  of sdl.K_V:
    inputKey(gui.imgui.ctx, keys.KEY_PASTE, down and modState == sdl.KMOD_LCTRL)
  of sdl.K_X:
    inputKey(gui.imgui.ctx, keys.KEY_CUT, down and modState == sdl.KMOD_LCTRL)
  of sdl.K_B:
    inputKey(gui.imgui.ctx, keys.KEY_TEXT_LINE_START, down and modState == sdl.KMOD_LCTRL)
  of sdl.K_E:
    inputKey(gui.imgui.ctx, keys.KEY_TEXT_LINE_END, down and modState == sdl.KMOD_LCTRL)
  of sdl.K_UP:
    inputKey(gui.imgui.ctx, keys.KEY_UP, down)
  of sdl.K_DOWN:
    inputKey(gui.imgui.ctx, keys.KEY_DOWN, down)
  of sdl.K_LEFT:
    if modState == sdl.KMOD_LCTRL:
      inputKey(gui.imgui.ctx, keys.KEY_TEXT_WORD_LEFT, down)
    else:
      inputKey(gui.imgui.ctx, keys.KEY_LEFT, down)
  of sdl.K_RIGHT:
    if modState == sdl.KMOD_LCTRL:
      inputKey(gui.imgui.ctx, keys.KEY_TEXT_WORD_RIGHT, down)
    else:
      inputKey(gui.imgui.ctx, keys.KEY_RIGHT, down)
  else:
    discard

proc onKeyDown*(gui: GUI, event: sdl.Event) =
  handleKeyPress(gui, sdl.getModState(), event.key.keysym.sym, true)

proc onKeyUp*(gui: GUI, event: sdl.Event) =
  handleKeyPress(gui, sdl.getModState(), event.key.keysym.sym, false)
  
proc handleMouseButton(gui: GUI, button: uint8, x, y: cint, down: bool) =
  case button
  of sdl.BUTTON_LEFT:
    inputButton(gui.imgui.ctx, buttons.BUTTON_LEFT, x, y, down)
  of sdl.BUTTON_RIGHT:
    inputButton(gui.imgui.ctx, buttons.BUTTON_RIGHT, x, y, down)
  of sdl.BUTTON_MIDDLE:
    inputButton(gui.imgui.ctx, buttons.BUTTON_MIDDLE, x, y, down)
  else:
    discard

proc project*(gui: GUI, event: sdl.Event): tuple =
  var posX, posY: float
  let size = sdl.getSize(gui.window.handle)
  case event.kind
  of MouseButtonDown, MouseButtonUp:
    var screenCoords: Vec3 = [event.button.x.float32, event.button.y.float32, 0.0]

    camera.unproject(gui.camera, screenCoords, gui.viewport.screenX.float,gui.viewport.screenY.float, gui.viewport.screenWidth.float, gui.viewport.screenHeight.float, size[0].float, size[1].float)

    posX = (((screenCoords[0] + 1.0) * (gui.viewport.worldWidth.float - 0.0)) / (1.0 + 1.0)) + 0.0

    posY = (((screenCoords[1] + 1.0) * (gui.viewport.worldHeight.float - 0.0)) / (1.0 + 1.0)) + 0.0
  of MouseMotion:
    var screenCoords: Vec3 = [event.motion.x.float32, event.motion.y.float32, 0.0]

    camera.unproject(gui.camera, screenCoords, gui.viewport.screenX.float,gui.viewport.screenY.float, gui.viewport.screenWidth.float, gui.viewport.screenHeight.float, size[0].float, size[1].float)

    posX = (((screenCoords[0] + 1.0) * (gui.viewport.worldWidth.float - 0.0)) / (1.0 + 1.0)) + 0.0

    posY = (((screenCoords[1] + 1.0) * (gui.viewport.worldHeight.float - 0.0)) / (1.0 + 1.0)) + 0.0
  else:
    discard
  
  (x: posX.cint, y: posY.cint)

proc onMouseButtonDown*(gui: GUI, event: sdl.Event) =
  var pos = project(gui, event)
  handleMouseButton(gui, event.button.button, pos.x, pos.y, true)

proc onMouseButtonUp*(gui: GUI, event: sdl.Event) =
  var pos = project(gui, event)
  handleMouseButton(gui, event.button.button, pos.x, pos.y, false)

proc onMouseMotion*(gui: GUI, event: sdl.Event) =
  if not gui.window.isNil:
    var pos = project(gui, event)
    inputMotion(gui.imgui.ctx, pos.x, pos.y)