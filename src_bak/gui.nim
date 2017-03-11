import glm, nvg, os, sdl2, tables

import event, graphics, rectangle, stack, log, gui/types

var debug* {.global.} = false

var vg {.global.}: ptr NVGcontext = nil

var pxRatio {.global.} : float

var dragActive* {.global.} : bool = false

var widgetBeingDragged* {.global.} : Widget = nil
var widgetsInFocus* {.global.} : seq[Widget] = nil
var widgets {.global.} : FastStack[Widget]
var fonts {.global.} : Table[string, string]

var activeWidget {.global.} : Widget = nil

proc registerWidget*(widget: Widget) =
  widgets.add(widget)
  if not widget.interactable.interact.isNil:
    activeWidget = widget

proc registerWidgets*(widgetsToAdd: varargs[Widget]) =
  for widget in widgetsToAdd:
    registerWidget(widget)

proc contains(widget: Widget, x, y: float) : bool =
  if widget.bounds.Contains(x, y):
    return true

proc fontRegistered*(id: string) : bool =
  contains(fonts, id)

proc registerFont*(id: string, filename: string) : bool =
  if not fileExists(filename):
    logError "Unable to load font with filename : " & filename & " file does not exist."
    return false

  if nvgCreateFont(vg, id, filename) == -1:
    logError "Unable to create nanovg font with filename : " & filename
    return false

  add(fonts, id, filename)

  return true

proc findTopMostWidgetInFocus() : Widget =
  for widget in widgets:
    if widgetsInFocus.contains(widget):
      return widget
    

proc findWidgetsInFocus(x, y: float) = 
  widgetsInFocus.setLen(0)
  for widget in widgets:
    if widget.contains(x, y) and widget.visible:
      widgetsInFocus.add(widget)
    
proc guiUpdate*(deltaTime: float) =
  var x, y : cint
  getMouseState(x, y)

  if not activeWidget.isNil:
    if not activeWidget.updateFunc.isNil:
      if widgetsInFocus.len == 0:
        activeWidget.updateFunc(activeWidget, deltaTime, false)
      else:
        activeWidget.updateFunc(activeWidget, deltaTime, widgetsInFocus.contains(activeWidget))
    
    if widgetsInFocus.len == 0:
      cursor = createSystemCursor(SDL_SYSTEM_CURSOR_ARROW)
      setCursor(cursor)

proc guiRender*() =
  nvgBeginFrame(vg, getWidth().cint, getHeight().cint, pxRatio)

  for widget in widgets.itemsReverse:
    if not activeWidget.isNil:
      if widget == activeWidget:
        continue
    if widget.visible:
      widget.renderFunc(widget, vg)

  if not activeWidget.isNil:
    if activeWidget.visible:
      activeWidget.renderFunc(activeWidget, vg)

  nvgEndFrame(vg)

proc guiShutdown*() =
  for widget in widgets:
    widget.disposeFunc()
  nvgDeleteGL3(vg)

proc listenForWindowEvent(event: Event) : bool =
  case event.window.event
  of WindowEvent_Resized:
    pxRatio = getFramebufferWidth().cfloat / cfloat(getWidth())
        
  else:
    discard

proc updateActiveWidget(widget: Widget) =
  activeWIdget = widget

proc listenForGUIEvent(event: Event) : bool =
  case event.kind
  of MouseMotion:
    findWidgetsInFocus(float event.motion.x, float event.motion.y)
    if dragActive:
      widgetBeingDragged.dragEventFunc(widgetBeingDragged, event)
  of MouseButtonUp:
    if dragActive:
      dragActive = false
      widgetBeingDragged = nil
  of MouseButtonDown:
    if widgetsInFocus.len > 0:
      if not activeWidget.isNil:
        if activeWidget.closableBounds.Contains(float event.button.x, float event.button.y):
          activeWidget.closable.close(activeWidget)
        else:
          var topMostWidgetInFocus = findTopMostWidgetInFocus()
          if not topMostWidgetInFocus.interactable.interact.isNil:
            if activeWidget != topMostWidgetInFocus and not widgetsInFocus.contains(activeWidget):
              echo "Updating active widget!"
              updateActiveWidget(topMostWidgetInFocus)
              
            dragActive = true
            widgetBeingDragged = activeWidget
          else:
            discard
  of MouseWheel:
    if widgetsInFocus.len > 0:
      if not activeWidget.isNil:
        var topMostWidgetInFocus = findTopMostWidgetInFocus()
        if topMostWidgetInFocus == activeWidget and not activeWidget.scrollable.scroll.isNil:
          activeWidget.scrollable.scroll(activeWidget, float event.wheel.x, float event.wheel.y)
  else:
    discard

  return true

proc guiInit*(dbg: bool) : bool =
  debug = dbg
  vg = nvgCreateGL3(NVG_ANTIALIAS or NVG_STENCIL_STROKES or NVG_DEBUG)
  pxRatio = getFramebufferWidth().cfloat / cfloat(getWidth())
  if vg == nil: 
    logError "Error initializing nanovg..."
    return false
  
  widgets = newFastStack[Widget](1)
  widgetsInFocus = @[]
  fonts = initTable[string, string]()

  discard registerFont("icons", "assets/fonts/dEngineIcons.ttf")

  registerEventListener(listenForGUIEvent, @[MouseMotion, MouseButtonDown, MouseButtonUp, MouseWheel])
  registerEventListener(listenForWindowEvent, @[WindowEvent])

  return true
  
proc setDragActive*(active: bool) =
  dragActive = active

proc getContext*() : NVGContextPtr =
  vg

proc layoutGUI*() =
  for widget in widgets:
    if not widget.layout.isNil:
        widget.layout.impl.execute(widget)
  
