import
  sdl2 as sdl

import 
  texture_region

type
  Animation* = object
    frames*: seq[TextureRegion]
    frameDuration*: float

proc fromTextureRegions*(frames: seq[TextureRegion], frameDuration: float) : Animation =
  result = Animation()
  result.frames = frames
  result.frameDuration = frameDuration

proc getFrame*(animation: Animation, stateTime: float) : TextureRegion =
  var frameNumber = int(stateTime / animation.frameDuration)
  frameNumber = frameNumber mod animation.frames.len
  return animation.frames[frameNumber]