import algorithm, nake, os, strutils

const
  desktopExDir = "desktop"
  androidExDir = "android"
  androidAppDir = "../android/app/src/main"
  exBin = "main"

proc run(bin: string) = direShell(nimExe, "c", "-r", bin)
proc runDesktopExample(name: string) = run(join(@[ desktopExDir, name, exBin ], "/"))

proc clean() =
  for kind, path in walkDir(androidAppDir & "/jni/src"):
    let fileExt = splitFile(path).ext
    if fileExt  == ".c" or fileExt == ".json":
      removeFile(path)

proc compileAndroidExample(name: string) = run(join(@[ androidExDir, name, exBin ], "/"))
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
  task name[0] & id, name & " : run example " & parts.join("-"):
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

for kind, path in walkDir("desktop", true):
  if path.contains("assets"): continue
  desktopExamples.add(path)
sort(desktopExamples, cmp[string])

for kind, path in walkDir("android", true):
  if path.contains("assets"): continue
  androidExamples.add(path)
sort(androidExamples, cmp[string])

for path in desktopExamples:
  registerExample("Desktop", path)

for path in androidExamples:
  registerExample("Android", path)
