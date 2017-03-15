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
requires "opengl >= 1.1.0"
requires "https://github.com/zacharycarter/bgfx.nim.git"
requires "https://github.com/krux02/nim-glm.git"
requires "https://github.com/zacharycarter/freetype.git"
requires "https://github.com/zacharycarter/nanovg.nim.git"
requires "strfmt >= 0.8.4"
requires "https://github.com/zacharycarter/nimassimp.git"
