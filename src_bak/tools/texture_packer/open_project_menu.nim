import nuklear

import file_browser, project

type
  OpenProjectMenu* = ref TOpenProjectMenu
  TOpenProjectMenu* = object
    ctx*: ref context
    visible*: bool
    fileBrowser*: FileBrowser
    fileBrowserOpen*: bool

proc init*(openProjectMenu: OpenProjectMenu, ctx: ref context) =
  openProjectMenu.visible = false
  openProjectMenu.ctx = ctx
  #openProjectMenu.fileBrowser = newFileBrowser(openProjectMenu.ctx)
  
proc show*(openProjectMenu: OpenProjectMenu) : Project =
  var ret = openProjectMenu.fileBrowser.show(true, ".dtp")
  if not ret.open:
    openProjectMenu.visible = false
    return openProject(ret.selected)