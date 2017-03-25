import
  nake,
  os,
  strutils

type
  Targets = enum
    AndroidARMDebug32, LinuxDebug32, LinuxDebug64, OSXDebug32, OSXRelease32, OSXRelease64, OSXDebug64, WinDebug32, WinDebug64, WinRelease32, WinRelease64

proc verifyBx(): bool =
  dirExists("vendor/bx/scripts")

proc verifyBgfx(): bool =
  dirExists("vendor/bgfx/scripts")

proc verifyDependencies(): bool =
  if verifyBx() and verifyBgfx():
    return true

proc genGmakeProjectsAndCd(gcc: string) =
  if not shell("genie --with-shared-lib --with-tools --gcc=$1 gmake" % gcc):
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
    direShell("make config=debug32 bgfx-shared-lib shaderc")
  of OSXDebug32:
    genGmakeProjectsAndCd("osx")
    direShell("make config=debug32 bgfx-shared-lib shaderc")
  of OSXDebug64:
    genGmakeProjectsAndCd("osx")
    direShell("make config=debug64 bgfx-shared-lib shaderc")
  of OSXRelease32:
    genGmakeProjectsAndCd("osx")
    direShell("make config=release32 bgfx-shared-lib shaderc")
  of OSXRelease64:
    genGmakeProjectsAndCd("osx")
    direShell("make config=release64 bgfx-shared-lib shaderc")
  of LinuxDebug32:
    genGmakeProjectsAndCd("linux-gcc")
    direShell("make config=debug32 bgfx-shared-lib shaderc")
  of LinuxDebug64:
    genGmakeProjectsAndCd("linux-gcc")
    direShell("make config=debug64 bgfx-shared-lib shaderc")
  of WinDebug32:
    genGmakeProjectsAndCd("mingw-gcc")
    direShell("make config=debug32 bgfx-shared-lib shaderc")
  of WinDebug64:
    genGmakeProjectsAndCd("mingw-gcc")
    direShell("make config=debug64 bgfx-shared-lib shaderc")
  of WinRelease32:
    genGmakeProjectsAndCd("mingw-gcc")
    direShell("make config=release32 bgfx-shared-lib shaderc")
  of WinRelease64:
    genGmakeProjectsAndCd("mingw-gcc")
    direShell("make config=release64 bgfx-shared-lib shaderc")
  
  cd(getAppDir())

proc installChipmunk() = 
  cd("vendor/Chipmunk2D")
  createDir(".build")
  cd(".build")
  if not shell("cmake .."):
      echo "Ensure CMake is installed before proceeding: https://cmake.org/"
      return
  direShell("make")



proc installDependencies(target: Targets) =
  installBgfx(target)
  installChipmunk()

proc verifyAndroidEnvVars() =
  if not existsEnv("ANDROID_NDK_ROOT") or not existsEnv("ANDROID_NDK_CLANG") or not existsEnv("ANDROID_NDK_ARM"):
    echo "Please make sure ANDROID_NDK_ROOT, ANDROID_NDK_CLANG and ANDROID_NDK_ARM environment variables are set for your platform."
    quit(QUIT_SUCCESS)

proc verifyWindowsEnvVars() =
  if not existsEnv("MINGW"):
    echo "Please make sure MINGW environment variable is set with a value pointing to your MinGW installation."
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

task "osx-release32", "Build release verisons of FRAG dependencies for OSX 32-bit instruction set":
  installDependencies(OSXRelease32)
  
task "osx-release64", "Build release verisons of FRAG dependencies for OSX 64-bit instruction set":
  installDependencies(OSXRelease64)

###########
# WINDOWS #
###########
task "win-debug32", "Build debug verisons of FRAG dependencies for Windows 32-bit instruction set":
  verifyWindowsEnvVars()
  installDependencies(WinDebug32)
  
task "win-debug64", "Build debug verisons of FRAG dependencies for Windows 64-bit instruction set":
  verifyWindowsEnvVars()
  installDependencies(WinDebug64)

task "win-release32", "Build debug verisons of FRAG dependencies for Windows 32-bit instruction set":
  verifyWindowsEnvVars()
  installDependencies(WinRelease32)
  
task "win-release64", "Build debug verisons of FRAG dependencies for Windows 64-bit instruction set":
  verifyWindowsEnvVars()
  installDependencies(WinRelease64)