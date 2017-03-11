import math, glm, nvg, opengl, sdl2

import ../gui, ../rectangle, ../util, layout, types, widget


var ICON_CIRCLED_CROSS : string = "A"

proc scrollPanel*(widget: var Widget, x , y: float) =
  if Panel(widget).contentBounds.Height() < widget.childBounds.Height():
    if not widget.layout.isNil:
      widget.layout.scroll(widget, x, y)
  
proc movePanel*(widget: var Widget, x, y: float) =
  var panel = Panel(widget)
  panel.bounds = panel.bounds.Translate(x, y)
  panel.headerBounds = panel.headerBounds.Translate(x, y)
  panel.closableBounds = panel.closableBounds.Translate(x,y)
  panel.contentBounds = panel.contentBounds.Translate(x,y)
  panel.childBounds = panel.childBounds.Translate(x,y)

  for child in panel.children:
    child.position.x += x
    child.position.y += y
    child.bounds = child.bounds.Translate(x, y)

proc resizePanel*(widget: var Widget, x, y: float) =
  let panel = Panel widget
  case panel.resizeMode
  of L:
    panel.bounds.left += x
    panel.headerBounds.left += x
  of R:
    panel.bounds.right += x
    panel.headerBounds.right += x
    panel.closableBounds.left += x
    panel.closableBounds.right += x
  of T:
    panel.bounds.top += y
    panel.headerBounds.top += y
    panel.headerBounds.bottom += y
    panel.closableBounds.top += y
    panel.closableBounds.bottom += y
    scrollPanel(widget, 0, y)
  of B:
    panel.bounds.bottom += y
  else:
    discard
  
  panel.layout.impl.execute(panel)

proc interact(widget: var Widget) =
  discard

proc closePanel(widget: var Widget) =
  widget.visible = false
  for child in widget.children:
    child.visible = false

proc render(widget: Widget, nvgContext: ptr NVGContext) {.procvar.} =
    let panel = Panel(widget)
  
    let cornerRadius = 3.0
    var shadowPaint, headerPaint, fadePaint : NVGPaint

    var icon = "        "
  

    nvgSave(nvgContext)

    # panel
    nvgBeginPath(nvgContext)
    nvgRoundedRect(nvgContext, panel.bounds.left, panel.bounds.top, panel.bounds.Width(), panel.bounds.Height(), cornerRadius)
    if debug and not panel.hovered:
        nvgFillColor(nvgContext, nvgRGBA(28,30,34,192))
    elif debug and panel.hovered:
      nvgFillColor(nvgContext, nvgRGBA(0,255,0,192))
    else:
      nvgFillColor(nvgContext, nvgRGBA(28,30,34,192))
    nvgFill(nvgContext)

    # drop shadow
    shadowPaint = nvgBoxGradient(
      nvgContext
      , panel.bounds.left
      , panel.bounds.top + 2
      , panel.bounds.Width()
      , panel.bounds.Height()
      , cornerRadius * 2, 10
      , nvgRGBA(0,0,0,128)
      , nvgRGBA(0,0,0,0)
    )
    nvgBeginPath(nvgContext)
    nvgRect(
      nvgContext
      , panel.bounds.left - 10
      , panel.bounds.top - 10
      , panel.bounds.Width() + 20
      , panel.bounds.Height() + 30
    )
    nvgRoundedRect(
      nvgContext
      , panel.bounds.left
      , panel.bounds.top
      , panel.bounds.Width()
      , panel.bounds.Height()
      , cornerRadius
    )
    nvgPathWinding(nvgContext, NVG_HOLE.cint)
    nvgFillPaint(nvgContext, shadowPaint)
    nvgFill(nvgContext)

    # header
    headerPaint = nvgLinearGradient(
      nvgContext
      , panel.bounds.left
      , panel.bounds.top
      , panel.bounds.left
      , panel.bounds.top + 15
      , nvgRGBA(255,255,255,8)
      , nvgRGBA(0,0,0,16),
    )
    nvgBeginPath(nvgContext)
    nvgRoundedRect(
      nvgContext
      , panel.bounds.left + 1
      , panel.bounds.top + 1
      , panel.bounds.Width() - 2
      , 30
      , cornerRadius - 1
    )
