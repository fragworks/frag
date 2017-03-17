import algorithm, nake, os, strutils

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

var examples: seq[string] = @[]
for kind, path in walkDir("examples/desktop", true):
  if path.contains("assets"): continue
  examples.add(path)
sort(examples, cmp[string])

for path in examples:
  registerExample("Desktop", path)
