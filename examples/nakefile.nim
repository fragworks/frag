import algorithm, nake, os, strutils

const
  desktopExDir = "desktop"
  androidExDir = "../platforms/android/examples"
  androidAppDir = "../platforms/android/app/src/main"
  exBin = "main"

proc run(bin: string) = 
  when defined(linux):
    direShell(nimExe, "c", "-r -d:linux", bin)
    return
  when defined(macosx):
    direShell(nimExe, "c", "-r -d:osx", bin)
    return
  when defined(windows):
    direShell(nimExe, "c", "-r -d:windows", bin)
    return
  else:
    direShell(nimExe, "c", "-r", bin)
    return

proc compile(src: string) = direShell(nimExe, "c --reportConceptFailures:on", src)

proc runDesktopExample(name: string) = run(join(@[ desktopExDir, name, exBin ], "/"))

proc clean() =
  for kind, path in walkDir(androidAppDir & "/jni/src"):
    let fileExt = splitFile(path).ext
    if fileExt  == ".c" or fileExt == ".json":
      removeFile(path)

proc compileAndroidExample(name: string) = compile(join(@[ androidExDir, name, exBin ], "/"))
proc compileJNI() =
  if not existsEnv("ANDROID_NDK_ROOT"):
    echo "Please set ANDROID_NDK_ROOT environment varaible before trying to run this task."
    return

  let ndkRoot = getEnv("ANDROID_NDK_ROOT")
  direShell(ndkRoot & "/ndk-build NDK_PROJECT_PATH=" & androidAppDir & " NDK_LIBS_OUT=" & androidAppDir & "/jniLibs")
  copyFile(ndkRoot & "/sources/cxx-stl/llvm-libc++/libs/armeabi-v7a/libc++_shared.so", androidAppDir & "/jniLibs/armeabi-v7a/libc++_shared.so")

proc registerExample(name, path: string) =
  var parts = path.split('-')
  let id = parts[0]
  parts.delete(0)
  task name[0] & id, name & " : Run example " & parts.join("-"):
    case name[0]
    of 'D':
      runDesktopExample(path)
    of 'A':
      clean()
      compileAndroidExample(path)
      compileJNI()
    else:
      discard

var desktopExamples: seq[string] = @[]
var androidExamples: seq[string] = @[]

for kind, path in walkDir(desktopExDir, true):
  if kind == pcFile or path.contains("assets"): continue
  desktopExamples.add(path)
sort(desktopExamples, cmp[string])

if dirExists("../platforms/android"):
  for kind, path in walkDir(androidExDir, true):
    if path.contains("assets"): continue
    androidExamples.add(path)
  sort(androidExamples, cmp[string])

for path in desktopExamples:
  registerExample("Desktop", path)

for path in androidExamples:
  registerExample("Android", path)
