import
  nake,
  os

type
  Targets = enum
    OSXDebug32, OSXDebug64, AndroidARM32

proc verifyBxExists(): bool =
  dirExists("vendor/bx")

proc verifyBgfxExists(): bool =
  dirExists("vendor/bgfx")

proc verifyDependenciesExist(): bool =
  if verifyBxExists() and verifyBgfxExists():
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

if not verifyDependenciesExist():
  echo "Ensure submodules are initialized and updated before proceeding."
  quit(QUIT_SUCCESS)

###########
# ANDROID #
###########
task "android-arm32", "Build debug versions of FRAG dependencies for ARM 32-bit instruction set":
  installDependencies(AndroidARM32)

#######
# OSX #
#######
task "osx-debug32", "Build debug verisons of FRAG dependencies for OSX 32-bit instruction set":
  installDependencies(OSXDebug32)
  
task "osx-debug64", "Build debug verisons of FRAG dependencies for OSX 64-bit instruction set":
  installDependencies(OSXDebug64)