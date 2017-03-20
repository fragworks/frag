import algorithm, nake, os, strutils

const
  fragBin = "src/frag"
  desktopExDir = "examples/desktop"
  androidExDir = "examples/android"
  exBin = "main"

proc compile(bin: string) = direShell(nimExe, "c", bin)
proc run(bin: string) = direShell(nimExe, "c", "-r", bin)
proc runDesktopExample(name: string) = run(join(@[ desktopExDir, name, exBin ], "/"))
proc runAndroidExample(name: string) = run(join(@[ androidExDir, name, exBin ], "/"))

proc registerExample(name, path: string) =
  var parts = path.split('-')
  let id = parts[0]
  parts.delete(0)
  task name[0] & id, name & " : run example " & parts.join("-"):
    case name[0]
    of 'D':
      runDesktopExample(path)
    of 'A':
      runAndroidExample(path)
    else:
      discard

var desktopExamples: seq[string] = @[]
var androidExamples: seq[string] = @[]

for kind, path in walkDir("examples/desktop", true):
  if path.contains("assets"): continue
  desktopExamples.add(path)
sort(desktopExamples, cmp[string])

for kind, path in walkDir("examples/android", true):
  if path.contains("assets"): continue
  androidExamples.add(path)
sort(androidExamples, cmp[string])

for path in desktopExamples:
  registerExample("Desktop", path)

for path in androidExamples:
  registerExample("Android", path)
