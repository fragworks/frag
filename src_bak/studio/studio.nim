import bgfx, nuklear, glfw3 as glfw

import 
  ../dEngine
  , ../gui/backend/nuklear_bgfx
  , ../graphics
  , ../app
  , ../log

var engine : DEngine

type
  Studio = ref object of AbstractApp
    nkbgfx: NuklearBGFX
    background: nk_color
    initialized: bool
    welcomeScreenOpen: bool
    projectOpen: bool

var studio {.global.} : Studio

proc init*(studio: Studio) =
  logInfo("Initializing dEngine studio...")
  studio.background = nk_rgb(48, 48, 48)
  nk_bgfx_init(addr studio.nkbgfx)
  studio.initialized = true


proc showWelcomeScreen() =
  var w, h: cint
  glfw.GetWindowSize(graphics.rootWindow, addr w, addr h)
  if nk_begin(addr studio.nkbgfx.ctx, "dEngine Studio", nk_rect(50, 50, cfloat w - 100, cfloat h - 100), uint32 NK_WINDOW_BORDER.ord or NK_WINDOW_CLOSABLE.ord) == 1:
    nk_layout_row_dynamic(addr studio.nkbgfx.ctx, 30, 1);
    nk_label(addr studio.nkbgfx.ctx, "Welcome to dEngine Studio!", NK_TEXT_CENTERED.ord);
    

    #discard nk_group_begin(addr studio.nkbgfx.ctx, "WelcomeMenu", NK_WINDOW_BORDER.ord)

    nk_layout_row_dynamic(addr studio.nkbgfx.ctx, 30, 2)
    if nk_button_label(addr studio.nkbgfx.ctx, "New Project") == 1:
      echo "New project clicked!"

    nk_layout_row_dynamic(addr studio.nkbgfx.ctx, 30, 2)
    if nk_button_label(addr studio.nkbgfx.ctx, "Open Project") == 1:
      echo "Open project clicked!"
    #nk_group_end(addr studio.nkbgfx.ctx)
  else:
    studio.welcomeScreenOpen = false

  
  nk_end(addr studio.nkbgfx.ctx)

proc dispose(studio: Studio) =
  studio.nkbgfx.dispose()
  #glfw.SetWindowShouldClose(graphics.rootWindow, true.cint)

proc update(studio: Studio, deltaTime: float) =
  if studio.initialized:
    if studio.welcomeScreenOpen:
      showWelcomeScreen()
    elif not studio.projectOpen:
      glfw.SetWindowShouldClose(graphics.rootWindow, true.cint)
    studio.nkbgfx.nk_bgfx_new_frame()

proc render(studio: Studio, deltaTime: float) =
  bgfx.SetViewClear(0, BGFX_CLEAR_COLOR or BGFX_CLEAR_DEPTH, 0x303030ff, 1.0, 0)
  if studio.initialized:
    studio.nkbgfx.nk_bgfx_render()
  
proc newStudio() : Studio =
  result = Studio()

proc toStudio*(studio: Studio) : IApp =
  return (
    init:      proc() = studio.init()
    , update:  proc(deltaTime: float) = studio.update(deltaTime)
    , render:  proc(deltaTime: float) = studio.render(deltaTime)
    , dispose: proc() = studio.dispose()
  )

studio = newStudio()
studio.initialized = false
studio.welcomeScreenOpen = true
engine = newDEngine(toStudio(studio), false)
engine.start()