import 
  sdl2 as sdl

import
  ../globals

var frameTime: uint32 = 0

proc limitFrameRate*() =
  let now = sdl.getTicks()
  if frameTime > now:
    sdl.delay(frameTime - now) # Delay to maintain steady frame rate
  frameTime += targetFrameMs