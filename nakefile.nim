import nake, os, strutils

const
  fragBin = "src/frag"
  exDir = "examples"
  exBin = "main"

proc compile(bin: string) = shell(nimExe, "c", bin)
proc run(bin: string) = shell(nimExe, "c", "-r", bin)
proc runEx(name: string) = run(join(@[ exDir, name, exBin ], "/"))

for kind, path in walkDir("examples", true):
  var parts = path.split('-')
  let id = parts[0]
  parts.del(0)
  task id, "Run example " & parts.join("-"): runEx(path)
