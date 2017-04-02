{.experimental.}

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

proc onKeyDown*(this: GUI, event: sdl.Event) {.procvar.} =
  discard