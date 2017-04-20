import
  math

import
  bgfxdotnim

import
  ../graphics/camera,
  scaling

type
  ViewportType* {.pure.} = enum
    Extend, Fill, Fit, Scaling, Screen, Stretch
  
  Viewport* = ref object
    camera*: Camera
    worldWidth*, worldHeight*: float
    screenX*, screenY*, screenWidth*, screenHeight*: int
    case viewportType*: ViewportType
    of ViewportType.Fit, ViewportType.Scaling:
      scaling: Scaling
    else:
      discard
  

proc init*(viewport: Viewport, worldWidth, worldHeight: float, camera: Camera) =
  viewport.worldWidth = worldWidth
  viewport.worldHeight = worldHeight
  viewport.camera = camera
  case viewport.viewportType
  of ViewportType.Fit:
    viewport.scaling = Scaling(scalingType: ScalingType.Fit)
  else:
    discard

proc apply*(viewport: Viewport, centerCamera: bool) =
  bgfx_set_view_rect(viewport.camera.viewId, viewport.screenX.uint16, viewport.screenY.uint16, viewport.screenWidth.uint16, viewport.screenHeight.uint16)

  viewport.camera.viewportWidth = viewport.worldWidth
  viewport.camera.viewportHeight = viewport.worldHeight

  if centerCamera:
    viewport.camera.position = [float32 viewport.worldWidth / 2, viewport.worldHeight / 2, 0]

  viewport.camera.update()

proc update*(viewport: Viewport, screenWidth, screenHeight: int, centerCamera: bool) =
  case viewport.viewportType
  of ViewportType.Fit:
    let scaled = viewport.scaling.apply(viewport.worldWidth, viewport.worldHeight, screenWidth.float, screenHeight.float)
    let viewportWidth = round(scaled[0])
    let viewportHeight = round(scaled[1])

    viewport.screenX = ((screenWidth.float - viewportWidth) / 2).int
    viewport.screenY = ((screenHeight.float - viewportHeight) / 2).int
    viewport.screenWidth = viewportWidth.int
    viewport.screenHeight = viewportHeight.int

    viewport.apply(centerCamera)
  else:
    discard
