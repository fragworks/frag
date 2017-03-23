import
  nake,
  os,
  strutils

type
  Targets = enum
    AndroidARMDebug32, LinuxDebug32, LinuxDebug64, OSXDebug32, OSXDebug64, WinDebug32, WinDebug64, 

proc verifyBx(): bool =
  dirExists("vendor/bx/scripts")

proc verifyBgfx(): bool =
  dirExists("vendor/bgfx/scripts")

proc verifyDependencies(): bool =
  if verifyBx() and verifyBgfx():
    return true

proc genGmakeProjectsAndCd(gcc: string) =
  if not shell("genie --with-shared-lib --gcc=$1 gmake" % gcc):
      echo "Ensure GENie is installed before proceeding: https://github.com/bkaradzic/GENie"
  if not(gcc == "mingw-gcc"):
    cd(".build/projects/gmake-$1" % gcc.replace("-gcc", ""))
  else:
    cd(".build/projects/gmake-$1" % gcc)

proc installBgfx(target: Targets) =
  cd("vendor/bgfx")
  case target
  of AndroidARMDebug32:
    genGmakeProjectsAndCd("android-arm")
    direShell("make config=debug32 bgfx-shared-lib")
  of OSXDebug32:
    genGmakeProjectsAndCd("osx")
    direShell("make config=debug32 bgfx-shared-lib")
  of OSXDebug64:
    genGmakeProjectsAndCd("osx")
    direShell("make config=debug64 bgfx-shared-lib")
  of LinuxDebug32:
    genGmakeProjectsAndCd("linux-gcc")
    direShell("make config=debug32 bgfx-shared-lib")
  of LinuxDebug64:
    genGmakeProjectsAndCd("linux-gcc")
    direShell("make config=debug64 bgfx-shared-lib")
  of WinDebug32:
    genGmakeProjectsAndCd("mingw-gcc")
    direShell("make config=debug32 bgfx-shared-lib")
  of WinDebug64:
    genGmakeProjectsAndCd("mingw-gcc")
    direShell("make config=debug64 bgfx-shared-lib")

proc installDependencies(target: Targets) =
  installBgfx(target)

proc verifyAndroidEnvVars() =
  if not existsEnv("ANDROID_NDK_ROOT") or not existsEnv("ANDROID_NDK_CLANG") or not existsEnv("ANDROID_NDK_ARM"):
    echo "Please make sure ANDROID_NDK_ROOT, ANDROID_NDK_CLANG and ANDROID_NDK_ARM environment variables are set for your platform."
    quit(QUIT_SUCCESS)

if not verifyDependencies():
  echo "Ensure submodules are initialized and updated before proceeding - |$ git submodule update --init --recursive"
  quit(QUIT_SUCCESS)

###########
# ANDROID #
###########
task "android-arm-debug32", "Build debug versions of FRAG dependencies for ARM 32-bit instruction set":
  verifyAndroidEnvVars()
  installDependencies(AndroidARMDebug32)

#########
# LINUX #
#########
task "linux-debug32", "Build debug verisons of FRAG dependencies for Linux 32-bit instruction set":
  installDependencies(LinuxDebug32)
  
task "linux-debug64", "Build debug verisons of FRAG dependencies for Linux 64-bit instruction set":
  installDependencies(LinuxDebug64)

#######
# OSX #
#######
task "osx-debug32", "Build debug verisons of FRAG dependencies for OSX 32-bit instruction set":
  installDependencies(OSXDebug32)
  
task "osx-debug64", "Build debug verisons of FRAG dependencies for OSX 64-bit instruction set":
  installDependencies(OSXDebug64)

###########
# WINDOWS #
###########
task "win-debug32", "Build debug verisons of FRAG dependencies for Windows 32-bit instruction set":
  installDependencies(WinDebug32)
  
task "win-debug64", "Build debug verisons of FRAG dependencies for Windows 64-bit instruction set":
  installDependencies(WinDebug64)