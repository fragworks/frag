import glfw3 as glfw, os

let targetFrameRate = 60.0
var frameStart = 0.0
let waitTime = 1.0 / targetFrameRate

proc limitFrameRate*() =
  let currentFrameTime = glfw.GetTime() - frameStart
  let dur = 1000.0 * (waitTime - currentFrameTime) + 0.5
  if dur > 0:
    sleep(int(dur))
  
  frameStart = glfw.GetTime()