import glm, sdl2

import ../graphics, ../gui, ../rectangle, types

proc dragEvent*(widget: var Widget, event: Event) {.procvar.} =
  if not widget.isNil:
      
    let mouseX = float event.motion.x
    let mouseY = float event.motion.y
    let relx = float event.motion.xrel
    let rely = float event.motion.yrel

    if not widget.beingResized:
      if not widget.movable.move.isNil:
        widget.movable.move(widget, relx, rely)
      
    else:
      case widget.resizeMode
      of R:
        if mouseX >= widget.bounds.left + widget.minWidth + 5:
          widget.resizable.resize(widget, relx, rely)
        else:
          return
      of L:
        if mouseX <= widget.bounds.right - widget.minWidth - 5:
          widget.resizable.resize(widget, relx, rely)
        else:
          return
      of T:
        if mouseY <= widget.bounds.bottom - widget.minHeight - 5:
          widget.resizable.resize(widget, relx, rely)
        else:
          return
      of B:
        if mouseY >= widget.bounds.top + widget.minHeight + 5:
          widget.resizable.resize(widget, relx, rely)
        else:
          return
      else:
        discard
      
proc resize*(widget: Widget) =
  discard

proc update*(widget: Widget, deltaTime: float, hovered: bool) {.procvar.} =
  # TODO: Handle corner resizing
  var mouseX, mouseY : cint
  getMouseState(mouseX, mouseY)
  
  if widget.parent.isNil:
    if hovered:
      widget.hovered = true
      if widget.closableBounds.Contains(float mouseX, float mouseY):
        widget.closableHovered = true
        cursor = createSystemCursor(SDL_SYSTEM_CURSOR_ARROW)
        setCursor(cursor)
        return
      else:
        widget.closableHovered = false

      var iSide = 0
      var iTopBot = 0
      
      let mx = float mouseX
      let my = float mouseY

      if mx <= widget.bounds.left + 5 and mx >= widget.bounds.left - 5:
        iSide = 1
      if mx >= widget.bounds.right - 5 and mx <= widget.bounds.right + 5:
        iSide = 2
      if my <= widget.bounds.top + 5 and my >= widget.bounds.top - 5:
        iTopBot = 3
      if my >= widget.bounds.bottom - 5 and my <= widget.bounds.bottom + 5:
        iTopBot = 6

      if widget.resizable.resize != nil:
        let border = iSide + iTopBot

        case border:
        of 0:
          cursor = createSystemCursor(SDL_SYSTEM_CURSOR_SIZEALL)
          setCursor(cursor)
          widget.beingResized = false
        of 1, 2:
          cursor = createSystemCursor(SDL_SYSTEM_CURSOR_SIZEWE)
          setCursor(cursor)
          widget.beingResized = true
          if border == 1:
            widget.resizeMode = L
          else:
            widget.resizeMode = R
        of 3, 6:
          cursor = createSystemCursor(SDL_SYSTEM_CURSOR_SIZENS)
          setCursor(cursor)
          widget.beingResized = true
          if border == 3:
            widget.resizeMode = T
          else:
            widget.resizeMode = B
        of 5, 7:
          cursor = createSystemCursor(SDL_SYSTEM_CURSOR_SIZENESW)
          setCursor(cursor)
          widget.beingResized = true
          if border == 5:
            widget.resizeMode = TR
          else:
            widget.resizeMode = BL
        of 4, 8:
          cursor = createSystemCursor(SDL_SYSTEM_CURSOR_SIZENWSE)
          setCursor(cursor)
          widget.beingResized = true
          if border == 4:
            widget.resizeMode = TL
          else:
            widget.resizeMode = BR
        else:
          cursor = createSystemCursor(SDL_SYSTEM_CURSOR_SIZEALL)
          setCursor(cursor)
      else:
        if widget.movable.move != nil:
          cursor = createSystemCursor(SDL_SYSTEM_CURSOR_SIZEALL)
          setCursor(cursor)
        else:
          cursor = createSystemCursor(SDL_SYSTEM_CURSOR_ARROW)
          setCursor(cursor)
    else:
      widget.hovered = false
      widget.closableHovered = false
      cursor = createSystemCursor(SDL_SYSTEM_CURSOR_ARROW)
      setCursor(cursor)

proc performLayout*(widget: var Widget) {.procvar.} =
  echo "Performing layout!"

proc initWidget*(widget: var Widget, `static`: bool) =
  widget.children = @[]
  widget.visible = true
  widget.`static` = `static`

proc addChild*(parentWidget, childWidget: Widget) =
  parentWidget.children.add(childWidget)
  childWidget.parent = parentWidget