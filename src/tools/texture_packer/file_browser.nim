import nuklear, glfw3 as glfw, os, posix, tables, strutils

import ../../graphics, ../../asset, ../../texture

type
  FileBrowser* = object
    ctx: ptr context
    file: string
    home: string
    desktop: string
    directory: string
    directories: seq[string]
    files: seq[string]
    filesAsButtons: bool
    filters: seq[string]
    homeImage: img
    desktopImage: img
    computerImage: img
    directoryImage: img
    fileImage: img
    newFolderPopupOpen: bool
    newFolderName: string
    newFolderNameLen: cint

var ratio = [0.25'f32, 0.75'f32]

proc walkDirectory*(fileBrowser: var FileBrowser) =
  fileBrowser.files.setLen(0)
  fileBrowser.directories.setLen(0)
  for kind, path in walkDir(fileBrowser.directory):
    let (_, name, ext) = splitFile(path)
    let (_, tail) = splitPath(path)
    if kind == pcDir:
      fileBrowser.directories.add(tail & "/")
    elif kind == pcFile:
      if fileBrowser.filters.len > 0:
        if fileBrowser.filters.contains(ext):
          fileBrowser.files.add(name & ext)
      else:
        fileBrowser.files.add(name & ext)

proc reloadDirectoryContent*(fileBrowser: var FileBrowser, path: string) =
  fileBrowser.directory = path
  fileBrowser.directories.setLen(0)
  fileBrowser.files.setLen(0)
  walkDirectory(fileBrowser)

proc initFileBrowser*(fileBrowser: var FileBrowser) =
  fileBrowser.newFolderName = newString(64)
  var tex = Texture get("assets/textures/icons/home.png")
  fileBrowser.homeImage = image_id(cint tex.handle.idx)
  tex = Texture get("assets/textures/icons/desktop.png")
  fileBrowser.desktopImage = image_id(cint tex.handle.idx)
  tex = Texture get("assets/textures/icons/computer.png")
  fileBrowser.computerImage = image_id(cint tex.handle.idx)
  tex = Texture get("assets/textures/icons/directory.png")
  fileBrowser.directoryImage = image_id(cint tex.handle.idx)
  tex = Texture get("assets/textures/icons/file.png")
  fileBrowser.fileImage = image_id(cint tex.handle.idx)
  
  fileBrowser.home = getEnv("HOME")

  if fileBrowser.home.isNil:
    fileBrowser.home = $getpwuid(getuid()).pw_dir

  fileBrowser.home.add("/")
  fileBrowser.directory = getCurrentDir() & "/"
  fileBrowser.desktop = fileBrowser.home & "desktop"

  fileBrowser.directories = @[]
  fileBrowser.files = @[]
  walkDirectory(fileBrowser)
  

proc newFileBrowser*(ctx: ptr context) : FileBrowser =
  result = FileBrowser()
  result.ctx = ctx
  initFileBrowser(result)


proc drawBreadCrumb*(fileBrowser: var FileBrowser) =
  openMenubar(fileBrowser.ctx[])
  layoutDynamicRow(fileBrowser.ctx[], 25, 6)
  if buttonLabel(fileBrowser.ctx[], "/"):
    reloadDirectoryContent(fileBrowser, "/")
    

  var directories : seq[string] = @[]
  var currentSplitPath = splitPath(fileBrowser.directory)
  var directory = currentSplitPath[1] 
  var pathLeft = currentSplitPath[0]
  while not(pathLeft == ""):
    directories.add(pathLeft & "/" & directory)
    currentSplitPath = splitPath(pathLeft)
    directory = currentSplitPath[1] 
    pathLeft = currentSplitPath[0]
  
  if not(directory == ""):
    if buttonLabel(fileBrowser.ctx[], directory):
      reloadDirectoryContent(fileBrowser, "/" & directory & "/")

  for i in countdown(high(directories), 0):
    if not(splitPath(directories[i]).tail == ""):
      if buttonLabel(fileBrowser.ctx[], splitPath(directories[i])[1]):
        reloadDirectoryContent(fileBrowser, directories[i])
  
  closeMenubar(fileBrowser.ctx[])

proc openNewFolderPopup(fileBrowser: var FileBrowser) =
  let totalSpace : rect = getWindowContentRegion(fileBrowser.ctx[])
  let halfWidth = totalSpace.w / 2
  let halfHeight = totalSpace.h / 2
  let rect = newRect(halfWidth / 2, halfHeight / 2, halfWidth, halfHeight )
  
  if beginPopup(fileBrowser.ctx[], POPUP_STATIC, "New Folder", WINDOW_CLOSABLE.ord, rect):
    var ratio = [120.0'f32, 225.0'f32]
    layoutDynamicRow(fileBrowser.ctx[], 20, 1)
    layoutRow(fileBrowser.ctx[], STATIC, 25, 2, ratio)
    label(fileBrowser.ctx[], "Folder Name:", TEXT_LEFT.ord)
    discard edit_string(fileBrowser.ctx[], EDIT_FIELD.ord, fileBrowser.newFolderName, fileBrowser.newFolderNameLen, 64, nuklear.filter)
    
    layoutDynamicRow(fileBrowser.ctx[], 20, 1)
    layoutDynamicRow(fileBrowser.ctx[], 20, 1)
    if buttonLabel(fileBrowser.ctx[], "Create"):
      var newFolderName = fileBrowser.directory
      newFolderName.add(fileBrowser.newFolderName)
      if not existsDir(newFolderName):
        createDir(newFolderName)
      closePopup(fileBrowser.ctx[])
      fileBrowser.newFolderPopupOpen = false
      reloadDirectoryContent(fileBrowser, fileBrowser.directory)
    endPopup(fileBrowser.ctx[])
  else:
    fileBrowser.newFolderPopupOpen = false

