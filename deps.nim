import os, osproc

if not(dirExists("vendor/bx/tools")) or not(dirExists("vendor/bgfx/src")) or not(dirExists("vendor/bimg/src")):
  echo "Initialize submodules in vendor folder prior to installation."
  quit(QUIT_SUCCESS)

when defined(windows):
  echo "Windows"
elif defined(macosx):
  setCurrentDir("vendor/bgfx")
  discard execCmd("""
    ../bx/tools/bin/darwin/genie --with-shared-lib --with-tools --gcc=osx gmake
  """)
  setCurrentDir(".build/projects/gmake-osx")
  discard execCmd("make config=release64")
elif defined(linux):
  setCurrentDir("vendor/bgfx")
  discard execCmd("""
    ../bx/tools/bin/linux/genie --with-shared-lib --with-tools --gcc=linux-gcc gmake
  """)
  setCurrentDir(".build/projects/gmake-linux")
  discard execCmd("make config=release64")
else:
  echo "Your operating system is not supported!"