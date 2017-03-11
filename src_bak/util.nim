import assimp, glm

proc lerp*(v1, v2: Vec2f, alpha: float) : Vec2f =
  let invAlpha = 1.0 - alpha
  vec2f((v1.x * invAlpha) + (v2.x * alpha), (v1.y * invAlpha) + (v2.y * alpha))

proc toMat4f*(m: TMatrix4x4) : Mat4f = 
  mat4f(
    vec4f(m[0], m[1], m[2], m[3])
    , vec4f(m[4], m[5], m[6], m[7])
    , vec4f(m[8], m[9], m[10], m[11])
    , vec4f(m[12], m[13], m[14], m[15])
  )
  
proc inverse*(m: TMatrix4x4) : Mat4f =
  glm.inverse(toMat4f(m))

proc initTranslationTransform*(m: var Mat4f, x, y, z: float) =
  m[0][0] = 1.0
  m[0][1] = 0.0
  m[0][2] = 0.0
  m[0][3] = x

  m[1][0] = 0.0
  m[1][1] = 1.0
  m[1][2] = 0.0
  m[1][3] = y

  m[2][0] = 0.0
  m[2][1] = 0.0
  m[2][2] = 1.0
  m[2][3] = z

  m[3][0] = 0.0
  m[3][1] = 0.0
  m[3][2] = 0.0
  m[3][3] = 1.0

proc initScalingTransform*(m: var Mat4f, scaleX, scaleY, scaleZ: float) =
  m[0][0] = scaleX
  m[0][1] = 0.0
  m[0][2] = 0.0
  m[0][3] = 0.0

  m[1][0] = 0.0
  m[1][1] = scaleY
  m[1][2] = 0.0
  m[1][3] = 0.0

  m[2][0] = 0.0
  m[2][1] = 0.0
  m[2][2] = scaleZ
  m[2][3] = 0.0

  m[3][0] = 0.0
  m[3][1] = 0.0
  m[3][2] = 0.0
  m[3][3] = 1.0

proc dotquaternions*(a: Quatf; b: Quatf): cfloat =
  return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w

proc mixquaternion*(q: var Quatf, a: var Quatf, b: Quatf, t: cfloat) =
  var tmp: Quatf
  if dotquaternions(a, b) < 0:
    tmp.x = - a.x
    tmp.y = - a.y
    tmp.z = - a.z
    tmp.w = - a.w
    a = tmp
  q.x = a.x + t * (b.x - a.x)
  q.y = a.y + t * (b.y - a.y)
  q.z = a.z + t * (b.z - a.z)
  q.w = a.w + t * (b.w - a.w)
  q = normalize(q)

proc offset*[A](some: ptr A; b: int): ptr A =
  result = cast[ptr A](cast[int](some) + (b * sizeof(A)))