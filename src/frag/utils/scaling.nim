import
  ../math/fpu_math

type
  ScalingType* = enum
    Fit, Fill, FillX, FillY, Stretch, StretchX, StretchY, None
  
  Scaling* = object
    scalingType*: ScalingType

var temp {.global.}: Vec2

proc apply*(scaling: Scaling, sourceWidth, sourceHeight, targetWidth, targetHeight: float): Vec2 =
  case scaling.scalingType
  of Fit:
    let targetRatio = targetHeight / targetWidth
    let sourceRatio = sourceHeight / sourceWidth
    let scale = if targetRatio > sourceRatio: targetWidth / sourceWidth else: targetHeight / sourceHeight
    temp[0] = sourceWidth * scale
    temp[1] = sourceHeight * scale
  else:
    discard
  
  return temp