#[
    nvgStrokeColor(nvgContext, nvgRGBA(255,0,0,255))
    nvgBeginPath(nvgContext)
    nvgRoundedRect(
      nvgContext
      , panel.headerBounds.left
      , panel.headerBounds.top + 1
      , panel.headerBounds.Width()
      , panel.headerBounds.Height()
      , cornerRadius - 1
    )
    nvgStroke(nvgContext)
]#

    if debug:
      nvgStrokeColor(nvgContext, nvgRGBA(255,0,0,255))
      nvgBeginPath(nvgContext)
      nvgRoundedRect(
        nvgContext
        , panel.bounds.left
        , panel.bounds.top + 1
        , panel.bounds.Width()
        , panel.bounds.Height()
        , cornerRadius - 1
      )
      nvgStroke(nvgContext)

      nvgStrokeColor(nvgContext, nvgRGBA(0,0,255,255))
      nvgBeginPath(nvgContext)
      nvgRect(
        nvgContext
        , panel.contentBounds.left
        , panel.contentBounds.top
        , panel.contentBounds.Width()
        , panel.contentBounds.Height()
      )
      nvgStroke(nvgContext)

      nvgStrokeColor(nvgContext, nvgRGBA(0,255,0,255))
      nvgBeginPath(nvgContext)
      nvgRect(
        nvgContext
        , panel.childBounds.left
        , panel.childBounds.top
        , panel.childBounds.Width()
        , panel.childBounds.Height()
      )
      nvgStroke(nvgContext)


    nvgFillPaint(nvgContext, headerPaint)
    nvgFill(nvgContext)
    nvgBeginPath(nvgContext)
    nvgMoveTo(nvgContext, panel.bounds.left + 0.5, panel.bounds.top + 0.5 + 30)
    nvgLineTo(nvgContext, panel.bounds.left + 0.5 + panel.bounds.Width() - 1, panel.bounds.top + 0.5 + 30)
    nvgStrokeColor(nvgContext, nvgRGBA(0,0,0,32))
    nvgStroke(nvgContext)

    if panel.closable.close != nil:
      nvgFontSize(nvgContext, panel.headerBounds.Height() * 0.5);
      nvgFontFace(nvgContext, "icons");
      if panel.closableHovered:
        nvgFillColor(nvgContext, nvgRGBA(255,255,255,255)) 
       
      else:
        nvgFillColor(nvgContext, nvgRGBA(255,255,255,32));
      nvgTextAlign(nvgContext,NVG_ALIGN_CENTER.int or NVG_ALIGN_MIDDLE.int);
      discard nvgText(nvgContext, panel.headerBounds.left+panel.headerBounds.Width()-panel.headerBounds.Height()*0.55f, panel.bounds.top + 16 + 1, ICON_CIRCLED_CROSS, nil);


    nvgScissor(nvgContext, panel.headerBounds.left, panel.headerBounds.top, panel.headerBounds.Width() - panel.closableBounds.Width(), panel.headerBounds.Height())
    
    nvgFontSize(nvgContext, 18.0)
    nvgFontFace(nvgContext, "orbitron")
    nvgTextAlign(nvgContext, NVG_ALIGN_CENTER.int or NVG_ALIGN_MIDDLE.int)
    
    nvgFontBlur(nvgContext, 2)
    nvgFillColor(nvgContext, nvgRGBA(0,0,0,128))
    discard nvgText(nvgContext, panel.bounds.left + panel.bounds.Width() / 2, panel.bounds.top + 16 + 1, panel.title, nil)

    nvgFontBlur(nvgContext, 0)
    nvgFillColor(nvgContext, nvgRGBA(220,220,220,160))
    discard nvgText(nvgContext, panel.bounds.left + panel.bounds.Width() / 2, panel.bounds.top + 16 + 1, panel.title, nil)

    nvgScissor(nvgContext, panel.contentBounds.left, panel.contentBounds.top, panel.contentBounds.Width(), panel.contentBounds.Height())
    for child in panel.children:
        if child.visible:
          child.renderFunc(child, nvgContext)

    #fadePaint = nvgLinearGradient(nvgContext, panel.bounds.left, panel.bounds.top, panel.bounds.left, panel.bounds.top + 6, nvgRGBA(200,200,200,255), nvgRGBA(200,200,200,0))
    #nvgBeginPath(nvgContext)
    #nvgRect(nvgContext, panel.bounds.left + 4, panel.bounds.top ,panel.bounds.Width() - 8,6)
    #nvgFillPaint(nvgContext, fadePaint)
    #nvgFill(nvgContext)


    #fadePaint = nvgLinearGradient(nvgContext, panel.bounds.left, panel.bounds.top + panel.bounds.Height(),panel.bounds.left,panel.bounds.top+panel.bounds.Height()-6, nvgRGBA(200,200,200,255), nvgRGBA(200,200,200,0))
    #nvgBeginPath(nvgContext);
    #nvgRect(nvgContext, panel.bounds.left+4,panel.bounds.top+panel.bounds.Height()-6,panel.bounds.Width()-8,6);
    #nvgFillPaint(nvgContext, fadePaint);
    #nvgFill(nvgContext);

    # Scroll bar
    shadowPaint = nvgBoxGradient(nvgContext, panel.bounds.left + panel.bounds.Width() - 12 + 1, panel.headerBounds.bottom + 4 + 1, 8, panel.contentBounds.Height()-8, 3,4, nvgRGBA(0,0,0,32), nvgRGBA(0,0,0,92))
    nvgBeginPath(nvgContext)
    nvgRoundedRect(nvgContext, panel.bounds.left + panel.bounds.Width() - 12, panel.headerBounds.bottom + 4, 8, panel.contentBounds.Height() - 8, 3)
    nvgFillPaint(nvgContext, shadowPaint)
    # nvgFillColor(nvgContext, nvgRGBA(255,0,0,128))
    nvgFill(nvgContext)

    shadowPaint = nvgBoxGradient(nvgContext, panel.bounds.left + panel.bounds.Width() - 12 - 1, panel.headerBounds.bottom + 4 + (panel.contentBounds.Height() - 8 - panel.scrollHeight) * panel.scrollPercentage - 1, 8, panel.scrollHeight, 3, 4, nvgRGBA(220,220,220,255), nvgRGBA(128,128,128,255))
    nvgBeginPath(nvgContext)
    nvgRoundedRect(nvgContext, panel.bounds.left + panel.bounds.Width() - 12 + 1, panel.headerBounds.bottom + 4 + 1 + (panel.contentBounds.Height() - 8 - panel.scrollHeight) * panel.scrollPercentage, 8 - 2, panel.scrollHeight - 2, 2)
    nvgFillPaint(nvgContext, shadowPaint);
    #nvgFillColor(nvgContext, nvgRGBA(0,0,0,128));
    nvgFill(nvgContext)

    nvgRestore(nvgContext)

