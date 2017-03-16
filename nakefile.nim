import nake, os, strutils

const
  fragBin = "src/frag"
  exDir = "examples/desktop"
  exBin = "main"

proc compile(bin: string) = direShell(nimExe, "c", bin)
proc run(bin: string) = direShell(nimExe, "c", "-r", bin)
proc runExample(name: string) = run(join(@[ exDir, name, exBin ], "/"))

proc registerExample(name, path: string) =
  var parts = path.split('-')
  let id = parts[0]
  parts.delete(0)
  task id, name & " - run example " & parts.join("-"):
    runExample(path)

for kind, path in walkDir("examples/desktop", true):
  if path.contains("assets"):
    continue
  registerExample("Desktop", path)
