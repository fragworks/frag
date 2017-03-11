import glm, nvg, sdl2

import ../rectangle

type  
  WidgetUpdateFunc = proc(widget: Widget, deltaTime: float, hovered: bool)
  WidgetRenderFunc = proc(widget: Widget, vgContext: ptr NVGContext)
  WidgetDragEventFunc = proc(widget: var Widget, event: Event)
  WidgetDisposeFunc = proc()

  Widget* = ref object of RootObj
    updateFunc*: WidgetUpdateFunc
    renderFunc*: WidgetRenderFunc
    dragEventFunc*: WidgetDragEventFunc
    disposeFunc*: WidgetDisposeFunc
    bounds*: Rectangle[float]
    position*: Vec2f
    layout*: Layout
    resizeMode*: ResizeMode
    beingResized*: bool
    minWidth*, minHeight*: float
    movable*: IMovable
    resizable*: IResizable
    closable*: IClosable
    interactable*: IInteractable
    scrollable*: IScrollable
    scrollHeight*: float
    scrollPercentage*: float
    closableBounds*: Rectangle[float]
    hovered*: bool
    closableHovered*: bool
    visible*: bool
    children*: seq[Widget]
    childBounds*: Rectangle[float]
    parent*: Widget
    `static`*: bool

  Panel* = ref object of Widget
    title*: string
    headerBounds*: Rectangle[float]
    contentBounds*: Rectangle[float]

  ResizeMode* = enum
    T, L, R, B, TL, TR, BL, BR

  IResizable* = object
    resize*: proc(widget: var Widget, x, y: float) {.closure.}
  
  IMovable* = object
    move*: proc(widget: var Widget, x, y: float) {.closure.}
  
  IClosable* = object
    close*: proc(widget: var Widget) {.closure.}
  
  IInteractable* = object
    interact*: proc(widget: var Widget) {.closure.}
  
  IScrollable* = object
    scroll*: proc(widget: var Widget, x, y: float) {.closure.}

  Alignment* = enum
    Minimum, Middle, Maximum, Fill

  Orientation* = enum
    Horizontal, Vertical
  
  Layout* {.pure inheritable.} = ref object of RootObj
    impl*: ILayout

  BoxLayout* = ref object of Layout
    orientation*: Orientation
    alignment*: Alignment
    margin*: float
    spacing*: float

  ILayout* = object
    execute*: proc(widget: Widget) {.closure.}