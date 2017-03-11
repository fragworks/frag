{.experimental.}
import nuklear, glfw3 as glfw

import ../../graphics, new_project_menu, open_project_menu, project

type
  WelcomeScreen* = ref TWelcomeScreen
  TWelcomeScreen* = object
    open*: bool
    ctx*: ref context
    newProjectMenu*: NewProjectMenu
    openProjectMenu*: OpenProjectMenu
    version: string
    fileBrowserOpen*: bool

proc init*(welcomeScreen: WelcomeScreen, ctx : ref context, version: string, newProjectMenu: NewProjectMenu, openProjectMenu: OpenProjectMenu) =
  welcomeScreen.open = true
  welcomeScreen.ctx = ctx
  welcomeScreen.version = version
  welcomeScreen.newProjectMenu = newProjectMenu
  welcomeScreen.openProjectMenu = openProjectMenu
  welcomeScreen.fileBrowserOpen = false

proc showSplitView(welcomeScreen: WelcomeScreen) : Project =
  var project : Project
  var total_space = getWindowContentRegion(welcomeScreen.ctx[])
  beginSpaceLayout(welcomeScreen.ctx[], STATIC, total_space.h, 2)
  pushSpaceLayout(welcomeScreen.ctx[], newRect(0,0,total_space.w/2 - 5, total_space.h - 20))
  if beginGroup(welcomeScreen.ctx[], "Welcome Screen Options", WINDOW_NO_SCROLLBAR.ord):
    layoutDynamicRow(welcomeScreen.ctx[], 30, 1)
    if buttonLabel(welcomeScreen.ctx[], "New Project"):
      if welcomeScreen.openProjectMenu.visible:
        welcomeScreen.openProjectMenu.visible = false
        welcomeScreen.newProjectMenu.visible = true
    if buttonLabel(welcomeScreen.ctx[], "Open Project"):
      if welcomeScreen.newProjectMenu.visible:
        welcomeScreen.newProjectMenu.visible = false
        welcomeScreen.openProjectMenu.visible = true
    endGroup(welcomeScreen.ctx[])

  pushSpaceLayout(welcomeScreen.ctx[], newRect(total_space.w/2 + 5,0, total_space.w/2 - 5, total_space.h - 20))
  if welcomeScreen.newProjectMenu.visible:
    project = welcomeScreen.newProjectMenu.show(true)
  
  return project

proc showUnifiedView(welcomeScreen: WelcomeScreen) =
  layoutDynamicRow(welcomeScreen.ctx[], 30, 1)
  if buttonLabel(welcomeScreen.ctx[], "New Project"):
    welcomeScreen.newProjectMenu.visible = true
  if buttonLabel(welcomeScreen.ctx[], "Open Project"):
    welcomeScreen.openProjectMenu.visible = true

proc show*(welcomeScreen: WelcomeScreen) : Project =
  var project : Project
  if not welcomeScreen.newProjectMenu.fileBrowserOpen and not welcomeScreen.openProjectMenu.visible:
    welcomeScreen.fileBrowserOpen = false
    var w, h: cint
    glfw.GetWindowSize(graphics.rootWindow, addr w, addr h)
    if welcomeScreen.ctx.open("Welcome to dEngine Texture Packer " & welcomeScreen.version, newRect(50, 50, cfloat w - 100, cfloat h - 100), WINDOW_BORDER.ord or WINDOW_CLOSABLE.ord or WINDOW_NO_SCROLLBAR.ord):
      #var canvas = window_get_canvas(welcomeScreen.ctx)
      if welcomeScreen.newProjectMenu.visible:
        project = showSplitView(welcomeScreen)
      else:
        showUnifiedView(welcomeScreen)


    else:
      welcomeScreen.open = false
      welcomeScreen.newProjectMenu.visible = false
      welcomeScreen.openProjectMenu.visible = false

    welcomeScreen.ctx[].close()
  elif welcomeScreen.openProjectMenu.visible:
    showWindow(welcomeScreen.ctx[], "Welcome to dEngine Texture Packer " & welcomeScreen.version, HIDDEN)
    project = welcomeScreen.openProjectMenu.show()
  else:
    showWindow(welcomeScreen.ctx[], "Welcome to dEngine Texture Packer " & welcomeScreen.version, HIDDEN)
    project = welcomeScreen.newProjectMenu.show(true)
    welcomeScreen.fileBrowserOpen = welcomeScreen.newProjectMenu.fileBrowserOpen

  return project
