import
  bgfxdotnim

import
  ../logger,
  ../math/fpu_math as fpumath

type
  CameraType* {.pure.} = enum
    Perspective, Orthographic

  Camera* = ref object
    case cameraType: CameraType
    of CameraType.Perspective:
      discard
    of CameraType.Orthographic:
      zoom*: float
    projection*: Mat4
    view: Mat4
    combined*: Mat4
    invProjView: Mat4
    nearPlane, farPlane: float
    viewportX*, viewportY*: float
    viewportWidth*, viewportHeight*: float
    position*, direction, lookAt, up*: Vec3
    initialized*: bool
    viewId*: uint8

proc update*(camera: Camera) =
  if camera.cameraType == CameraType.Orthographic:
    fpumath.mtxOrtho(
      camera.projection, 
      camera.zoom * (camera.viewportWidth / 2), 
      camera.zoom * -camera.viewportWidth / 2, 
      camera.zoom * -(camera.viewportHeight / 2), 
      camera.zoom * camera.viewportHeight / 2, 
      camera.nearPlane, 
      camera.farPlane
    )

    var tmp : Vec3
    fpumath.vec3Add(tmp, camera.position, camera.direction)
    fpumath.mtxLookAt(
      camera.view,
      camera.position,
      tmp,
      camera.up
    )

    fpumath.mtxMul(camera.combined, camera.view, camera.projection)
    
  else:
    let aspect = camera.viewportWidth / camera.viewportHeight
    #mtxProj(camera.fi)

proc zoomIn*(camera: Camera) =
  camera.zoom += 0.2

proc zoomOut*(camera: Camera) =
  camera.zoom -= 0.2

proc ortho*(camera: Camera, farPlane, viewportWidth, viewportHeight: float, yDown: bool = false) =
  if not camera.initialized:
    logWarn "Camera must be initialized before calling ortho."
    return

  if yDown:
    camera.up[1] = -1.0f32
    camera.direction[2] = 1.0f32

  if camera.cameraType == CameraType.Perspective:
    camera.cameraType = CameraType.Orthographic
    camera.zoom = 1.0
  
  camera.nearPlane = 0.0
  camera.farPlane = farPlane
    

  camera.viewportWidth = viewportWidth
  camera.viewportHeight = viewportHeight

  camera.position = [
    float32 camera.zoom * camera.viewportWidth / 2.0f,
    camera.zoom * camera.viewportHeight / 2.0f,
    0.0
  ]

  bgfx_set_view_rect(camera.viewId, 0, 0, uint16 viewportWidth, uint16 viewportHeight)

proc updateViewport*(camera: Camera, viewportWidth, viewportHeight: float) =
  camera.viewportWidth = viewportWidth
  camera.viewportHeight = viewportHeight
  
  bgfx_set_view_rect(camera.viewId, 0, 0, uint16 viewportWidth, uint16 viewportHeight)

proc unproject*(camera: Camera, screenCoords: var Vec3, viewportX, viewportY, viewportWidth, viewportHeight, screenWidth, screenHeight: float) =
  var x = screenCoords[0]
  var y = screenCoords[1]

  x = x - viewportX
  #y = screenHeight - y - 1
  y = y - viewportY

  screenCoords[0] = (2 * x) / viewportWidth - 1
  screenCoords[1] = (2 * y) / viewportHeight - 1
  screenCoords[2] = 2 * screenCoords[2] - 1
  screenCoords.vec3Prj(screenCoords, camera.invProjView)

proc init*(camera: Camera, viewId: uint8) =
  camera.viewId = viewId
  camera.cameraType = CameraType.Perspective
  mtxIdentity(camera.projection)
  mtxIdentity(camera.view)
  mtxIdentity(camera.combined)
  mtxIdentity(camera.invProjView)
  camera.nearPlane = 1.0
  camera.farPlane = 100.0
  camera.viewportWidth = 0
  camera.viewportheight = 0
  camera.position = [0.0'f32, 0.0'f32, 0.0'f32]
  camera.direction = [0.0'f32, 0.0'f32, -1.0'f32]
  camera.up = [0.0'f32, 1.0'f32, 0.0'f32]
  camera.initialized = true