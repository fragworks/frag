import glm

import ../rectangle, types

proc scroll*(layout: Layout, widget: Widget, x, y: float) =
  if layout of BoxLayout:
    var boxLayout = BoxLayout(layout)
    var dx, dy : float
    if boxLayout.orientation == Vertical:
      dy = y
      dx = 0

      if dy > 0 and widget.childBounds.top + dy >= Panel(widget).contentBounds.top + 1 + boxLayout.margin:
        return
      elif dy < 0 and widget.children[widget.children.len - 1].bounds.bottom + dy <= Panel(widget).contentBounds.bottom - 1 - boxLayout.margin:
        return
    else:
      dx = x
      dy = 0

    widget.childBounds = widget.childBounds.Translate(dx, dy)
    if widget of Panel:
      var panel = Panel(widget)
      echo ((panel.contentBounds.top - widget.childBounds.top) / widget.childBounds.Height())
      widget.scrollPercentage = (panel.contentBounds.top - widget.childBounds.top) / (widget.childBounds.Height() - panel.contentBounds.Height())

    for child in widget.children.mitems:
      if not child.movable.move.isNil:
          child.movable.move(child, dx, dy)

proc executeBoxLayout*(widget: Widget) =
  let layout : BoxLayout = BoxLayout widget.layout
  let axisOne = int(layout.orientation)
  let axisTwo = (int(layout.orientation) + 1) mod 2

  var position = layout.margin
  var yOffset = 0.0

  var containerSize = vec2f(widget.bounds.Width(), widget.bounds.Height())

  if widget of Panel:
    var panel = Panel widget
    panel.contentBounds = newRectangle(
      panel.bounds.left + layout.margin
      , panel.headerBounds.bottom + layout.margin
      , panel.bounds.right - layout.margin
      , panel.bounds.bottom - layout.margin
    )
    if layout.orientation == Vertical:
      position += panel.headerBounds.Height() + layout.margin
    else:
      yOffset = panel.headerBounds.Height() + layout.margin
      containerSize.y = containerSize.y - yOffset
    
  var first = true
  for w in widget.children:
    if not w.visible:
      continue
    if first:
      first = false
    else:
      position += layout.spacing
    
    var targetSize : array[2, float]
    targetSize = [w.bounds.Width(), w.bounds.Height()]
    var pos : array[2, float] = [0.0 ,yOffset]
    
    pos[axisOne] = position

    case layout.alignment
    of Minimum:
      pos[axisTwo] += layout.margin
    of Middle:
      discard
    of Maximum:
      discard
    of Fill:
      discard
    
    if not w.movable.move.isNil:
      var movableWidget = w
      if not widget.beingResized:
        w.movable.move(movableWidget, pos[0] + widget.bounds.left, pos[1] + widget.bounds.top)
      else:
        if widget of Panel:
          var panel = Panel widget
          
          if widget.beingResized:
            if layout.orientation == Vertical:
              w.movable.move(
                movableWidget
                , (panel.headerBounds.left - w.position.x) + pos[0]
                , 0
              )
    position += targetSize[axisOne]
  
  if widget.children.len > 0:
    if widget of Panel:
      var panel = Panel widget
      if not widget.beingResized:
        widget.childBounds = newRectangle(panel.contentBounds.left, panel.contentBounds.top, panel.contentBounds.right, widget.children[widget.children.len - 1].bounds.bottom + layout.margin)
  
      widget.scrollHeight =  (panel.contentBounds.Height() / widget.childBounds.Height()) * (panel.contentBounds.Height() - 8)
  

proc newBoxLayout*(orientation: Orientation, alignment: Alignment, margin: float, spacing: float) : BoxLayout =
  result = BoxLayout()
  result.orientation = orientation
  result.alignment = alignment
  result.margin = margin
  result.spacing = spacing
  result.impl = ILayout(execute:executeBoxLayout)