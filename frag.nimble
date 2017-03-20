# Package

version       = "0.1.0"
author        = "Zachary Carter"
description   = "A 2D|3D game engine"
license       = "MIT"

# Settings

srcDir        = "src"
skipDirs      = @[ "examples" ]

# Dependencies

requires "nim >= 0.16.0"
requires "sdl2 >= 1.1"
requires "https://github.com/yglukhov/android.git"
requires "https://github.com/zacharycarter/bgfx.nim.git"
requires "sound >= 0.1.0"
requires "stb_image >= 1.1"
requires "https://github.com/zacharycarter/freetype.git"
requires "https://github.com/zacharycarter/nanovg.nim.git"
requires "strfmt >= 0.8.4"
requires "https://github.com/zacharycarter/nimassimp.git"
