import nuklear

type
  MainWindow* = ref TMainWIndow
  TMainWindow* = object
  
proc newMainWindow*() : MainWindow =
  result = MainWindow()

proc show*(mainWindow: MainWindow, totalSpace: rect) =
  discard