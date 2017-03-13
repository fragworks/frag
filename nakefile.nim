import nake, strutils

const
  fragBin = "src/frag"
  exDir = "examples"
  exBin = "main"

proc compile(bin: string) = shell(nimExe, "c", bin)
proc run(bin: string) = shell(nimExe, "c", "-r", bin)
proc runEx(name: string) = run(join(@[ exDir, name, exBin ], "/"))

# TODO: doesn't work because there is a directory there named what it tries to make the binary: 'frag'
task defaultTask, "Compile FRAG": compile(fragBin)

# TODO: automate, based on folders in ./examples
task "00", "Run example 00.": runEx("00-hello-world")
task "01", "Run example 01.": runEx("01-sprite-batch")
