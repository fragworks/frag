{.experimental.}
import
  events

import
  nuklear,
  sdl2 as sdl

export panel_flags

import
  ../gui/imgui,
  ../gui/themes/gui_themes,
  ../math/fpu_math as fpumath,
  module

proc init*(gui: GUI): bool =
  gui.view = 1
  gui.imgui = IMGUI()
  return gui.imgui.init()

proc setView*(gui: GUI, view: uint8) =
  gui.view = view

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

proc setProjectionMatrix*(gui: GUI, projection: Mat4) =
  gui.imgui.setProjectionMatrix(projection, gui.view)

proc shutdown*(gui: GUI) =
  gui.imgui.dispose()

proc layoutDynamicRow*(gui: GUI, height: float32, cols: int32) =
  gui.imgui.ctx.layoutDynamicRow(height, cols)

proc buttonLabel*(gui: GUI, label: string): bool =
  gui.imgui.ctx.buttonLabel(label)

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

proc onMouseButtonDown*(gui: GUI, event: sdl.Event) =
  handleMouseButton(gui, event.button.button, event.button.x, event.button.y, true)

proc onMouseButtonUp*(gui: GUI, event: sdl.Event) =
  handleMouseButton(gui, event.button.button, event.button.x, event.button.y, false)

proc onMouseMotion*(gui: GUI, event: sdl.Event) =
  inputMotion(gui.imgui.ctx, event.motion.x, event.motion.y)
  