proc drawButonGroup(fileBrowser: var FileBrowser, totalSpace: rect) : bool =
  layoutRow(fileBrowser.ctx[], DYNAMIC, total_space.h, 2, ratio)
  discard beginGroup(fileBrowser.ctx[], "Special", WINDOW_NO_SCROLLBAR.ord)
  layoutDynamicRow(fileBrowser.ctx[], 40, 1)
  if imageLabelButton(fileBrowser.ctx[], fileBrowser.homeImage, "home", TEXT_CENTERED.ord):
    reloadDirectoryContent(fileBrowser, fileBrowser.home)
  if imageLabelButton(fileBrowser.ctx[], fileBrowser.desktopImage, "desktop", TEXT_CENTERED.ord):
    reloadDirectoryContent(fileBrowser, fileBrowser.desktop)
  if imageLabelButton(fileBrowser.ctx[], fileBrowser.computerImage, "computer", TEXT_CENTERED.ord):
    reloadDirectoryContent(fileBrowser, "/")
  layoutDynamicRow(fileBrowser.ctx[], 40, 1)
  layoutDynamicRow(fileBrowser.ctx[], 20, 1)
  if not fileBrowser.filesAsButtons:
    if buttonLabel(fileBrowser.ctx[], "Select"):
      return true
    if buttonLabel(fileBrowser.ctx[], "New Folder"):
      fileBrowser.newFolderPopupOpen = true
  endGroup(fileBrowser.ctx[])

proc drawContent(fileBrowser: var FileBrowser, totalSpace: rect, close: var bool) =
  discard beginGroup(fileBrowser.ctx[], "Content", 0)
    
  var i, j, k = 0
  var rows, cols = 0
  let count = fileBrowser.directories.len + fileBrowser.files.len

  cols = 6
  rows = count div cols

  for i in 0..rows:
    var n = j + cols
    layoutDynamicRow(fileBrowser.ctx[], 75.0, cols.cint)
    while j < count and j < n:
      if j < fileBrowser.directories.len:
        if imageButton(fileBrowser.ctx[], fileBrowser.directoryImage):
          reloadDirectoryContent(fileBrowser, fileBrowser.directory & fileBrowser.directories[j])
      else:
        if not fileBrowser.filesAsButtons:
          image(fileBrowser.ctx[], fileBrowser.fileImage)
        else:
          if imageButton(fileBrowser.ctx[], fileBrowser.fileImage):
            fileBrowser.file = fileBrowser.files[j - fileBrowser.directories.len]
            close = true
      inc(j)

    n = k + cols
    layoutDynamicRow(fileBrowser.ctx[], 20, cols.cint)
    while k < count and k < n:
      if k < fileBrowser.directories.len:
        label(fileBrowser.ctx[], fileBrowser.directories[k], TEXT_CENTERED.ord)
      else:
        let t = k - fileBrowser.directories.len
        if fileBrowser.files.len > t:
          label(fileBrowser.ctx[], fileBrowser.files[t], TEXT_CENTERED.ord)
      inc(k)

  endGroup(fileBrowser.ctx[])


proc drawWindowLayout(fileBrowser: var FileBrowser) : bool =
  var totalSpace = getWindowContentRegion(fileBrowser.ctx[])
  var close = drawButonGroup(fileBrowser, totalSpace)
  drawContent(fileBrowser, totalSpace, close)
  return close

proc show*(fileBrowser: var FileBrowser, filesAsButtons: bool, filters: varargs[string]) : tuple[selected: string, open: bool] =
  fileBrowser.filesAsButtons = filesAsButtons
  fileBrowser.filters = @filters

  if fileBrowser.filters.len > 0:
    walkDirectory(fileBrowser)

  var w, h: cint
  glfw.GetWindowSize(graphics.rootWindow, addr w, addr h)
  if fileBrowser.ctx[].open("File Browser", newRect(100, 100, cfloat w - 200, cfloat h - 200), uint32 WINDOW_BORDER.ord or WINDOW_CLOSABLE.ord or WINDOW_NO_SCROLLBAR.ord):
    if fileBrowser.newFolderPopupOpen:
      openNewFolderPopup(fileBrowser)
      fileBrowser.ctx[].close()
      return (fileBrowser.directory, true)
      
    else:
      let spacingX = fileBrowser.ctx.style.window.spacing.x
      fileBrowser.ctx.style.window.spacing.x = 0
      drawBreadCrumb(fileBrowser)
      fileBrowser.ctx.style.window.spacing.x = spacingX

      var close = drawWindowLayout(fileBrowser)

      fileBrowser.ctx[].close()

      if close:
        showWindow(fileBrowser.ctx[], "File Browser", HIDDEN)
        if fileBrowser.filesAsButtons:
          return (fileBrowser.directory & fileBrowser.file, false)  
        else:
          return (fileBrowser.directory, false)  

      return (fileBrowser.directory, true)
  
  fileBrowser.ctx[].close()
  fileBrowser.directory = getCurrentDir() & "/"
  reloadDirectoryContent(fileBrowser, fileBrowser.directory)
  return (nil, false)