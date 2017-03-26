{.experimental.}
import 
  nuklear

import 
  ../imgui

type
  GUITheme* {.pure.} = enum
    White

proc setTheme*(imgui: IMGUI, theme: GUITheme) =
  var style : array[COLOR_COUNT.ord, color]
  case theme:
  of GUITheme.White:
    style[COLOR_TEXT.ord] = newColorRGBA(255, 255, 255, 255)
    style[COLOR_WINDOW.ord] = newColorRGBA(0, 0, 0, 0)
    style[COLOR_HEADER.ord] = newColorRGBA(175, 175, 175, 255)
    style[COLOR_BORDER.ord] = newColorRGBA(0, 0, 0, 255)
    style[COLOR_BUTTON.ord] = newColorRGBA(185, 185, 185, 255)
    style[COLOR_BUTTON_HOVER.ord] = newColorRGBA(170, 170, 170, 255)
    style[COLOR_BUTTON_ACTIVE.ord] = newColorRGBA(160, 160, 160, 255)
    style[COLOR_TOGGLE.ord] = newColorRGBA(150, 150, 150, 255)
    style[COLOR_TOGGLE_HOVER.ord] = newColorRGBA(120, 120, 120, 255)
    style[COLOR_TOGGLE_CURSOR.ord] = newColorRGBA(175, 175, 175, 255)
    style[COLOR_SELECT.ord] = newColorRGBA(190, 190, 190, 255)
    style[COLOR_SELECT_ACTIVE.ord] = newColorRGBA(175, 175, 175, 255)
    style[COLOR_SLIDER.ord] = newColorRGBA(190, 190, 190, 255)
    style[COLOR_SLIDER_CURSOR.ord] = newColorRGBA(80, 80, 80, 255)
    style[COLOR_SLIDER_CURSOR_HOVER.ord] = newColorRGBA(70, 70, 70, 255)
    style[COLOR_SLIDER_CURSOR_ACTIVE.ord] = newColorRGBA(60, 60, 60, 255)
    style[COLOR_PROPERTY.ord] = newColorRGBA(175, 175, 175, 255)
    style[COLOR_EDIT.ord] = newColorRGBA(150, 150, 150, 255)
    style[COLOR_EDIT_CURSOR.ord] = newColorRGBA(0, 0, 0, 255)
    style[COLOR_COMBO.ord] = newColorRGBA(175, 175, 175, 255)
    style[COLOR_CHART.ord] = newColorRGBA(160, 160, 160, 255)
    style[COLOR_CHART_COLOR.ord] = newColorRGBA(45, 45, 45, 255)
    style[COLOR_CHART_COLOR_HIGHLIGHT.ord] = newColorRGBA(255, 0, 0, 255)
    style[COLOR_SCROLLBAR.ord] = newColorRGBA(180, 180, 180, 255)
    style[COLOR_SCROLLBAR_CURSOR.ord] = newColorRGBA(140, 140, 140, 255)
    style[COLOR_SCROLLBAR_CURSOR_HOVER.ord] = newColorRGBA(150, 150, 150, 255)
    style[COLOR_SCROLLBAR_CURSOR_ACTIVE.ord] = newColorRGBA(160, 160, 160, 255)
    style[COLOR_TAB_HEADER.ord] = newColorRGBA(180, 180, 180, 255)
  
  imgui.ctx.newStyleFromTable(style[0])