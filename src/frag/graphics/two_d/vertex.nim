type
  PosUVColorVertex* {.packed, pure.} = object
    x*, y*, z*: float32
    u*, v*: float32
    abgr*: uint32

