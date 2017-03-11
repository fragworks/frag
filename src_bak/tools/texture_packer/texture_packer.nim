import bgfx, nuklear, glfw3 as glfw

import 
  ../../dEngine
  , ../../asset
  , ../../gui/backend/nuklear_bgfx as nukbgfx
  , ../../gui/backend/nuklear_themes
  , ../../graphics
  , ../../app
  , ../../log
  , welcome_screen
  , main_menu
  , main_window
  , new_project_menu
  , open_project_menu
  , project

var engine : DEngine

let version = "v0.0.1"

type
  TexturePacker = ref object of AbstractApp
    background: color
    initialized: bool
    projectOpen: bool
    welcomeScreen: WelcomeScreen
    mainMenu: MainMenu
    mainWindow: MainWindow
    newProjectMenu: NewProjectMenu
    openProjectMenu: OpenProjectMenu
    project: Project
    nkbgfx: NuklearBGFX

var texturePacker : TexturePacker

proc init*(texturePacker: Texturepacker) =
  logInfo "Initializing dEngine texture packer..."

  logInfo "Loading textures..."
  load "assets/textures/icons/directory.png"
  load "assets/textures/icons/file.png"
  load "assets/textures/icons/check.png"
  load "assets/textures/icons/cancel.png"
  load "assets/textures/icons/home.png"
  load "assets/textures/icons/desktop.png"
  load "assets/textures/icons/computer.png"

  texturePacker.background = newColorRGB(48, 48, 48)

  texturePacker.nkbgfx = NuklearBGFX()
  texturePacker.nkbgfx.init()
  texturePacker.nkbgfx.setStyle(WHITE)

  texturePacker.newProjectMenu = NewProjectMenu()
  texturePacker.newProjectMenu.init(texturePacker.nkbgfx.ctx)
  
  texturePacker.openProjectMenu = OpenProjectMenu()
  texturePacker.openProjectMenu.init(texturePacker.nkbgfx.ctx)

  texturePacker.welcomeScreen = WelcomeScreen()
  texturePacker.welcomeScreen.init(texturePacker.nkbgfx.ctx, version, texturePacker.newProjectMenu, texturePacker.openProjectMenu)

  #[texturePacker.mainMenu = newMainMenu(
    nkbgfx.ctx
    , addr texturePacker.newProjectMenu
    , addr texturePacker.openProjectMenu
  )

  texturePacker.mainWindow = newMainWindow()
]#
  texturePacker.initialized = true
  

proc dispose(texturePacker: TexturePacker) =
  unload("assets/textures/icons/directory.png")
  unload("assets/textures/icons/file.png")
  unload("assets/textures/icons/check.png")
  unload("assets/textures/icons/cancel.png")
  unload("assets/textures/icons/home.png")
  unload("assets/textures/icons/desktop.png")
  unload("assets/textures/icons/computer.png")
  dispose(texturePacker.nkbgfx)

proc updateProject*(texturePacker: TexturePacker, project: Project) =
  if not project.name.isNil:
    texturePacker.project = project
    texturePacker.projectOpen = true

proc openNewProjectMenu(texturePacker: TexturePacker, total_space: var rect) =
  if texturePacker.nkbgfx.ctx.open("New Project", newRect(total_space.x + 100, total_space.y + 100, total_space.w - 200, total_space.h - 200), WINDOW_TITLE.ord or WINDOW_NO_SCROLLBAR.ord or WINDOW_CLOSABLE.ord):
    totalSpace = getWindowContentRegion(texturePacker.nkbgfx.ctx)
    layoutDynamicRow(texturePacker.nkbgfx.ctx, total_space.h - 10, 1)
    
    texturePacker.updateProject(newProjectMenu.show(texturePacker.newProjectMenu, false))

  else:
    texturePacker.newProjectMenu.visible = false
  texturePacker.nkbgfx.ctx.close()

#proc openFileBrowser(texturePacker: TexturePacker) =
#  texturePacker.updateProject(newProjectMenu.show(addr texturePacker.newProjectMenu, false))]#

proc update(texturePacker: TexturePacker, deltaTime: float) =
  discard
  texturePacker.nkbgfx.bgfx_new_frame()
  if texturePacker.initialized:
    if (texturePacker.welcomeScreen.open or texturePacker.welcomeScreen.fileBrowserOpen) and texturePacker.project.name.isNil:
      texturePacker.updateProject(texturePacker.welcomeScreen.show())
      
    else:
      var w, h: cint
      glfw.GetWindowSize(graphics.rootWindow, addr w, addr h)
      var totalSpace : rect
      var windowTitle : string
      if not texturePacker.project.name.isNil:
        windowTitle = "dEngine Texture Packer " & version & " - " &  texturePacker.project.name
      else:
        windowTitle = "dEngine Texture Packer " & version
      if texturePacker.nkbgfx.ctx.open(windowTitle, newRect(0, 0, cfloat w, cfloat h), WINDOW_TITLE.ord):
        total_space = getWindowContentRegion(texturePacker.nkbgfx.ctx)
        if texturePacker.mainMenu.visible:
          texturePacker.mainMenu.show()
          texturePacker.mainWindow.show(total_space)
        texturePacker.nkbgfx.ctx.close()
        if texturePacker.newProjectMenu.visible:
          openNewProjectMenu(texturePacker, totalSpace)
        elif texturePacker.openProjectMenu.visible:
          texturePacker.updateProject(openProjectMenu.show(texturePacker.openProjectMenu))
        else:
          discard
          #if texturePacker.newProjectMenu.fileBrowserOpen:
            #texturePacker.openFileBrowser(texturePacker)

proc render(texturePacker: TexturePacker, deltaTime: float) =
  discard
  bgfx.SetViewClear(0, BGFX_CLEAR_COLOR or BGFX_CLEAR_DEPTH, 0x303030ff, 1.0, 0)
  if texturePacker.initialized:
    texturePacker.nkbgfx.render()

proc toTexturePacker*(texturePacker: TexturePacker) : IApp =
  return (
    init:      proc() = texturePacker.init()
    , update:  proc(deltaTime: float) = texturePacker.update(deltaTime)
    , render:  proc(deltaTime: float) = texturePacker.render(deltaTime)
    , dispose: proc() = texturePacker.dispose()
  )

texturePacker = TexturePacker()
texturePacker.initialized = false
engine = newDEngine(toTexturePacker(texturePacker), false)
engine.start()