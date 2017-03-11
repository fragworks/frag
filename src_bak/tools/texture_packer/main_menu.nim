import nuklear, glfw3 as glfw

import ../../graphics, new_project_menu, open_project_menu

type
  MainMenu* = ref TMainMenu
  TMainMenu* = object
    visible*: bool
    ctx*: ref context
    newProjectMenu*: ptr NewProjectMenu
    openProjectMenu*: ptr OpenProjectMenu

proc newMainMenu*(ctx : ref context, newProjectMenu: ptr NewProjectMenu, openProjectMenu: ptr OpenProjectMenu) : MainMenu =
  result = MainMenu()
  result.visible = true
  result.newProjectMenu = newProjectMenu
  result.openProjectMenu = openProjectMenu
  result.ctx = ctx

proc show*(mainMenu: var MainMenu) =
  openMenubar(mainMenu.ctx[])
  beginRowLayout(mainMenu.ctx[], STATIC, 25, 3)
  pushRowLayout(mainMenu.ctx[], 45)
  if beginMenuLabel(mainMenu.ctx[], "File", TEXT_LEFT.ord, newVec2(120, 200)):
    layoutDynamicRow(mainMenu.ctx[], 25, 1)
    if menuItemLabel(mainMenu.ctx[], "New Project", TEXT_LEFT.ord):
      mainMenu.newProjectMenu.visible = true
    if menuItemLabel(mainMenu.ctx[], "Open Project", TEXT_LEFT.ord):
      mainMenu.openProjectMenu.visible = true
    if menuItemLabel(mainMenu.ctx[], "Quit", TEXT_LEFT.ord):
      glfw.SetWindowShouldClose(graphics.rootWindow, 1)
    endMenu(mainMenu.ctx[])
  if beginMenuLabel(mainMenu.ctx[], "Edit", TEXT_LEFT.ord, newVec2(120, 200)):
    layoutDynamicRow(mainMenu.ctx[], 25, 1)
    if menuItemLabel(mainMenu.ctx[], "New Project", TEXT_LEFT.ord):
      discard
    endMenu(mainMenu.ctx[])
  if beginMenuLabel(mainMenu.ctx[], "Help", TEXT_LEFT.ord, newVec2(120, 200)):
    layoutDynamicRow(mainMenu.ctx[], 25, 1)
    if menuItemLabel(mainMenu.ctx[], "About", TEXT_LEFT.ord):
      discard
    endMenu(mainMenu.ctx[])
  closeMenubar(mainMenu.ctx[])