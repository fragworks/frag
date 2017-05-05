import os, osproc

if not dirExists("vendor/bx"):
  echo "Initialize submodules in vendor folder prior to installation."

when defined(windows):
  echo "Windows"
elif defined(macosx):
  setCurrentDir("vendor/bgfx")
  discard execCmd("""
    ../bx/tools/bin/darwin/genie --with-shared-lib --with-tools --gcc=osx gmake
  """)
  setCurrentDir(".build/projects/gmake-osx")
  discard execCmd("make")
elif defined(linux):
  echo "Linux"
else:
  echo "Unsupported!"