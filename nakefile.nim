import nake, os, strutils

const
  fragBin = "src/frag"
  exDir = "examples"
  exBin = "main"

proc compile(bin: string) = direShell(nimExe, "c", bin)
proc run(bin: string) = direShell(nimExe, "c", "-r", bin)
proc runExample(name: string) = run(join(@[ exDir, name, exBin ], "/"))

proc registerExample(path: string) =
  var parts = path.split('-')
  let id = parts[0]
  parts.delete(0)
  task id, "Run example " & parts.join("-"):
    runExample(path)

for kind, path in walkDir("examples", true):
  registerExample(path)
