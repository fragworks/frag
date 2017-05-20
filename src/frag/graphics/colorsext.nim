import
  colors

proc extractRGBA*(a: Color): tuple[r, g, b, a: range[0..255]] =
  ## extracts the red/green/blue components of the color `a`.
  result.r = a.int shr 24 and 0xff
  result.g = a.int shr 16 and 0xff
  result.b = a.int shr 8 and 0xff
  result.a = a.int and 0xff

proc toFloats*(a: tuple[r, g, b, a: range[0..255]]): tuple[r, g, b, a: float] =
  result.r = a.r.float / 255.0
  result.g = a.g.float / 255.0
  result.b = a.b.float / 255.0
  result.a = a.a.float / 255.0