import bgfx, math
import fpumath

const CAMERA_KEY_FORWARD = 0x01
const CAMERA_KEY_BACKWARD = 0x02
const CAMERA_KEY_LEFT = 0x04
const CAMERA_KEY_RIGHT = 0x08
const CAMERA_KEY_UP = 0x10
const CAMERA_KEY_DOWN = 0x20

type
  MouseCoords = tuple[
    mx: float,
    my: float
  ]

  Camera* = object
    mouseNow: MouseCoords
    mouseLast: MouseCoords
    eye: Vec3
    at: Vec3
    up: Vec3
    proj: Mat4
    horizontalAngle: float
    verticalAngle: float
    mouseSpeed: float
    moveSpeed: float
    keys: uint8_t
    mouseDown: bool
    viewportWidth, viewportHeight: float
    fov: float
    near, far: float

proc reset*(camera: var Camera, viewportWidth, viewportHeight: float) =
  camera.mouseNow.mx = 0
  camera.mouseNow.my = 0
  camera.mouseLast.mx = 0
  camera.mouseLast.my = 0
  camera.eye = [0.0'f32, 0.0'f32, -35.0'f32]
  camera.at = [0.0'f32, 0.0'f32, 0.0'f32]
  camera.up = [0.0'f32, 1.0'f32, 0.0'f32]
  camera.horizontalAngle = 0.01
  camera.verticalAngle = 0
  camera.mouseSpeed = 0.0020
  camera.moveSpeed = 1.0
  camera.keys = 0
  camera.mouseDown = false
  camera.viewportWidth = viewportWidth
  camera.viewportHeight = viewportHeight
  camera.fov = 60.0
  camera.near = 0.1
  camera.far = 1000.0

proc updateMouseCoords*(camera: var Camera, x, y: float) =
  camera.mouseLast = camera.mouseNow
  camera.mouseNow.mx = x
  camera.mouseNow.my = y

proc setKeyState*(camera: var Camera, key: uint8_t; down: bool) =
  camera.keys = camera.keys and not key
  if down:
    camera.keys = camera.keys or  key
  else:
    camera.keys = camera.keys or 0  

proc update*(camera: var Camera, deltaTime: float) =
  if camera.mouseDown:
    let deltaX = camera.mouseNow.mx - camera.mouseLast.mx
    let deltaY = camera.mouseNow.my - camera.mouseLast.my

    camera.horizontalAngle += camera.mouseSpeed * deltaX
    camera.verticalAngle -= camera.mouseSpeed * deltaY

  let direction : Vec3 = [
    fcos(camera.verticalAngle) * fsin(camera.horizontalAngle),
    fsin(camera.verticalAngle),
    fcos(camera.verticalAngle) * fcos(camera.horizontalAngle),
  ]

  let right : Vec3 = [
    fsin(camera.horizontalAngle - piHalf),
    0,
    fcos(camera.horizontalANgle - piHalf)
  ]

  var up : Vec3
  vec3Cross(up, right, direction)
  
  if (camera.keys and CAMERA_KEY_FORWARD) == 1:
    var pos: Vec3
    vec3Move(pos, camera.eye)

    var tmp: Vec3
    vec3Mul(tmp, direction, deltaTime * camera.moveSpeed)

    vec3Add(camera.eye, pos, tmp)
    setKeyState(camera, CAMERA_KEY_FORWARD, false)

  if (camera.keys and CAMERA_KEY_BACKWARD) == 2:
    var pos: Vec3
    vec3Move(pos, camera.eye)

    var tmp: Vec3
    vec3Mul(tmp, direction, deltaTime * camera.moveSpeed)

    vec3Sub(camera.eye, pos, tmp)
    setKeyState(camera, CAMERA_KEY_BACKWARD, false)

  if (camera.keys and CAMERA_KEY_LEFT) == 4:
    var pos: Vec3
    vec3Move(pos, camera.eye)

    var tmp: Vec3
    vec3Mul(tmp, right, deltaTime * camera.moveSpeed)

    vec3Add(camera.eye, pos, tmp)
    setKeyState(camera, CAMERA_KEY_LEFT, false)

  if (camera.keys and CAMERA_KEY_RIGHT) == 8:
    var pos: Vec3
    vec3Move(pos, camera.eye)

    var tmp: Vec3
    vec3Mul(tmp, right, deltaTime * camera.moveSpeed)

    vec3Sub(camera.eye, pos, tmp)
    setKeyState(camera, CAMERA_KEY_RIGHT, false)

  if (camera.keys and CAMERA_KEY_UP) == 16:
    var pos: Vec3
    vec3Move(pos, camera.eye)

    var tmp: Vec3
    vec3Mul(tmp, up, deltaTime * camera.moveSpeed)

    vec3Add(camera.eye, pos, tmp)
    setKeyState(camera, CAMERA_KEY_UP, false)

  if (camera.keys and CAMERA_KEY_DOWN) == 32:
    var pos: Vec3
    vec3Move(pos, camera.eye)

    var tmp: Vec3
    vec3Mul(tmp, up, deltaTime * camera.moveSpeed)

    vec3Sub(camera.eye, pos, tmp)
    setKeyState(camera, CAMERA_KEY_DOWN, false)

  vec3Add(camera.at, camera.eye, direction)
  vec3Cross(camera.up, right, direction)

proc moveForward*(camera: var Camera, down: cint) =
  if down == 1 or down == 2:
    setKeyState(camera, CAMERA_KEY_FORWARD, true)
  else:
    setKeyState(camera, CAMERA_KEY_FORWARD, false)

proc moveRight*(camera: var Camera, down: cint) =
  if down == 1 or down == 2:
    setKeyState(camera, CAMERA_KEY_RIGHT, true)
  else:
    setKeyState(camera, CAMERA_KEY_RIGHT, false)

proc moveLeft*(camera: var Camera, down: cint) =
  if down == 1 or down == 2:
    setKeyState(camera, CAMERA_KEY_LEFT, true)
  else:
    setKeyState(camera, CAMERA_KEY_LEFT, false)

proc moveBackward*(camera: var Camera, down: cint) =
  if down == 1 or down == 2:
    setKeyState(camera, CAMERA_KEY_BACKWARD, true)
  else:
    setKeyState(camera, CAMERA_KEY_BACKWARD, false)

proc moveUp*(camera: var Camera, down: cint) =
  if down == 1 or down == 2:
    setKeyState(camera, CAMERA_KEY_UP, true)
  else:
    setKeyState(camera, CAMERA_KEY_UP, false)

proc moveDown*(camera: var Camera, down: cint) =
  if down == 1 or down == 2:
    setKeyState(camera, CAMERA_KEY_DOWN, true)
  else:
    setKeyState(camera, CAMERA_KEY_DOWN, false)

proc newCamera*(viewportWidth, viewportHeight: float) : Camera =
  result = Camera()
  reset(result, viewportWidth, viewportHeight)

proc setPosition*(camera: var Camera, position: Vec3) =
  camera.eye = position

proc setVerticalAngle*(camera: var Camera, verticalAngle: float) =
  camera.verticalAngle = verticalAngle

proc setHorizontalAngle*(camera: var Camera, horizontalAngle: float) =
  camera.horizontalAngle = horizontalAngle

proc getViewMatrix*(camera: Camera, viewMtx: var Mat4) =
  mtxLookAt(viewMtx, camera.eye, camera.at, camera.up)

proc getProjMatrix*(camera: Camera, projMtx: var Mat4) =
  mtxProj(projMtx, camera.fov, camera.viewportWidth / camera.viewportHeight, camera.near, camera.far)

proc setMouseDown*(camera: var Camera, mouseDown: bool) =
  camera.mouseDown = mouseDown
  