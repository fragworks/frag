import strutils

proc runJS(bin: string) = 
  exec("nim js --threads:off --verbosity:3 $1 > out.txt" % bin)

proc run(bin: string) = 
  when defined(linux):
    exec("nim c -r -d:linux $1" % bin)
    return
  when defined(macosx):
    exec("nim c -r -d:osx $1" % bin)
    return
  when defined(windows):
    exec("nim c -r -d:windows $1" % bin)
    return
  else:
    exec("nim c -r $1" % bin)
    return

task tasks, "List Tasks":
  echo "D00 : Desktop - Hello World"
  echo "D01 : Desktop - Sprite Batch"
  echo "D02 : Desktop - Audio"
  echo "D03 : Desktop - Input"
  echo "D04 : Desktop - Sprite Animation"
  echo "D05 : Desktop - GUI"
  echo "D06 : Desktop - Physics"
  echo "D07 : Desktop - NanoVG"

task D00, "Desktop - Hello World":
  run("desktop/00-hello-world/main.nim")

task D01, "Desktop - Sprite Batch":
  run("desktop/01-sprite-batch/main.nim")

task D02, "Desktop - Audio":
  run("desktop/02-audio/main.nim")

task D03, "Desktop - Input":
  run("desktop/03-input/main.nim")

task D04, "Desktop - Sprite Animation":
  run("desktop/04-sprite-animation/main.nim")

task D05, "Desktop - GUI":
  run("desktop/05-gui/main.nim")

task D06, "Desktop - Physics":
  run("desktop/06-physics/main.nim")

task D07, "Desktop - NanoVG":
  run("desktop/07-nanovg/main.nim")

task D08, "HTML5":
  runJS("desktop/08-html5/main.nim")