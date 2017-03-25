**FRAG**
=======

Framework for Rather Awesome Games
[![Build Status](https://travis-ci.org/fragworks/frag.svg?branch=master)](https://travis-ci.org/fragworks/frag)
[![Join the chat at https://gitter.im/fragworks/frag](https://badges.gitter.im/fragworks/frag.svg)](https://gitter.im/fragworks/frag?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
----------------------------------

FRAG is a game creation framework being developed using the [Nim](https://nim-lang.org/) programming language, and is currently in pre-alpha status.
The immediate development focus for FRAG is supporting the creation of 2D mobile and desktop games.

Support for 3D is planned for post-alpha releases of FRAG.

**Tested for Desktop on**:
- OSX Sierra v10.12.1 (OpenGL 3.3)
- Arch Linux
- Windows 10 (DirectX 11)

**Tested for Android on**:
- Samsung Galaxy S6 (arm64-v8a, OpenGL ES 2.0)

**Dependencies for Desktop**:
- [Nim v0.16.1](https://github.com/nim-lang/Nim)
- [BGFX](https://github.com/bkaradzic/bgfx)
- [SDL2](https://www.libsdl.org/download-2.0.php)
- [SDL_image](https://www.libsdl.org/projects/SDL_image/)

**Some technical details about FRAG**:

 - Planned support for a multitude of rendering backends via [BGFX](https://github.com/bkaradzic/bgfx)
 - SDL2

Examples
-------
----------

**Desktop**


----------


[Hello World](https://github.com/fragworks/frag/tree/master/examples/desktop/00-hello-world)
![https://github.com/fragworks/frag/tree/master/examples/00-hello-world](http://i.imgur.com/24JvAzP.png)

[Spritebatch](https://github.com/fragworks/frag/tree/master/examples/desktop/01-sprite-batch)
![https://github.com/fragworks/frag/tree/master/examples/01-sprite-batch](http://i.imgur.com/0qYhxLw.png)

[Audio](https://github.com/fragworks/frag/tree/master/examples/desktop/02-audio)

[Input](https://github.com/fragworks/frag/tree/master/examples/desktop/03-input)

[Sprite Animation](https://github.com/fragworks/frag/tree/master/examples/desktop/04-sprite-animation)

![https://github.com/fragworks/frag/tree/master/examples/04-sprite-animation](http://i.imgur.com/qIXCc0E.gif)

[GUI](https://github.com/fragworks/frag/tree/master/examples/desktop/05-gui)

![https://github.com/fragworks/frag/tree/master/examples/05-gui](http://i.imgur.com/ui9PFKD.png)


**Android**


----------

[Hello World](https://github.com/fragworks/frag-android/blob/master/examples/00-hello-world/main.nim)

![https://github.com/fragworks/frag-android/blob/master/examples/00-hello-world/main.nim](http://i.imgur.com/Ybqin46.png)
