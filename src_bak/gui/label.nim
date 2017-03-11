import glm, nvg

import ../gui, ../log, ../rectangle, types, widget

type
  Label* = ref object of Widget
    text*: string
    textColor: NVGColor
    fontId: string
    fontSize: float

proc moveLabel(widget: var Widget, x, y: float) =
  widget.position.x += x
  widget.position.y += y
  widget.bounds = widget.bounds.Translate(x,y)

proc moveLabelTo*(widget: var Widget, x, y: float) =
  let dx = x - widget.position.x
  let dy = y - widget.position.y

  widget.moveLabel(dx, dy)

proc render(widget: Widget, nvgContext: ptr NVGContext) {.procvar.} =
  let label = Label(widget)

  nvgFontFace(nvgContext, label.fontId)
  nvgFontSize(nvgContext, label.fontSize)
  nvgFillColor(nvgContext, label.textColor)
  nvgTextAlign(nvgContext, NVG_ALIGN_LEFT.int or NVG_ALIGN_MIDDLE.int);
  discard nvgText(nvgContext, label.position.x, label.position.y, label.text, nil)

  nvgStrokeColor(nvgContext, nvgRGBA(255,0,0,255))
  nvgBeginPath(nvgContext)
  nvgRect(
    nvgContext
    , label.bounds.left
    , label.bounds.top
    , label.bounds.Width()
    , label.bounds.Height()
  )
  if debug:
    if label.hovered:
      nvgFillColor(nvgContext, nvgRGBA(0,255,0,192))
      nvgFill(nvgContext)
    nvgStroke(nvgContext)


proc destroy() {.procvar.} =
  discard

let
  movable: IMovable = IMovable(move: moveLabel)

proc newLabel*(
    text: string
    , fontId: string
    , `static`: bool = true
    , textColor: NVGColor = nvgRGBA(255, 255, 255, 255)
    , position: Vec2f = vec2f(0)
    , fontSize: float = 12.0
    , fontFilename: string = nil
) : Label =
  result = Label()
  initWidget(Widget result, `static`)
  result.text  = text
  result.textColor = textColor
  result.fontId = fontId
  result.fontSize = fontSize
  result.updateFunc = update
  result.renderFunc = render
  result.dragEventFunc = dragEvent
  result.disposeFunc = destroy
  result.position = position
  
  if not result.`static`:
    result.movable = movable

  if not fontRegistered(fontId):
    if fontFilename.isNil:
      logError("Font with id " & fontId & " not yet loaded. Must provide filename.")
      return
    if not registerFont(fontId, fontFilename) :
      return

  var labelBounds : seq[cfloat] = @[cfloat 0.0, cfloat 0.0, cfloat 0.0, cfloat 0.0]
  nvgFontFace(getContext(), result.fontId)
  nvgFontSize(getContext(), result.fontSize)
  discard nvgTextBounds(getContext(), position.x, position.y, result.text, nil, addr labelBounds[0])

  let width = labelBounds[3] - labelBounds[1]
  let height = labelBounds[3] - labelBounds[1]

  result.bounds = newRectangle[float](position.x, position.y - height / 2, labelBounds[2], labelBounds[3])