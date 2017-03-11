import bgfx, nuklear, strutils, os, parsecfg

import ../../asset, ../../texture, file_browser, project

type
  NewProjectMenu* = ref TNewProjectMenu
  TNewProjectMenu* = object
    ctx*: ref context
    projectName: string
    projectNameLen: cint
    projectLocation: string
    projectLocationLen: cint
    visible*: bool
    directoryIcon: img
    checkmarkIcon: img
    cancelIcon: img
    fileBrowser*: FileBrowser
    fileBrowserOpen*:bool

proc init*(newProjectMenu: NewProjectMenu, ctx: ref context) =
  newProjectMenu.projectNameLen = 0
  newProjectMenu.visible = false
  newProjectMenu.ctx = ctx

  #newProjectMenu.fileBrowser = newFileBrowser(newProjectMenu.ctx)
  newProjectMenu.projectLocation = newString(64)
  newProjectMenu.projectName = newString(256)

  var tex = Texture(get("assets/textures/icons/directory.png"))
  newProjectMenu.directoryIcon = image_id(cint tex.handle.idx)
  tex = Texture(get("assets/textures/icons/check.png"))
  newProjectMenu.checkmarkIcon = image_id(cint tex.handle.idx)
  tex = Texture(get("assets/textures/icons/cancel.png"))
  newProjectMenu.cancelIcon = image_id(cint tex.handle.idx)

proc createProjectFile*(fileName: string, projectName: string) : Project =
  let path = filename &  ".dtp"
  var file: File
  if file.open(path, fmWrite):
    try:
      file.writeLine("# dEngine Texture Packer v0.1 - File generated automatically. Do not modify contents.\n")
      file.writeLine("[project]")
      file.writeLine("name=" & projectName)
      file.writeLine("path=" & path)
    except:
      raise
    finally:
      file.close

  return openProject(path)


proc show*(newProjectMenu: NewProjectMenu, showWindowTitle: bool) : Project =
  if newProjectMenu.fileBrowserOpen:
    var ret = newProjectMenu.fileBrowser.show(false)
    if not ret.open:
      newProjectMenu.fileBrowserOpen = false
      newProjectMenu.visible = true
      if not ret.selected.isNil:
       newProjectMenu.projectLocation = ret.selected
       newProjectMenu.projectLocationLen = newProjectMenu.projectLocation.len.cint


  else:
    var windowFlags : uint32
    if showWindowTitle:
      windowFlags = WINDOW_TITLE.ord
    else:
      windowFlags = 0
    if beginGroup(newProjectMenu.ctx[], "New Project", windowFlags):
      var ratio = [120'f32, 225'f32, 25'f32]
      var buttonRatio = [120'f32, 120'f32]
      layoutRow(newProjectMenu.ctx[], STATIC, 25, 2, ratio)
      label(newProjectMenu.ctx[], "Project Name:", TEXT_LEFT.ord)
      discard edit_string(newProjectMenu.ctx[], EDIT_FIELD.ord, newProjectMenu.projectName, newProjectMenu.projectNameLen, 64, filter)
      layoutRow(newProjectMenu.ctx[], STATIC, 25, 3, ratio)
      label(newProjectMenu.ctx[], "Project Location:", TEXT_LEFT.ord)
      discard edit_string(newProjectMenu.ctx[], EDIT_FIELD.ord, newProjectMenu.projectLocation, newProjectMenu.projectLocationLen, 256, filter)
      if imageButton(newProjectMenu.ctx[], newProjectMenu.directoryIcon):
        newProjectMenu.fileBrowserOpen = true
        newProjectMenu.visible = false
        showWindow(newProjectMenu.ctx[], "New Project", HIDDEN)
      layoutDynamicRow(newProjectMenu.ctx[], 25, 2)
      layoutRow(newProjectMenu.ctx[], STATIC, 25, 2, buttonRatio)
      if imageLabelButton(newProjectMenu.ctx[], newProjectMenu.checkmarkIcon, "Create", TEXT_CENTERED.ord):
        var projectName : string
        shallowCopy(projectName, newProjectMenu.projectName)
        setLen(projectName, newProjectMenu.projectNameLen)

        var projectLocation : string
        shallowCopy(projectLocation, newProjectMenu.projectLocation)
        setLen(projectLocation, newProjectMenu.projectLocationLen)

        newProjectMenu.visible = false

        if not projectLocation.endsWith("/"):
          return createProjectFile(projectLocation & "/" & projectName, projectName)
        else:
          return createProjectFile(projectLocation & projectName, projectName)
      if imageLabelButton(newProjectMenu.ctx[], newProjectMenu.cancelIcon, "Cancel", TEXT_CENTERED.ord):
        newProjectMenu.visible = false
      endGroup(newProjectMenu.ctx[])