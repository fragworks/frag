import
  nake,
  os

type
  Targets = enum
    OSXDebug32, OSXDebug64, AndroidARM32

proc verifyBx(): bool =
  dirExists("vendor/bx")

proc verifyBgfx(): bool =
  dirExists("vendor/bgfx")

proc verifyDependencies(): bool =
  if verifyBx() and verifyBgfx():
    return true

proc genAndroidARMGmake() =
  if not shell("genie --with-shared-lib --gcc=android-arm gmake"):
      echo "Ensure GENie is installed before proceeding: https://github.com/bkaradzic/GENie"
  cd(".build/projects/gmake-android-arm")

proc genOSXGmake() =
  if not shell("genie --with-shared-lib --gcc=osx gmake"):
      echo "Ensure GENie is installed before proceeding: https://github.com/bkaradzic/GENie"
  cd(".build/projects/gmake-osx")

proc installBgfx(target: Targets) =
  cd("vendor/bgfx")
  case target
  of OSXDebug32:
    genOSXGmake()
    direShell("make config=debug32 bgfx-shared-lib")
  of OSXDebug64:
    genOSXGmake()
    direShell("make config=debug64 bgfx-shared-lib")
  of AndroidARM32:
    genAndroidARMGmake()
    direShell("make config=debug32 bgfx-shared-lib")

proc installDependencies(target: Targets) =
  installBgfx(target)

proc verifyAndroidEnvVars() =
  if not existsEnv("ANDROID_NDK_ROOT") or not existsEnv("ANDROID_NDK_CLANG") or not existsEnv("ANDROID_NDK_ARM"):
    echo "Please make sure ANDROID_NDK_ROOT, ANDROID_NDK_CLANG and ANDROID_NDK_ARM environment variables are set for your platform."
    quit(QUIT_SUCCESS)

if not verifyDependencies():
  echo "Ensure submodules are initialized and updated before proceeding."
  quit(QUIT_SUCCESS)

###########
# ANDROID #
###########
task "android-arm32", "Build debug versions of FRAG dependencies for ARM 32-bit instruction set":
  verifyAndroidEnvVars()
  installDependencies(AndroidARM32)

#######
# OSX #
#######
task "osx-debug32", "Build debug verisons of FRAG dependencies for OSX 32-bit instruction set":
  installDependencies(OSXDebug32)
  
task "osx-debug64", "Build debug verisons of FRAG dependencies for OSX 64-bit instruction set":
  installDependencies(OSXDebug64)