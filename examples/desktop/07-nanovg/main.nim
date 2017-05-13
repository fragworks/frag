import
  events

import
  bgfxextrasdotnim

import
  ../../../src/frag,
  ../../../src/frag/config,
  ../../../src/frag/graphics/window,
  ../../../src/frag/logger,
  ../../../src/frag/modules/graphics

import
  logo

const WIDTH = 960
const HEIGHT = 540

type
  App = ref object
    nvgCtx: ptr NVGContext

proc drawWindow(ctx: ptr NVGContext, title: string, x, y, w, h: float) =
  let cornerRadius = 3.0

  var shadowPaint: NVGPaint
  var headerPaint: NVGPaint
  
  nvgSave(ctx)

  # Window
  nvgBeginPath(ctx);
  nvgRoundedRect(ctx, x,y, w,h, cornerRadius);
  nvgFillColor(ctx, nvgRGBA(28.cuchar,30.cuchar,34.cuchar,192.cuchar) );
  #	nvgFillColor(vg, nvgRGBA(0,0,0,128) );
  nvgFill(ctx);

  # Drop shadow
  shadowPaint = nvgBoxGradient(ctx, x,y+2, w,h, cornerRadius*2, 10, nvgRGBA(0.cuchar,0.cuchar,0.cuchar,128.cuchar), nvgRGBA(0.cuchar,0.cuchar,0.cuchar,0.cuchar) )
  nvgBeginPath(ctx)
  nvgRect(ctx, x-10,y-10, w+20,h+30)
  nvgRoundedRect(ctx, x,y, w,h, cornerRadius)
  nvgPathWinding(ctx, NVG_HOLE.ord)
  nvgFillPaint(ctx, shadowPaint)
  nvgFill(ctx)

  # Header
  headerPaint = nvgLinearGradient(ctx, x,y,x,y+15, nvgRGBA(255.cuchar,255.cuchar,255.cuchar,8.cuchar), nvgRGBA(0.cuchar,0.cuchar,0.cuchar,16.cuchar) )
  nvgBeginPath(ctx)
  nvgRoundedRect(ctx, x+1,y+1, w-2,30, cornerRadius-1)
  nvgFillPaint(ctx, headerPaint)
  nvgFill(ctx)
  nvgBeginPath(ctx)
  nvgMoveTo(ctx, x+0.5f, y+0.5f+30)
  nvgLineTo(ctx, x+0.5f+w-1, y+0.5f+30)
  nvgStrokeColor(ctx, nvgRGBA(0.cuchar,0.cuchar,0.cuchar,32.cuchar) )
  nvgStroke(ctx)

  nvgFontSize(ctx, 18.0f)
  nvgFontFace(ctx, "sans-bold")
  nvgTextAlign(ctx, NVG_ALIGN_CENTER.ord or NVG_ALIGN_MIDDLE.ord)

  nvgFontBlur(ctx,2)
  nvgFillColor(ctx, nvgRGBA(0.cuchar,0.cuchar,0.cuchar,128.cuchar) )
  discard nvgText(ctx, x+w/2,y+16+1, title, nil)

  nvgFontBlur(ctx,0)
  nvgFillColor(ctx, nvgRGBA(220.cuchar,220.cuchar,220.cuchar,160.cuchar) )
  discard nvgText(ctx, x+w/2,y+16, title, nil)

  nvgRestore(ctx)

proc drawDemo(ctx: ptr NVGContext) =
  drawWindow(ctx, "Widgets `n Stuff", 50, 50, 300, 400)

proc resize*(e: EventArgs) =
  let event = SDLEventMessage(e).event
  let sdlEventData = event.sdlEventData
  # let app = cast[App](event.userData)
  let graphics = event.graphics
  graphics.setViewRect(0, 0, 0, uint16 sdlEventData.window.data1, uint16 sdlEventData.window.data2)

proc initApp(app: App, ctx: Frag) =
  logDebug "Initializing app..."
  ctx.events.on(SDLEventType.WindowResize, resize)

  discard imguiCreate()

  app.nvgCtx = nvgCreate(1, 0.cuchar)
  bgfx_set_view_seq(0, true)
  
  discard nvgCreateFont(app.nvgCtx, "sans-bold", "desktop/assets/font/roboto-bold.ttf")

  logDebug "App initialized."

proc updateApp(app:App, ctx: Frag, deltaTime: float) =
  discard

proc renderApp(app: App, ctx: Frag, deltaTime: float) =
  ctx.graphics.clearView(0, ClearMode.Color.ord or ClearMode.Depth.ord, 0x303030ff, 1.0, 0)

  let size = ctx.graphics.getSize()

  nvgBeginFrame(app.nvgCtx, size.x, size.y, 1.0f)

  drawDemo(app.nvgCtx)

  nvgEndFrame(app.nvgCtx)

proc shutdownApp(app: App, ctx: Frag) =
  logDebug "Shutting down app..."
  nvgDelete(app.nvgCtx)
  imguiDestroy()
  logDebug "App shut down."

startFrag(App(), Config(
  rootWindowTitle: "Frag Example 07-nanovg",
  rootWindowPosX: window.posUndefined, rootWindowPosY: window.posUndefined,
  rootWindowWidth: WIDTH, rootWindowHeight: HEIGHT,
  resetFlags: ResetFlag.VSync,
  logFileName: "example-00.log",
  assetRoot: "../assets",
  debugMode: BGFX_DEBUG_NONE
))