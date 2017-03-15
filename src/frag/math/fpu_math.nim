# Copyright 2017 Cory Noll Crimmins - Golden
# License: BSD-2
# Port for bx fpumath

import math, algorithm

var pi*: float32 = 3.141592653589793'f32

var invPi*: float32 = 1.0'f32 / 3.141592653589793'f32

var piHalf*: float32 = 1.570796326794897'f32

var sqrt2*: float32 = 1.414213562373095'f32

proc toRad*(deg: float32): float32 {.inline.} =
    return deg * pi / 180.0'f32

proc toDeg*(rad: float32): float32 {.inline.} =
    return rad * 180.0'f32 / pi

proc ffloor*(f: float32): float32 {.inline.} =
    return floor(f)

proc fceil*(f: float32): float32 {.inline.} =
    return ceil(f)

proc fround*(f: float32): float32 {.inline.} =
    return ffloor(f + 0.5'f32)

proc fmin*(a: float32; b: float32): float32 {.inline.} =
    return if a < b: a else: b

proc fmax*(a: float32; b: float32): float32 {.inline.} =
    return if a > b: a else: b

proc fmin3*(a: float32; b: float32; c: float32): float32 {.inline.} =
    return fmin(a, fmin(b, c))

proc fmax3*(a: float32; b: float32; c: float32): float32 {.inline.} =
    return fmax(a, fmax(b, c))

proc fclamp*(a: float32; min: float32; max: float32): float32 {.inline.} =
    return fmin(fmax(a, min), max)

proc fsaturate*(a: float32): float32 {.inline.} =
    return fclamp(a, 0.0'f32, 1.0'f32)

proc flerp*(a: float32; b: float32; t: float32): float32 {.inline.} =
    return a + (b - a) * t

proc fsign*(a: float32): float32 {.inline.} =
    return if a < 0.0'f32: - 1.0'f32 else: 1.0'f32

proc fstep*(edge: float32; a: float32): float32 {.inline.} =
    return if a < edge: 0.0'f32 else: 1.0'f32

proc fpulse*(a: float32; start: float32; `end`: float32): float32 {.inline.} =
    return fstep(a, start) - fstep(a, `end`)

proc fabsf*(a: float32): float32 {.inline.} =
    if (a > 0): return a else: return -a

proc fabsolute*(a: float32): float32 {.inline.} =
    return fabsf(a)

proc fsq*(a: float32): float32 {.inline.} =
    return a * a

proc fsin*(a: float32): float32 {.inline.} =
    return sin(a)

proc fcos*(a: float32): float32 {.inline.} =
    return cos(a)

proc fpow*(a: float32; b: float32): float32 {.inline.} =
    return pow(a, b)

proc fexp2*(a: float32): float32 {.inline.} =
    return fpow(2.0'f32, a)

proc flog*(a: float32): float32 {.inline.} =
    return ln(a)

proc flog2*(a: float32): float32 {.inline.} =
    return flog(a) * 1.442695041'f32

proc fsqrt*(a: float32): float32 {.inline.} =
    return sqrt(a)

proc frsqrt*(a: float32): float32 {.inline.} =
    return 1.0'f32 / fsqrt(a)

proc ffract*(a: float32): float32 {.inline.} =
    return a - floor(a)

proc fmod*(a: float32; b: float32): float32 {.inline.} =
    return fmod(a, b)

proc fequal*(a: float32; b: float32; epsilon: float32): bool {.inline.} =
    # http://realtimecollisiondetection.net/blog/?p=89
    var lhs: float32 = fabsolute(a - b)
    var rhs: float32 = epsilon * fmax3(1.0'f32, fabsolute(a), fabsolute(b))
    return lhs <= rhs

proc fequal*(a: openarray[float32]; b: openarray[float32]; num: int; epsilon: float32): bool {.inline.} =
    var equal: bool = fequal(a[0], b[0], epsilon)
    var ii: int = 1
    while equal and ii < num:
        equal = fequal(a[ii], b[ii], epsilon)
        inc(ii)
    return equal

proc fwrap*(a: float32; wrap: float32): float32 {.inline.} =
    var `mod`: float32 = fmod(a, wrap)
    var outResult: float32 = if `mod` < 0.0'f32: wrap + `mod` else: `mod`
    return outResult

# References:
#    - Bias And Gain Are Your Friend
#        http://blog.demofox.org/2012/09/24/bias-and-gain-are-your-friend/
#    - http://demofox.org/biasgain.html

proc fbias*(time: float32; bias: float32): float32 {.inline.} =
    return time / (((1.0'f32 / bias - 2.0'f32) * (1.0'f32 - time)) + 1.0'f32)

proc fgain*(time: float32; gain: float32): float32 {.inline.} =
    if time < 0.5'f32:
        return fbias(time * 2.0'f32, gain) * 0.5'f32
    return fbias(time * 2.0'f32 - 1.0'f32, 1.0'f32 - gain) * 0.5'f32 + 0.5'f32

type Vec3* = array[3, float32]

proc vec3Move*(outResult: var Vec3; a: Vec3) {.inline.} =
    outResult[0] = a[0]
    outResult[1] = a[1]
    outResult[2] = a[2]

proc vec3Abs*(outResult: var Vec3; a: Vec3) {.inline.} =
    outResult[0] = fabsolute(a[0])
    outResult[1] = fabsolute(a[1])
    outResult[2] = fabsolute(a[2])

proc vec3Neg*(outResult: var Vec3; a: Vec3) {.inline.} =
    outResult[0] = - a[0]
    outResult[1] = - a[1]
    outResult[2] = - a[2]

proc vec3Add*(outResult: var Vec3; a: Vec3; b: Vec3) {.inline.} =
    outResult[0] = a[0] + b[0]
    outResult[1] = a[1] + b[1]
    outResult[2] = a[2] + b[2]

proc vec3Add*(outResult: var Vec3; a: Vec3; b: float32) {.inline.} =
    outResult[0] = a[0] + b
    outResult[1] = a[1] + b
    outResult[2] = a[2] + b

proc vec3Sub*(outResult: var Vec3; a: Vec3; b: Vec3) {.inline.} =
    outResult[0] = a[0] - b[0]
    outResult[1] = a[1] - b[1]
    outResult[2] = a[2] - b[2]

proc vec3Sub*(outResult: var Vec3; a: Vec3; b: float32) {.inline.} =
    outResult[0] = a[0] - b
    outResult[1] = a[1] - b
    outResult[2] = a[2] - b

proc vec3Mul*(a: Vec3; b: Vec3): Vec3 {.inline.} =
    result[0] = a[0] * b[0]
    result[1] = a[1] * b[1]
    result[2] = a[2] * b[2]

proc vec3Mul*(outResult: var Vec3; a: Vec3; b: Vec3) {.inline.} =
    outResult[0] = a[0] * b[0]
    outResult[1] = a[1] * b[1]
    outResult[2] = a[2] * b[2]

proc vec3Mul*(a: Vec3; b: float32): Vec3 {.inline.} =
    result[0] = a[0] * b
    result[1] = a[1] * b
    result[2] = a[2] * b

proc vec3Mul*(outResult: var Vec3; a: Vec3; b: float32) {.inline.} =
    outResult[0] = a[0] * b
    outResult[1] = a[1] * b
    outResult[2] = a[2] * b

proc vec3Dot*(a: Vec3; b: Vec3): float32 {.inline.} =
    return a[0] * b[0] + a[1] * b[1] + a[2] * b[2]

proc vec3Cross*(outResult: var Vec3; a: Vec3; b: Vec3) {.inline.} =
    outResult[0] = a[1] * b[2] - a[2] * b[1]
    outResult[1] = a[2] * b[0] - a[0] * b[2]
    outResult[2] = a[0] * b[1] - a[1] * b[0]

proc vec3Length*(a: Vec3): float32 {.inline.} =
    return fsqrt(vec3Dot(a, a))

proc vec3Lerp*(outResult: var Vec3; a: Vec3; b: Vec3; t: float32) {.inline.} =
    outResult[0] = flerp(a[0], b[0], t)
    outResult[1] = flerp(a[1], b[1], t)
    outResult[2] = flerp(a[2], b[2], t)

proc vec3Lerp*(outResult: var Vec3; a: Vec3; b: Vec3; c: Vec3) {.inline.} =
    outResult[0] = flerp(a[0], b[0], c[0])
    outResult[1] = flerp(a[1], b[1], c[1])
    outResult[2] = flerp(a[2], b[2], c[2])

proc vec3Norm*(outResult: var Vec3; a: Vec3): float32 {.discardable, inline.} =
    var len: float32 = vec3Length(a)
    var invLen: float32 = 1.0'f32 / len
    outResult[0] = a[0] * invLen
    outResult[1] = a[1] * invLen
    outResult[2] = a[2] * invLen
    return len

proc vec3Min*(outResult: var Vec3; a: Vec3; b: Vec3) {.inline.} =
    outResult[0] = fmin(a[0], b[0])
    outResult[1] = fmin(a[1], b[1])
    outResult[2] = fmin(a[2], b[2])

proc vec3Max*(outResult: var Vec3; a: Vec3; b: Vec3) {.inline.} =
    outResult[0] = fmax(a[0], b[0])
    outResult[1] = fmax(a[1], b[1])
    outResult[2] = fmax(a[2], b[2])

proc vec3Rcp*(outResult: var Vec3; a: Vec3) {.inline.} =
    outResult[0] = 1.0'f32 / a[0]
    outResult[1] = 1.0'f32 / a[1]
    outResult[2] = 1.0'f32 / a[2]

proc vec3TangentFrame*(n: Vec3; t: var Vec3; b: var Vec3) {.inline.} =
    var nx: float32 = n[0]
    var ny: float32 = n[1]
    var nz: float32 = n[2]
    if fabsf(nx) > fabsf(nz):
        var invLen: float32 = 1.0'f32 / sqrt(nx * nx + nz * nz)
        t[0] = - (nz * invLen)
        t[1] = 0.0'f32
        t[2] = nx * invLen
    else:
        var invLen: float32 = 1.0'f32 / fsqrt(ny * ny + nz * nz)
        t[0] = 0.0'f32
        t[1] = nz * invLen
        t[2] = - (ny * invLen)
    vec3Cross(b, n, t)

type Quat* = array[4, float32]

proc quatIdentity*(outResult: var Quat) {.inline.} =
    outResult[0] = 0.0'f32
    outResult[1] = 0.0'f32
    outResult[2] = 0.0'f32
    outResult[3] = 1.0'f32

proc quatMove*(outResult: var Quat; a: Quat) {.inline.} =
    outResult[0] = a[0]
    outResult[1] = a[1]
    outResult[2] = a[2]
    outResult[3] = a[3]

proc quatMulXYZ*(outResult: var Vec3; qa: Quat; qb: Quat) {.inline.} =
    var ax: float32 = qa[0]
    var ay: float32 = qa[1]
    var az: float32 = qa[2]
    var aw: float32 = qa[3]
    var bx: float32 = qb[0]
    var by: float32 = qb[1]
    var bz: float32 = qb[2]
    var bw: float32 = qb[3]
    outResult[0] = aw * bx + ax * bw + ay * bz - az * by
    outResult[1] = aw * by - ax * bz + ay * bw + az * bx
    outResult[2] = aw * bz + ax * by - ay * bx + az * bw

proc quatMul*(outResult: var Quat; qa: Quat; qb: Quat) {.inline.} =
    var ax: float32 = qa[0]
    var ay: float32 = qa[1]
    var az: float32 = qa[2]
    var aw: float32 = qa[3]
    var bx: float32 = qb[0]
    var by: float32 = qb[1]
    var bz: float32 = qb[2]
    var bw: float32 = qb[3]
    outResult[0] = aw * bx + ax * bw + ay * bz - az * by
    outResult[1] = aw * by - ax * bz + ay * bw + az * bx
    outResult[2] = aw * bz + ax * by - ay * bx + az * bw
    outResult[3] = aw * bw - ax * bx - ay * by - az * bz

proc quatInvert*(outResult: var Quat; quat: Quat) {.inline.} =
    outResult[0] = - quat[0]
    outResult[1] = - quat[1]
    outResult[2] = - quat[2]
    outResult[3] = quat[3]

proc quatDot*(a: Quat; b: Quat): float32 {.inline.} =
    return a[0] * b[0] + a[1] * b[1] + a[2] * b[2] + a[3] * b[3]

proc quatNorm*(outResult: var Quat; quat: Quat) {.inline.} =
    var norm: float32 = quatDot(quat, quat)
    if 0.0'f32 < norm:
        var invNorm: float32 = 1.0'f32 / fsqrt(norm)
        outResult[0] = quat[0] * invNorm
        outResult[1] = quat[1] * invNorm
        outResult[2] = quat[2] * invNorm
        outResult[3] = quat[3] * invNorm
    else:
        quatIdentity(outResult)

proc quatToEuler*(outResult: var Vec3; quat: Quat) {.inline.} =
    var x: float32 = quat[0]
    var y: float32 = quat[1]
    var z: float32 = quat[2]
    var w: float32 = quat[3]
    var yy: float32 = y * y
    var zz: float32 = z * z
    var xx: float32 = x * x
    outResult[0] = arctan2(2.0'f32 * (x * w - y * z), 1.0'f32 - 2.0'f32 * (xx + zz))
    outResult[1] = arctan2(2.0'f32 * (y * w + x * z), 1.0'f32 - 2.0'f32 * (yy + zz))
    outResult[2] = arcsin(2.0'f32 * (x * y + z * w))

proc quatRotateAxis*(outResult: var Quat; axis: Vec3; angle: float32) {.inline.} =
    var ha: float32 = angle * 0.5'f32
    var ca: float32 = fcos(ha)
    var sa: float32 = fsin(ha)
    outResult[0] = axis[0] * sa
    outResult[1] = axis[1] * sa
    outResult[2] = axis[2] * sa
    outResult[3] = ca

proc quatRotateX*(outResult: var Quat; ax: float32) {.inline.} =
    var hx: float32 = ax * 0.5'f32
    var cx: float32 = fcos(hx)
    var sx: float32 = fsin(hx)
    outResult[0] = sx
    outResult[1] = 0.0'f32
    outResult[2] = 0.0'f32
    outResult[3] = cx

proc quatRotateY*(outResult: var Quat; ay: float32) {.inline.} =
    var hy: float32 = ay * 0.5'f32
    var cy: float32 = fcos(hy)
    var sy: float32 = fsin(hy)
    outResult[0] = 0.0'f32
    outResult[1] = sy
    outResult[2] = 0.0'f32
    outResult[3] = cy

proc quatRotateZ*(outResult: var Quat; az: float32) {.inline.} =
    var hz: float32 = az * 0.5'f32
    var cz: float32 = fcos(hz)
    var sz: float32 = fsin(hz)
    outResult[0] = 0.0'f32
    outResult[1] = 0.0'f32
    outResult[2] = sz
    outResult[3] = cz

proc vec3MulQuat*(outResult: var Vec3; vec: Vec3; quat: Quat) {.inline.} =
    var tmp0: Quat
    quatInvert(tmp0, quat)
    var qv: Quat
    qv[0] = vec[0]
    qv[1] = vec[1]
    qv[2] = vec[2]
    qv[3] = 0.0'f32
    var tmp1: Quat
    quatMul(tmp1, tmp0, qv)
    quatMulXYZ(outResult, tmp1, quat)

type Mat4* = array[16, float32]

proc mtxIdentity*(outResult: var Mat4) {.inline.} =
    outResult = [
        1.0'f32, 0.0'f32, 0.0'f32, 0.0'f32,
        0.0'f32, 1.0'f32, 0.0'f32, 0.0'f32,
        0.0'f32, 0.0'f32, 1.0'f32, 0.0'f32,
        0.0'f32, 0.0'f32, 0.0'f32, 1.0'f32
    ]

proc mtxTranslate*(outResult: var Mat4; tx: float32; ty: float32; tz: float32) {.inline.} =
    mtxIdentity(outResult)
    outResult[12] = tx
    outResult[13] = ty
    outResult[14] = tz

proc mtxScale*(outResult: var Mat4; sx: float32; sy: float32; sz: float32) {.inline.} =
    fill(outResult, 0)
    outResult[0] = sx
    outResult[5] = sy
    outResult[10] = sz
    outResult[15] = 1.0'f32

proc mtxScale*(outResult: var Mat4; scale: float32) {.inline.} =
    mtxScale(outResult, scale, scale, scale)

proc mtxFromNormal*(outResult: var Mat4; normal: Vec3; scale: float32;
                    pos: Vec3) {.inline.} =
    var tangent: array[3, float32]
    var bitangent: array[3, float32]
    vec3TangentFrame(normal, tangent, bitangent)
    outResult[0..2] = vec3Mul(bitangent, scale)
    outResult[4..6] = vec3Mul(normal, scale)
    outResult[8..10] = vec3Mul(tangent, scale)
    outResult[3] = 0.0'f32
    outResult[7] = 0.0'f32
    outResult[11] = 0.0'f32
    outResult[12] = pos[0]
    outResult[13] = pos[1]
    outResult[14] = pos[2]
    outResult[15] = 1.0'f32

proc mtxQuat*(outResult: var Mat4; quat: Quat) {.inline.} =
    var x: float32 = quat[0]
    var y: float32 = quat[1]
    var z: float32 = quat[2]
    var w: float32 = quat[3]
    var x2: float32 = x + x
    var y2: float32 = y + y
    var z2: float32 = z + z
    var x2x: float32 = x2 * x
    var x2y: float32 = x2 * y
    var x2z: float32 = x2 * z
    var x2w: float32 = x2 * w
    var y2y: float32 = y2 * y
    var y2z: float32 = y2 * z
    var y2w: float32 = y2 * w
    var z2z: float32 = z2 * z
    var z2w: float32 = z2 * w
    outResult[0] = 1.0'f32 - (y2y + z2z)
    outResult[1] = x2y - z2w
    outResult[2] = x2z + y2w
    outResult[3] = 0.0'f32
    outResult[4] = x2y + z2w
    outResult[5] = 1.0'f32 - (x2x + z2z)
    outResult[6] = y2z - x2w
    outResult[7] = 0.0'f32
    outResult[8] = x2z - y2w
    outResult[9] = y2z + x2w
    outResult[10] = 1.0'f32 - (x2x + y2y)
    outResult[11] = 0.0'f32
    outResult[12] = 0.0'f32
    outResult[13] = 0.0'f32
    outResult[14] = 0.0'f32
    outResult[15] = 1.0'f32

proc mtxQuatTranslation*(outResult: var Mat4; quat: Quat; translation: Vec3) {.inline.} =
    mtxQuat(outResult, quat)
    outResult[12] = - (outResult[0] * translation[0] + outResult[4] * translation[1] +
        outResult[8] * translation[2])
    outResult[13] = - (outResult[1] * translation[0] + outResult[5] * translation[1] +
        outResult[9] * translation[2])
    outResult[14] = - (outResult[2] * translation[0] + outResult[6] * translation[1] +
        outResult[10] * translation[2])

proc mtxQuatTranslationHMD*(outResult: var Mat4; quat: Quat; translation: Vec3) {.inline.} =
    var quat: array[4, float32]
    quat[0] = - quat[0]
    quat[1] = - quat[1]
    quat[2] = quat[2]
    quat[3] = quat[3]
    mtxQuatTranslation(outResult, quat, translation)


proc mtxLookAt_Impl*(outResult: var Mat4; eye: Vec3; view: Vec3;
                     up_optional: Vec3 = [0.0'f32, 1.0'f32, 0.0'f32]) {.inline.} =
    var tmp: Vec3
    var up: Vec3 = up_optional
    vec3Cross(tmp, up, view)
    var right: Vec3
    vec3Norm(right, tmp)
    vec3Cross(up, view, right)
    fill(outResult, 0.0'f32)
    outResult[0] = right[0]
    outResult[1] = up[0]
    outResult[2] = view[0]
    outResult[4] = right[1]
    outResult[5] = up[1]
    outResult[6] = view[1]
    outResult[8] = right[2]
    outResult[9] = up[2]
    outResult[10] = view[2]
    outResult[12] = - vec3Dot(right, eye)
    outResult[13] = - vec3Dot(up, eye)
    outResult[14] = - vec3Dot(view, eye)
    outResult[15] = 1.0'f32

proc mtxLookAtLh*(outResult: var Mat4; eye: Vec3; at: Vec3;
                  up_optional: Vec3 = [0.0'f32, 1.0'f32, 0.0'f32]) {.inline.} =
    var tmp: Vec3
    vec3Sub(tmp, at, eye)
    var view: Vec3
    vec3Norm(view, tmp)
    mtxLookAt_Impl(outResult, eye, view, up_optional)

proc mtxLookAtRh*(outResult: var Mat4; eye: Vec3; at: Vec3;
                  up: Vec3 = [0.0'f32, 1.0'f32, 0.0'f32]) {.inline.} =
    var tmp: Vec3
    vec3Sub(tmp, eye, at)
    var view: Vec3
    vec3Norm(view, tmp)
    mtxLookAt_Impl(outResult, eye, view, up)

proc mtxLookAt*(outResult: var Mat4; eye: Vec3; at: Vec3;
                up: Vec3 = [0.0'f32, 1.0'f32, 0.0'f32]) {.inline.} =
    mtxLookAtLh(outResult, eye, at, up)

proc mtxLHProjXYWH*(outResult: var Mat4; x: float32; y: float32; width: float32;
                    height: float32; near: float32; far: float32; oglNdc: bool = false) {.inline.} =
    var diff: float32 = far - near
    var aa: float32 = if oglNdc: (far + near) / diff else: far / diff
    var bb: float32 = if oglNdc: (2.0'f32 * far * near) / diff else: near * aa
    fill(outResult, 0)
    outResult[0] = width
    outResult[5] = height
    outResult[8] = - x
    outResult[9] = - y
    outResult[10] = aa
    outResult[11] = 1.0'f32
    outResult[14] = - bb

proc mtxRHProjXYWH*(outResult: var Mat4; x: float32; y: float32; width: float32;
                    height: float32; near: float32; far: float32; oglNdc: bool = false) {.
        inline.} =
    var diff: float32 = far - near
    var aa: float32 = if oglNdc: (far + near) / diff else: far / diff
    var bb: float32 = if oglNdc: (2.0'f32 * far * near) / diff else: near * aa
    fill(outResult, 0)
    outResult[0] = width
    outResult[5] = height
    outResult[8] = x
    outResult[9] = y
    outResult[10] = - aa
    outResult[11] = - 1.0'f32
    outResult[14] = - bb

proc mtxLHProj_impl*(outResult: var Mat4; ut: float32; dt: float32; lt: float32;
                     rt: float32; near: float32; far: float32; oglNdc: bool = false) {.inline.} =
    var invDiffRl: float32 = 1.0'f32 / (rt - lt)
    var invDiffUd: float32 = 1.0'f32 / (ut - dt)
    var width: float32 = 2.0'f32 * near * invDiffRl
    var height: float32 = 2.0'f32 * near * invDiffUd
    var xx: float32 = (rt + lt) * invDiffRl
    var yy: float32 = (ut + dt) * invDiffUd
    mtxLHProjXYWH(outResult, xx, yy, width, height, near, far, oglNdc)

proc mtxRHProj_impl*(outResult: var Mat4; ut: float32; dt: float32; lt: float32;
                     rt: float32; near: float32; far: float32; oglNdc: bool = false) {.inline.} =
    var invDiffRl: float32 = 1.0'f32 / (rt - lt)
    var invDiffUd: float32 = 1.0'f32 / (ut - dt)
    var width: float32 = 2.0'f32 * near * invDiffRl
    var height: float32 = 2.0'f32 * near * invDiffUd
    var xx: float32 = (rt + lt) * invDiffRl
    var yy: float32 = (ut + dt) * invDiffUd
    mtxRHProjXYWH(outResult, xx, yy, width, height, near, far, oglNdc)

proc mtxLHProj_impl*(outResult: var Mat4; fov: array[4, float32]; near: float32;
                     far: float32; oglNdc: bool = false) {.inline.} =
    mtxLHProj_impl(outResult, fov[0], fov[1], fov[2], fov[3], near, far, oglNdc)

proc mtxRHProj_impl*(outResult: var Mat4; fov: array[4, float32]; near: float32;
                     far: float32; oglNdc: bool = false) {.inline.} =
    mtxRHProj_impl(outResult, fov[0], fov[1], fov[2], fov[3], near, far, oglNdc)

proc mtxLHProj_impl*(outResult: var Mat4; fovy: float32; aspect: float32; near: float32;
                     far: float32; oglNdc: bool = false) {.inline.} =
    var height: float32 = 1.0'f32 / tan(toRad(fovy) * 0.5'f32)
    var width: float32 = height * 1.0'f32 / aspect
    mtxLHProjXYWH(outResult, 0.0'f32, 0.0'f32, width, height, near, far, oglNdc)

proc mtxRHProj_impl*(outResult: var Mat4; fovy: float32; aspect: float32; near: float32;
                     far: float32; oglNdc: bool = false) {.inline.} =
    var height: float32 = 1.0'f32 / tan(toRad(fovy) * 0.5'f32)
    var width: float32 = height * 1.0'f32 / aspect
    mtxRHProjXYWH(outResult, 0.0'f32, 0.0'f32, width, height, near, far, oglNdc)

proc mtxProj*(outResult: var Mat4; ut: float32; dt: float32; lt: float32; rt: float32;
              near: float32; far: float32; oglNdc: bool = false) {.inline.} =
    mtxLHProj_impl(outResult, ut, dt, lt, rt, near, far, oglNdc)

proc mtxProj*(outResult: var Mat4; fov: array[4, float32]; near: float32; far: float32;
              oglNdc: bool = false) {.inline.} =
    mtxLHProj_impl(outResult, fov, near, far, oglNdc)

proc mtxProj*(outResult: var Mat4; fovy: float32; aspect: float32; near: float32;
              far: float32; oglNdc: bool = false) {.inline.} =
    mtxLHProj_impl(outResult, fovy, aspect, near, far, oglNdc)

proc mtxProjLh*(outResult: var Mat4; ut: float32; dt: float32; lt: float32; rt: float32;
                near: float32; far: float32; oglNdc: bool = false) {.inline.} =
    mtxLHProj_impl(outResult, ut, dt, lt, rt, near, far, oglNdc)

proc mtxProjLh*(outResult: var Mat4; fov: array[4, float32]; near: float32; far: float32;
                oglNdc: bool = false) {.inline.} =
    mtxLHProj_impl(outResult, fov, near, far, oglNdc)

proc mtxProjLh*(outResult: var Mat4; fovy: float32; aspect: float32; near: float32;
                far: float32; oglNdc: bool = false) {.inline.} =
    mtxLHProj_impl(outResult, fovy, aspect, near, far, oglNdc)

proc mtxProjRh*(outResult: var Mat4; ut: float32; dt: float32; lt: float32; rt: float32;
                near: float32; far: float32; oglNdc: bool = false) {.inline.} =
    mtxRHProj_impl(outResult, ut, dt, lt, rt, near, far, oglNdc)

proc mtxProjRh*(outResult: var Mat4; fov: array[4, float32]; near: float32; far: float32;
                oglNdc: bool = false) {.inline.} =
    mtxRHProj_impl(outResult, fov, near, far, oglNdc)

proc mtxProjRh*(outResult: var Mat4; fovy: float32; aspect: float32; near: float32;
                far: float32; oglNdc: bool = false) {.inline.} =
    mtxRHProj_impl(outResult, fovy, aspect, near, far, oglNdc)

proc mtxProjLhInfXYWH*(outResult: var Mat4; x: float32; y: float32; width: float32;
                       height: float32; near: float32; oglNdc: bool = false;
                       NearFarT: bool = false) {.inline.} =
    var aa: float32
    var bb: float32
    if NearFarT:
        aa = if oglNdc: - 1.0'f32 else: 0.0'f32
        bb = if oglNdc: - (2.0'f32 * near) else: - near
    else:
        aa = 1.0'f32
        bb = if oglNdc: 2.0'f32 * near else: near
    fill(outResult, 0)
    outResult[0] = width
    outResult[5] = height
    outResult[8] = - x
    outResult[9] = - y
    outResult[10] = aa
    outResult[11] = 1.0'f32
    outResult[14] = - bb

proc mtxProjRhInfXYWH*(outResult: var Mat4; x: float32; y: float32; width: float32;
                       height: float32; near: float32; oglNdc: bool = false;
                       NearFarT: bool = false) {.inline.} =
    var aa: float32
    var bb: float32
    if NearFarT:
        aa = if oglNdc: - 1.0'f32 else: 0.0'f32
        bb = if oglNdc: - (2.0'f32 * near) else: - near
    else:
        aa = 1.0'f32
        bb = if oglNdc: 2.0'f32 * near else: near
    fill(outResult, 0)
    outResult[0] = width
    outResult[5] = height
    outResult[8] = x
    outResult[9] = y
    outResult[10] = - aa
    outResult[11] = - 1.0'f32
    outResult[14] = - bb

proc mtxProjLHInf_impl*(outResult: var Mat4; ut: float32; dt: float32; lt: float32;
                        rt: float32; near: float32; oglNdc: bool = false;
                        NearFarT: bool = false) {.inline.} =
    var invDiffRl: float32 = 1.0'f32 / (rt - lt)
    var invDiffUd: float32 = 1.0'f32 / (ut - dt)
    var width: float32 = 2.0'f32 * near * invDiffRl
    var height: float32 = 2.0'f32 * near * invDiffUd
    var xx: float32 = (rt + lt) * invDiffRl
    var yy: float32 = (ut + dt) * invDiffUd
    mtxProjRHInfXYWH(outResult, xx, yy, width, height, near, oglNdc, NearFarT)

proc mtxProjRHInf_impl*(outResult: var Mat4; ut: float32; dt: float32; lt: float32;
                        rt: float32; near: float32; oglNdc: bool = false;
                        NearFarT: bool = false) {.inline.} =
    var invDiffRl: float32 = 1.0'f32 / (rt - lt)
    var invDiffUd: float32 = 1.0'f32 / (ut - dt)
    var width: float32 = 2.0'f32 * near * invDiffRl
    var height: float32 = 2.0'f32 * near * invDiffUd
    var xx: float32 = (rt + lt) * invDiffRl
    var yy: float32 = (ut + dt) * invDiffUd
    mtxProjLHInfXYWH(outResult, xx, yy, width, height, near, oglNdc, NearFarT)

proc mtxProjLHInf_impl*(outResult: var Mat4; fov: array[4, float32]; near: float32;
                        oglNdc: bool = false; NearFarT: bool = false) {.inline.} =
    mtxProjLHInf_impl(outResult, fov[0], fov[1], fov[2], fov[3], near, oglNdc, NearFarT)

proc mtxProjRHInf_impl*(outResult: var Mat4; fov: array[4, float32]; near: float32;
                        oglNdc: bool = false; NearFarT: bool = false) {.inline.} =
    mtxProjRHInf_impl(outResult, fov[0], fov[1], fov[2], fov[3], near, oglNdc, NearFarT)

proc mtxProjLHInf_impl*(outResult: var Mat4; fovy: float32; aspect: float32;
                        near: float32; oglNdc: bool = false; NearFarT: bool = false) {.inline.} =
    var height: float32 = 1.0'f32 / tan(toRad(fovy) * 0.5'f32)
    var width: float32 = height * 1.0'f32 / aspect
    mtxProjLHInfXYWH(outResult, 0.0'f32, 0.0'f32, width, height, near, oglNdc, NearFarT)

proc mtxProjRHInf_impl*(outResult: var Mat4; fovy: float32; aspect: float32;
                        near: float32; oglNdc: bool = false; NearFarT: bool = false) {.
        inline.} =
    var height: float32 = 1.0'f32 / tan(toRad(fovy) * 0.5'f32)
    var width: float32 = height * 1.0'f32 / aspect
    mtxProjRHInfXYWH(outResult, 0.0'f32, 0.0'f32, width, height, near, oglNdc, NearFarT)

proc mtxProjInf*(outResult: var Mat4; fov: array[4, float32]; near: float32;
                 oglNdc: bool = false; NearFarT: bool = false) {.inline.} =
    mtxProjLHInf_impl(outResult, fov, near, oglNdc, NearFarT)

proc mtxProjInf*(outResult: var Mat4; ut: float32; dt: float32; lt: float32; rt: float32;
                 near: float32; oglNdc: bool = false; NearFarT: bool = false) {.inline.} =
    mtxProjLHInf_impl(outResult, ut, dt, lt, rt, near, oglNdc, NearFarT)

proc mtxProjInf*(outResult: var Mat4; fovy: float32; aspect: float32; near: float32;
                 oglNdc: bool = false; NearFarT: bool = false) {.inline.} =
    mtxProjLHInf_impl(outResult, fovy, aspect, near, oglNdc, NearFarT)

proc mtxProjInfLh*(outResult: var Mat4; ut: float32; dt: float32; lt: float32; rt: float32;
                   near: float32; oglNdc: bool = false; NearFarT: bool = false) {.inline.} =
    mtxProjLHInf_impl(outResult, ut, dt, lt, rt, near, oglNdc, NearFarT)

proc mtxProjInfLh*(outResult: var Mat4; fov: array[4, float32]; near: float32;
                   oglNdc: bool = false; NearFarT: bool = false) {.inline.} =
    mtxProjLHInf_impl(outResult, fov, near, oglNdc, NearFarT)

proc mtxProjInfLh*(outResult: var Mat4; fovy: float32; aspect: float32; near: float32;
                   oglNdc: bool = false; NearFarT: bool = false) {.inline.} =
    mtxProjLHInf_impl(outResult, fovy, aspect, near, oglNdc, NearFarT)

proc mtxProjInfRh*(outResult: var Mat4; ut: float32; dt: float32; lt: float32; rt: float32;
                   near: float32; oglNdc: bool = false; NearFarT: bool = false) {.inline.} =
    mtxProjRHInf_impl(outResult, ut, dt, lt, rt, near, oglNdc, NearFarT)

proc mtxProjInfRh*(outResult: var Mat4; fov: array[4, float32]; near: float32;
                   oglNdc: bool = false; NearFarT: bool = false) {.inline.} =
    mtxProjRHInf_impl(outResult, fov, near, oglNdc, NearFarT)

proc mtxProjInfRh*(outResult: var Mat4; fovy: float32; aspect: float32; near: float32;
                   oglNdc: bool = false; NearFarT: bool = false) {.inline.} =
    mtxProjRHInf_impl(outResult, fovy, aspect, near, oglNdc, NearFarT)

proc mtxProjRevInfLh*(outResult: var Mat4; ut: float32; dt: float32; lt: float32;
                      rt: float32; near: float32; oglNdc: bool = false;
                      NearFarT: bool = false) {.inline.} =
    mtxProjLHInf_impl(outResult, ut, dt, lt, rt, near, oglNdc, NearFarT)

proc mtxProjRevInfLh*(outResult: var Mat4; fov: array[4, float32]; near: float32;
                      oglNdc: bool = false; NearFarT: bool = false) {.inline.} =
    mtxProjLHInf_impl(outResult, fov, near, oglNdc, NearFarT)

proc mtxProjRevInfLh*(outResult: var Mat4; fovy: float32; aspect: float32; near: float32;
                      oglNdc: bool = false; NearFarT: bool = false) {.inline.} =
    mtxProjLHInf_impl(outResult, fovy, aspect, near, oglNdc, NearFarT)

proc mtxProjRevInfRh*(outResult: var Mat4; ut: float32; dt: float32; lt: float32;
                      rt: float32; near: float32; oglNdc: bool = false;
                      NearFarT: bool = false) {.inline.} =
    mtxProjRHInf_impl(outResult, ut, dt, lt, rt, near, oglNdc, NearFarT)

proc mtxProjRevInfRh*(outResult: var Mat4; fov: array[4, float32]; near: float32;
                      oglNdc: bool = false; NearFarT: bool = false) {.inline.} =
    mtxProjRHInf_impl(outResult, fov, near, oglNdc, NearFarT)

proc mtxProjRevInfRh*(outResult: var Mat4; fovy: float32; aspect: float32; near: float32;
                      oglNdc: bool = false; NearFarT: bool = false) {.inline.} =
    mtxProjRHInf_impl(outResult, fovy, aspect, near, oglNdc, NearFarT)

proc mtxOrthoLH_impl*(outResult: var Mat4; left: float32; right: float32;
                      bottom: float32; top: float32; near: float32; far: float32;
                      offset: float32 = 0.0'f32; oglNdc: bool = false) {.inline.} =
    var aa: float32 = 2.0'f32 / (right - left)
    var bb: float32 = 2.0'f32 / (top - bottom)
    var cc: float32 = (if oglNdc: 2.0'f32 else: 1.0'f32) / (far - near)
    var dd: float32 = (left + right) / (left - right)
    var ee: float32 = (top + bottom) / (bottom - top)
    var ff: float32 = if oglNdc: (near + far) / (near - far) else: near / (near - far)
    fill(outResult, 0.0'f32)
    outResult[0] = aa
    outResult[5] = bb
    outResult[10] = cc
    outResult[12] = dd + offset
    outResult[13] = ee
    outResult[14] = ff
    outResult[15] = 1.0'f32

proc mtxOrthoRH_impl*(outResult: var Mat4; left: float32; right: float32;
                      bottom: float32; top: float32; near: float32; far: float32;
                      offset: float32 = 0.0'f32; oglNdc: bool = false) {.inline.} =
    var aa: float32 = 2.0'f32 / (right - left)
    var bb: float32 = 2.0'f32 / (top - bottom)
    var cc: float32 = (if oglNdc: 2.0'f32 else: 1.0'f32) / (far - near)
    var dd: float32 = (left + right) / (left - right)
    var ee: float32 = (top + bottom) / (bottom - top)
    var ff: float32 = if oglNdc: (near + far) / (near - far) else: near / (near - far)
    fill(outResult, 0.0'f32)
    outResult[0] = aa
    outResult[5] = bb
    outResult[10] = - cc
    outResult[12] = dd + offset
    outResult[13] = ee
    outResult[14] = ff
    outResult[15] = 1.0'f32

proc mtxOrtho*(outResult: var Mat4; left: float32; right: float32; bottom: float32;
               top: float32; near: float32; far: float32; offset: float32 = 0.0'f32;
               oglNdc: bool = false) {.inline.} =
    mtxOrthoLH_impl(outResult, left, right, bottom, top, near, far, offset, oglNdc)

proc mtxOrthoLh*(outResult: var Mat4; left: float32; right: float32; bottom: float32;
                 top: float32; near: float32; far: float32; offset: float32 = 0.0'f32;
                 oglNdc: bool = false) {.inline.} =
    mtxOrthoLH_impl(outResult, left, right, bottom, top, near, far, offset, oglNdc)

proc mtxOrthoRh*(outResult: var Mat4; left: float32; right: float32; bottom: float32;
                 top: float32; near: float32; far: float32; offset: float32 = 0.0'f32;
                 oglNdc: bool = false) {.inline.} =
    mtxOrthoRH_impl(outResult, left, right, bottom, top, near, far, offset, oglNdc)

proc mtxRotateX*(outResult: var Mat4; ax: float32) {.inline.} =
    var sx: float32 = fsin(ax)
    var cx: float32 = fcos(ax)
    fill(outResult, 0)
    outResult[0] = 1.0'f32
    outResult[5] = cx
    outResult[6] = - sx
    outResult[9] = sx
    outResult[10] = cx
    outResult[15] = 1.0'f32

proc mtxRotateY*(outResult: var Mat4; ay: float32) {.inline.} =
    var sy: float32 = fsin(ay)
    var cy: float32 = fcos(ay)
    fill(outResult, 0.0'f32)
    outResult[0] = cy
    outResult[2] = sy
    outResult[5] = 1.0'f32
    outResult[8] = - sy
    outResult[10] = cy
    outResult[15] = 1.0'f32

proc mtxRotateZ*(outResult: var Mat4; az: float32) {.inline.} =
    var sz: float32 = fsin(az)
    var cz: float32 = fcos(az)
    fill(outResult, 0.0'f32)
    outResult[0] = cz
    outResult[1] = - sz
    outResult[4] = sz
    outResult[5] = cz
    outResult[10] = 1.0'f32
    outResult[15] = 1.0'f32

proc mtxRotateXY*(outResult: var Mat4; ax: float32; ay: float32) {.inline.} =
    var sx: float32 = fsin(ax)
    var cx: float32 = fcos(ax)
    var sy: float32 = fsin(ay)
    var cy: float32 = fcos(ay)
    fill(outResult, 0.0'f32)
    outResult[0] = cy
    outResult[2] = sy
    outResult[4] = sx * sy
    outResult[5] = cx
    outResult[6] = - (sx * cy)
    outResult[8] = - (cx * sy)
    outResult[9] = sx
    outResult[10] = cx * cy
    outResult[15] = 1.0'f32

proc mtxRotateXYZ*(outResult: var Mat4; ax: float32; ay: float32; az: float32) {.inline.} =
    var sx: float32 = fsin(ax)
    var cx: float32 = fcos(ax)
    var sy: float32 = fsin(ay)
    var cy: float32 = fcos(ay)
    var sz: float32 = fsin(az)
    var cz: float32 = fcos(az)
    fill(outResult, 0.0'f32)
    outResult[0] = cy * cz
    outResult[1] = - (cy * sz)
    outResult[2] = sy
    outResult[4] = cz * sx * sy + cx * sz
    outResult[5] = cx * cz - sx * sy * sz
    outResult[6] = - (cy * sx)
    outResult[8] = - (cx * cz * sy) + sx * sz
    outResult[9] = cz * sx + cx * sy * sz
    outResult[10] = cx * cy
    outResult[15] = 1.0'f32

proc mtxRotateZYX*(outResult: var Mat4; ax: float32; ay: float32; az: float32) {.inline.} =
    var sx: float32 = fsin(ax)
    var cx: float32 = fcos(ax)
    var sy: float32 = fsin(ay)
    var cy: float32 = fcos(ay)
    var sz: float32 = fsin(az)
    var cz: float32 = fcos(az)
    fill(outResult, 0.0'f32)
    outResult[0] = cy * cz
    outResult[1] = cz * sx * sy - cx * sz
    outResult[2] = cx * cz * sy + sx * sz
    outResult[4] = cy * sz
    outResult[5] = cx * cz + sx * sy * sz
    outResult[6] = - (cz * sx) + cx * sy * sz
    outResult[8] = - sy
    outResult[9] = cy * sx
    outResult[10] = cx * cy
    outResult[15] = 1.0'f32

proc mtxSRT*(outResult: var Mat4; sx, sy, sz, ax, ay, az, tx, ty, tz: float32) {.inline.} =
    let lsx = fsin(ax)
    let lcx = fcos(ax)
    let lsy = fsin(ay)
    let lcy = fcos(ay)
    let lsz = fsin(az)
    let lcz = fcos(az)
    let sxsz = lsx * lsz
    let cycz = lcy * lcz
    outResult[0] = sx * (cycz - sxsz * lsy)
    outResult[1] = sx * - (lcx * lsz)
    outResult[2] = sx * (lcz * lsy + lcy * sxsz)
    outResult[3] = 0.0'f32
    outResult[4] = sy * (lcz * lsx * lsy + lcy * lsz)
    outResult[5] = sy * lcx * lcz
    outResult[6] = sy * (lsy * lsz - cycz * lsx)
    outResult[7] = 0.0'f32
    outResult[8] = sz * - (lcx * lsy)
    outResult[9] = sz * lsx
    outResult[10] = sz * lcx * lcy
    outResult[11] = 0.0'f32
    outResult[12] = tx
    outResult[13] = ty
    outResult[14] = tz
    outResult[15] = 1.0'f32

proc vec3MulMtx*(outResult: var Vec3; vec: Vec3; mat: Mat4) {.inline.} =
    outResult[0] = vec[0] * mat[0] + vec[1] * mat[4] + vec[2] * mat[8] + mat[12]
    outResult[1] = vec[0] * mat[1] + vec[1] * mat[5] + vec[2] * mat[9] + mat[13]
    outResult[2] = vec[0] * mat[2] + vec[1] * mat[6] + vec[2] * mat[10] + mat[14]

proc vec3MulMtxH*(outResult: var Vec3; vec: Vec3; mat: Mat4) {.inline.} =
    var xx: float32 = vec[0] * mat[0] + vec[1] * mat[4] + vec[2] * mat[8] + mat[12]
    var yy: float32 = vec[0] * mat[1] + vec[1] * mat[5] + vec[2] * mat[9] + mat[13]
    var zz: float32 = vec[0] * mat[2] + vec[1] * mat[6] + vec[2] * mat[10] + mat[14]
    var ww: float32 = vec[0] * mat[3] + vec[1] * mat[7] + vec[2] * mat[11] + mat[15]
    var invW: float32 = fsign(ww) / ww
    outResult[0] = xx * invW
    outResult[1] = yy * invW
    outResult[2] = zz * invW

type Vec4* = array[4, float32]

proc vec4MulMtx*(outResult: var Vec4; vec: Vec4; mat: Mat4) {.inline.} =
    outResult[0] = vec[0] * mat[0] + vec[1] * mat[4] + vec[2] * mat[8] + vec[3] * mat[12]
    outResult[1] = vec[0] * mat[1] + vec[1] * mat[5] + vec[2] * mat[9] + vec[3] * mat[13]
    outResult[2] = vec[0] * mat[2] + vec[1] * mat[6] + vec[2] * mat[10] + vec[3] * mat[14]
    outResult[3] = vec[0] * mat[3] + vec[1] * mat[7] + vec[2] * mat[11] + vec[3] * mat[15]

proc mtxMul*(outResult: var Mat4; a: Mat4; b: Mat4) {.inline.} =
    # [0..3]
    outResult[0 ] = a[0 ] * b[0] + a[1 ] * b[4] + a[2 ] * b[8 ] + a[3 ] * b[12]
    outResult[1 ] = a[0 ] * b[1] + a[1 ] * b[5] + a[2 ] * b[9 ] + a[3 ] * b[13]
    outResult[2 ] = a[0 ] * b[2] + a[1 ] * b[6] + a[2 ] * b[10] + a[3 ] * b[14]
    outResult[3 ] = a[0 ] * b[3] + a[1 ] * b[7] + a[2 ] * b[11] + a[3 ] * b[15]
    # [4..7]
    outResult[4 ] = a[4 ] * b[0] + a[5 ] * b[4] + a[6 ] * b[8 ] + a[7 ] * b[12]
    outResult[5 ] = a[4 ] * b[1] + a[5 ] * b[5] + a[6 ] * b[9 ] + a[7 ] * b[13]
    outResult[6 ] = a[4 ] * b[2] + a[5 ] * b[6] + a[6 ] * b[10] + a[7 ] * b[14]
    outResult[7 ] = a[4 ] * b[3] + a[5 ] * b[7] + a[6 ] * b[11] + a[7 ] * b[15]
    # [8..11]
    outResult[8 ] = a[8 ] * b[0] + a[9 ] * b[4] + a[10] * b[8 ] + a[11] * b[12]
    outResult[9 ] = a[8 ] * b[1] + a[9 ] * b[5] + a[10] * b[9 ] + a[11] * b[13]
    outResult[10] = a[8 ] * b[2] + a[9 ] * b[6] + a[10] * b[10] + a[11] * b[14]
    outResult[11] = a[8 ] * b[3] + a[9 ] * b[7] + a[10] * b[11] + a[11] * b[15]
    # [12..15]
    outResult[12] = a[12] * b[0] + a[13] * b[4] + a[14] * b[8 ] + a[15] * b[12]
    outResult[13] = a[12] * b[1] + a[13] * b[5] + a[14] * b[9 ] + a[15] * b[13]
    outResult[14] = a[12] * b[2] + a[13] * b[6] + a[14] * b[10] + a[15] * b[14]
    outResult[15] = a[12] * b[3] + a[13] * b[7] + a[14] * b[11] + a[15] * b[15]

proc mtxTranspose*(outResult: var Mat4; a: Mat4) {.inline.} =
    outResult[0] = a[0]
    outResult[4] = a[1]
    outResult[8] = a[2]
    outResult[12] = a[3]
    outResult[1] = a[4]
    outResult[5] = a[5]
    outResult[9] = a[6]
    outResult[13] = a[7]
    outResult[2] = a[8]
    outResult[6] = a[9]
    outResult[10] = a[10]
    outResult[14] = a[11]
    outResult[3] = a[12]
    outResult[7] = a[13]
    outResult[11] = a[14]
    outResult[15] = a[15]

proc mtx3Inverse*(outResult: var Mat4; a: Mat4) {.inline.} =
    var xx: float32 = a[0]
    var xy: float32 = a[1]
    var xz: float32 = a[2]
    var yx: float32 = a[3]
    var yy: float32 = a[4]
    var yz: float32 = a[5]
    var zx: float32 = a[6]
    var zy: float32 = a[7]
    var zz: float32 = a[8]
    var det: float32 = 0.0'f32
    det += xx * (yy * zz - yz * zy)
    det -= xy * (yx * zz - yz * zx)
    det += xz * (yx * zy - yy * zx)
    var invDet: float32 = 1.0'f32 / det
    outResult[0] = + ((yy * zz - yz * zy) * invDet)
    outResult[1] = - ((xy * zz - xz * zy) * invDet)
    outResult[2] = + ((xy * yz - xz * yy) * invDet)
    outResult[3] = - ((yx * zz - yz * zx) * invDet)
    outResult[4] = + ((xx * zz - xz * zx) * invDet)
    outResult[5] = - ((xx * yz - xz * yx) * invDet)
    outResult[6] = + ((yx * zy - yy * zx) * invDet)
    outResult[7] = - ((xx * zy - xy * zx) * invDet)
    outResult[8] = + ((xx * yy - xy * yx) * invDet)

proc mtxInverse*(outResult: var Mat4; a: Mat4) {.inline.} =
    var xx: float32 = a[0]
    var xy: float32 = a[1]
    var xz: float32 = a[2]
    var xw: float32 = a[3]
    var yx: float32 = a[4]
    var yy: float32 = a[5]
    var yz: float32 = a[6]
    var yw: float32 = a[7]
    var zx: float32 = a[8]
    var zy: float32 = a[9]
    var zz: float32 = a[10]
    var zw: float32 = a[11]
    var wx: float32 = a[12]
    var wy: float32 = a[13]
    var wz: float32 = a[14]
    var ww: float32 = a[15]
    var det: float32 = 0.0'f32
    det += xx * (yy * (zz * ww - zw * wz) - yz * (zy * ww - zw * wy) + yw * (zy * wz - zz * wy))
    det -= xy * (yx * (zz * ww - zw * wz) - yz * (zx * ww - zw * wx) + yw * (zx * wz - zz * wx))
    det += xz * (yx * (zy * ww - zw * wy) - yy * (zx * ww - zw * wx) + yw * (zx * wy - zy * wx))
    det -= xw * (yx * (zy * wz - zz * wy) - yy * (zx * wz - zz * wx) + yz * (zx * wy - zy * wx))
    var invDet: float32 = 1.0'f32 / det
    outResult[0] = + ((yy * (zz * ww - wz * zw) - yz * (zy * ww - wy * zw) + yw * (zy * wz - wy * zz)) * invDet)
    outResult[1] = - ((xy * (zz * ww - wz * zw) - xz * (zy * ww - wy * zw) + xw * (zy * wz - wy * zz)) * invDet)
    outResult[2] = + ((xy * (yz * ww - wz * yw) - xz * (yy * ww - wy * yw) + xw * (yy * wz - wy * yz)) * invDet)
    outResult[3] = - ((xy * (yz * zw - zz * yw) - xz * (yy * zw - zy * yw) + xw * (yy * zz - zy * yz)) * invDet)
    outResult[4] = - ((yx * (zz * ww - wz * zw) - yz * (zx * ww - wx * zw) + yw * (zx * wz - wx * zz)) * invDet)
    outResult[5] = + ((xx * (zz * ww - wz * zw) - xz * (zx * ww - wx * zw) + xw * (zx * wz - wx * zz)) * invDet)
    outResult[6] = - ((xx * (yz * ww - wz * yw) - xz * (yx * ww - wx * yw) + xw * (yx * wz - wx * yz)) * invDet)
    outResult[7] = + ((xx * (yz * zw - zz * yw) - xz * (yx * zw - zx * yw) + xw * (yx * zz - zx * yz)) * invDet)
    outResult[8] = + ((yx * (zy * ww - wy * zw) - yy * (zx * ww - wx * zw) + yw * (zx * wy - wx * zy)) * invDet)
    outResult[9] = - ((xx * (zy * ww - wy * zw) - xy * (zx * ww - wx * zw) + xw * (zx * wy - wx * zy)) * invDet)
    outResult[10] = + ((xx * (yy * ww - wy * yw) - xy * (yx * ww - wx * yw) + xw * (yx * wy - wx * yy)) * invDet)
    outResult[11] = - ((xx * (yy * zw - zy * yw) - xy * (yx * zw - zx * yw) + xw * (yx * zy - zx * yy)) * invDet)
    outResult[12] = - ((yx * (zy * wz - wy * zz) - yy * (zx * wz - wx * zz) + yz * (zx * wy - wx * zy)) * invDet)
    outResult[13] = + ((xx * (zy * wz - wy * zz) - xy * (zx * wz - wx * zz) + xz * (zx * wy - wx * zy)) * invDet)
    outResult[14] = - ((xx * (yy * wz - wy * yz) - xy * (yx * wz - wx * yz) + xz * (yx * wy - wx * yy)) * invDet)
    outResult[15] = + ((xx * (yy * zz - zy * yz) - xy * (yx * zz - zx * yz) + xz * (yx * zy - zx * yy)) * invDet)

#/ Convert LH to RH projection matrix and vice versa.

proc mtxProjFlipHandedness*(dst: var Mat4; src: Mat4) {.inline.} =
    dst[0] = - src[0]
    dst[1] = - src[1]
    dst[2] = - src[2]
    dst[3] = - src[3]
    dst[4] = src[4]
    dst[5] = src[5]
    dst[6] = src[6]
    dst[7] = src[7]
    dst[8] = - src[8]
    dst[9] = - src[9]
    dst[10] = - src[10]
    dst[11] = - src[11]
    dst[12] = src[12]
    dst[13] = src[13]
    dst[14] = src[14]
    dst[15] = src[15]

#/ Convert LH to RH view matrix and vice versa.

proc mtxViewFlipHandedness*(dst: var Mat4; src: Mat4) {.inline.} =
    dst[0] = - src[0]
    dst[1] = src[1]
    dst[2] = - src[2]
    dst[3] = src[3]
    dst[4] = - src[4]
    dst[5] = src[5]
    dst[6] = - src[6]
    dst[7] = src[7]
    dst[8] = - src[8]
    dst[9] = src[9]
    dst[10] = - src[10]
    dst[11] = src[11]
    dst[12] = - src[12]
    dst[13] = src[13]
    dst[14] = - src[14]
    dst[15] = src[15]

proc calcNormal*(outResult: var Vec3; va: Vec3; vb: Vec3; vc: Vec3) {.inline.} =
    var ba: array[3, float32]
    vec3Sub(ba, vb, va)
    var ca: array[3, float32]
    vec3Sub(ca, vc, va)
    var baxca: array[3, float32]
    vec3Cross(baxca, ba, ca)
    vec3Norm(outResult, baxca)

proc calcPlane*(outResult: var Vec4; va: Vec3; vb: Vec3; vc: Vec3) {.inline.} =
    var normal: array[3, float32]
    calcNormal(normal, va, vb, vc)
    outResult[0] = normal[0]
    outResult[1] = normal[1]
    outResult[2] = normal[2]
    outResult[3] = - vec3Dot(normal, va)

type Vec2* = array[2, float32]

proc calcLinearFit2D*(outResult: var Vec2; points: pointer; stride: int;
                      numPoints: uint32) {.inline.} =
    var sumX: float32 = 0.0'f32
    var sumY: float32 = 0.0'f32
    var sumXX: float32 = 0.0'f32
    var sumXY: float32 = 0.0'f32
    var pointsptr: ByteAddress = cast[ByteAddress](points)
    var ii: uint32 = 0
    while ii < numPoints:
        var point: Vec2 = cast[Vec2](pointsptr)
        var xx: float32 = point[0]
        var yy: float32 = point[1]
        sumX += xx
        sumY += yy
        sumXX += xx * xx
        sumXY += xx * yy
        inc(ii)
        inc(pointsptr, stride)
    # [ sum(x^2) sum(x)] [ A ] = [ sum(x*y) ]
    # [ sum(x) numPoints ] [ B ] [ sum(y) ]
    var det: float32 = (sumXX * cast[float32](numPoints) - sumX * sumX)
    var invDet: float32 = 1.0'f32 / det
    outResult[0] = (- (sumX * sumY) + cast[float32](numPoints) * sumXY) * invDet
    outResult[1] = (sumXX * sumY - sumX * sumXY) * invDet

proc calcLinearFit3D*(outResult: var Vec3; points: pointer; stride: int;
                      numPoints: uint32) {.inline.} =
    var sumX: float32 = 0.0'f32
    var sumY: float32 = 0.0'f32
    var sumZ: float32 = 0.0'f32
    var sumXX: float32 = 0.0'f32
    var sumXY: float32 = 0.0'f32
    var sumXZ: float32 = 0.0'f32
    var sumYY: float32 = 0.0'f32
    var sumYZ: float32 = 0.0'f32
    var pointsptr: ByteAddress = cast[ByteAddress](points)
    var ii: uint32 = 0
    while ii < numPoints:
        var point: Vec3 = cast[Vec3](pointsptr)
        var xx: float32 = point[0]
        var yy: float32 = point[1]
        var zz: float32 = point[2]
        sumX += xx
        sumY += yy
        sumZ += zz
        sumXX += xx * xx
        sumXY += xx * yy
        sumXZ += xx * zz
        sumYY += yy * yy
        sumYZ += yy * zz
        inc(ii)
        inc(pointsptr, stride)
    # [ sum(x^2) sum(x*y) sum(x)        ] [ A ]     [ sum(x*z) ]
    # [ sum(x*y) sum(y^2) sum(y)        ] [ B ] = [ sum(y*z) ]
    # [ sum(x)     sum(y)     numPoints ] [ C ]     [ sum(z)     ]
    var mtx: Mat4
    fill(mtx, 0.0'f32)
    mtx[0..8] = [sumXX, sumXY, sumX, sumXY, sumYY, sumY, sumX, sumY, float32(numPoints)]
    var invMtx: Mat4
    mtx3Inverse(invMtx, mtx)
    outResult[0] = invMtx[0] * sumXZ + invMtx[1] * sumYZ + invMtx[2] * sumZ
    outResult[1] = invMtx[3] * sumXZ + invMtx[4] * sumYZ + invMtx[5] * sumZ
    outResult[2] = invMtx[6] * sumXZ + invMtx[7] * sumYZ + invMtx[8] * sumZ

proc rgbToHsv*(hsv: var Vec3; rgb: Vec3) {.inline.} =
    var rr: float32 = rgb[0]
    var gg: float32 = rgb[1]
    var bb: float32 = rgb[2]
    var s0: float32 = fstep(bb, gg)
    var px: float32 = flerp(bb, gg, s0)
    var py: float32 = flerp(gg, bb, s0)
    var pz: float32 = flerp(- 1.0'f32, 0.0'f32, s0)
    var pw: float32 = flerp(2.0'f32 / 3.0'f32, - (1.0'f32 / 3.0'f32), s0)
    var s1: float32 = fstep(px, rr)
    var qx: float32 = flerp(px, rr, s1)
    var qy: float32 = py
    var qz: float32 = flerp(pw, pz, s1)
    var qw: float32 = flerp(rr, px, s1)
    var dd: float32 = qx - fmin(qw, qy)
    var ee: float32 = 1e-010
    hsv[0] = fabsolute(qz + (qw - qy) / (6.0'f32 * dd + ee))
    hsv[1] = dd / (qx + ee)
    hsv[2] = qx

proc hsvToRgb*(rgb: var Vec3; hsv: Vec3) {.inline.} =
    var hh: float32 = hsv[0]
    var ss: float32 = hsv[1]
    var vv: float32 = hsv[2]
    var px: float32 = fabsolute(ffract(hh + 1.0'f32) * 6.0'f32 - 3.0'f32)
    var py: float32 = fabsolute(ffract(hh + 2.0'f32 / 3.0'f32) * 6.0'f32 - 3.0'f32)
    var pz: float32 = fabsolute(ffract(hh + 1.0'f32 / 3.0'f32) * 6.0'f32 - 3.0'f32)
    rgb[0] = vv * flerp(1.0'f32, fsaturate(px - 1.0'f32), ss)
    rgb[1] = vv * flerp(1.0'f32, fsaturate(py - 1.0'f32), ss)
    rgb[2] = vv * flerp(1.0'f32, fsaturate(pz - 1.0'f32), ss)