proc destroy() {.procvar.} =
  discard

let
  movable : IMovable = IMovable(move: movePanel)
  resizable: IResizable = IResizable(resize: resizePanel)
  closable: IClosable = IClosable(close: closePanel)
  interactable: IInteractable = IInteractable(interact: interact)
  scrollable: IScrollable = IScrollable(scroll: scrollPanel)

proc newPanel*(
  title: string
  , position
  , size: Vec2f
  , layout: Layout = nil
  , `static`: bool = false
  , minWidth, minHeight: float = 100
) : Panel =
  result = Panel()
  initWidget(Widget result, `static`)
  result.title = title
  result.minWidth = minWidth
  result.minHeight = minHeight
  result.updateFunc = update
  result.renderFunc = render
  result.dragEventFunc = dragEvent
  result.disposeFunc = destroy
  result.interactable = interactable
  result.scrollable = scrollable
  result.layout = layout
  result.resizable = resizable
  result.closable = closable
  result.bounds = newRectangle[float](position.x, position.y, position.x + size.x, position.y + size.y)
  result.headerBounds = newRectangle[float](position.x, position.y, position.x + size.x, position.y + 32)

  if not result.`static`:
    result.movable = movable
  
  let left = result.headerBounds.left+result.headerBounds.Width()-result.headerBounds.Height()*0.55f
  let top = result.headerBounds.top+result.headerBounds.Height()*0.55f

  var bounds : seq[cfloat] = @[cfloat 0, cfloat 0, cfloat 0, cfloat 0]
  nvgFontSize(getContext(), result.headerBounds.Height()* 0.5f);
  nvgFontFace(getContext(), "icons");
  discard nvgTextBounds(getContext(), left, top, "A", nil, addr bounds[0])

  let width = bounds[2] - bounds[0]
  let height = bounds[3] - bounds[1]

  result.closableBounds = newRectangle[float](
    left - width
    , top - height
    , left + width
    , top + height
  )