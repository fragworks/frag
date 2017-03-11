import math

when isMainModule:
  import unittest

# Type definition {{{1

type
  Rectangle*[T] = object
    left*, top*, right*, bottom*: T

proc newRectangle*[T](left, top, right, bottom: T) : Rectangle[T] =
  result = Rectangle[T]()
  result.left = left
  result.top = top
  result.right  = right
  result.bottom = bottom

# }}}

# Properties {{{1

proc Width*[T](self: Rectangle[T]): T {.inline.} =
  ## Calculates the width of this rectangle.
  result = 1 + self.right - self.left

proc Height*[T](self: Rectangle[T]): T {.inline.} =
  ## Calculates the height of this rectangle.
  result = 1 + self.bottom - self.top

# }}}

# Geometry {{{1

proc Union*[T](self, other: Rectangle[T]): Rectangle[T] =
  ## Return a rectangle which contains both input rectangles.
  result.left   = min(self.left   , other.left  )
  result.top    = min(self.top    , other.top   )
  result.right  = max(self.right  , other.right )
  result.bottom = max(self.bottom , other.bottom)

proc Difference*[T](self, other: Rectangle[T]): Rectangle[T] =
  ## Returns the difference between two rectangles. If both
  ## intersections overlap, this returns a rectangle which is contained
  ## by both input rectangles. If there is no overlap, then an inverse
  ## rectangle is returned that is contained by neither input rectangle.
  result.left   = max(self.left  , other.left  )
  result.top    = max(self.top   , other.top   )
  result.right  = min(self.right , other.right )
  result.bottom = min(self.bottom, other.bottom)

# }}}

# Adjustment {{{1

proc Set*[T](self: var Rectangle[T]; lf, tp, bm, rg: T) =
  ## Modifies the rectangle in-place, setting each element of the
  ## rectangle in a single procedure call.
  self.Left   = lf
  self.Top    = tp
  self.Bottom = bm
  self.Right  = rg

proc Set*[T](self: var Rectangle[T]; other: Rectangle[T]) =
  ## Modifies the rectangle in-place, setting each element of the
  ## rectangle to the same elements stored in another rectangle.
  self.Left   = other.Left
  self.Top    = other.Top
  self.Bottom = other.Bottom
  self.Right  = other.Right

proc Inflate*[T](self, other: Rectangle[T]): Rectangle[T] =
  ## Return a rectangle where each edge has been pushed outward by the
  ## other rectangle. Beware that inverted rectangles are a possible
  ## result.
  # NB: Seems like we could vectorize this.
  result.left   = self.left   - other.left
  result.top    = self.top    - other.top
  result.bottom = self.bottom + other.bottom
  result.right  = self.right  + other.right

proc Deflate*[T](self, other: Rectangle[T]): Rectangle[T] =
  ## Return a rectangle where each edge has been pushed inward by the
  ## other rectangle. Beware that inverted rectangles are a possible
  ## result.
  # NB: Seems like we could vectorize this.
  result.left   = self.left   + other.left
  result.top    = self.top    + other.top
  result.bottom = self.bottom - other.bottom
  result.right  = self.right  - other.right

proc Translate*[T](self: Rectangle[T]; x, y: T): Rectangle[T] =
  ## Translates each component of the rectangle. Also known as "moving"
  ## the rectangle in other toolkits.
  # NB: Seems like we could vectorize this.
  result.left   = self.left   + x
  result.right  = self.right  + x
  result.top    = self.top    + y
  result.bottom = self.bottom + y

# }}}

# Inversion {{{1

proc IsInverted*[T](self: Rectangle[T]): bool =
  return (self.Width < 0) or (self.Height < 0)

proc Invert*[T](self: Rectangle[T]): Rectangle[T] =
  result.left   = self.right
  result.right  = self.left
  result.top    = self.bottom
  result.bottom = self.top

# }}}

# Comparison {{{1

# Implementation {{{2

proc Contains*[T](self: Rectangle[T]; x, y: T): bool =
  ## Checks if a given [x, y] coordinate is contained by the source
  ## rectangle.
  if x < self.left  : return false
  if y < self.top   : return false
  if x >= self.right  : return false
  if y >= self.bottom : return false
  return true

proc Contains*[T](self, other: Rectangle[T]): bool =
  ## Checks if a given rectangle is wholly contained by the source
  ## rectangle.
  if other.left   <  self.left   : return false
  if other.top    <  self.top    : return false
  if other.right  >= self.right  : return false
  if other.bottom >= self.bottom : return false
  return true

proc Intersects*[T](self, other: Rectangle[T]): bool =
  ## Checks if a given rectangle has at least a partial intersection
  ## with the second rectangle.
  if self.Contains(other.left, other.top): return true
  if self.Contains(other.right, other.bottom): return true
  return false

# }}} impl

# Testing {{{2

when isMainModule:
  proc IntersectionTest() =
    debugEcho "== INTERSECTION TEST =="
    let big = Rectangle[int](left: 0,  top: 0,  right: 63, bottom: 63)
    let a = Rectangle[int](left: 0,  top: 0,  right: 31, bottom: 31)
    let b = Rectangle[int](left: 32, top: 0,  right: 63, bottom: 31)
    let c = Rectangle[int](left: 32, top: 32, right: 63, bottom: 63)
    let d = Rectangle[int](left: 0,  top: 32, right: 31, bottom: 63)

    doAssert big.intersects(a), "Big didn't intersect A"
    doAssert a.width  == 32
    doAssert a.height == 32
    doAssert a.intersects(a), "A didn't intersect itself"
    doAssert b.intersects(a) == false, "Intersection is incorrect."
    doAssert c.intersects(a) == false, "Intersection is incorrect."
    doAssert d.intersects(a) == false, "Intersection is incorrect."

    doAssert big.intersects(b), "Big didn't intersect B"
    doAssert b.width  == 32
    doAssert b.height == 32
    doAssert a.intersects(b) == false, "Intersection is incorrect."
    doAssert b.intersects(b), "B didn't intersect itself"
    doAssert c.intersects(b) == false, "Intersection is incorrect."
    doAssert d.intersects(b) == false, "Intersection is incorrect."

    doAssert big.intersects(c), "Big didn't intersect C"
    doAssert c.width  == 32
    doAssert c.height == 32
    doAssert a.intersects(c) == false, "Intersection is incorrect."
    doAssert b.intersects(c) == false, "Intersection is incorrect."
    doAssert c.intersects(c), "C didn't intersect itself"
    doAssert d.intersects(c) == false, "Intersection is incorrect."

    doAssert big.intersects(d), "Big didn't intersect D"
    doAssert d.width  == 32
    doAssert d.height == 32
    doAssert a.intersects(d) == false, "Intersection is incorrect."
    doAssert b.intersects(d) == false, "Intersection is incorrect."
    doAssert c.intersects(d) == false, "Intersection is incorrect."
    doAssert d.intersects(d), "D didn't intersect itself"

  IntersectionTest()

# }}} testing

# }}}

# Algebra {{{1

proc Area*[T](self: Rectangle[T]): T {.inline.} =
  ## Calculates the area of this rectangle.
  result = self.Width * self.Height

proc Perimeter*[T](self: Rectangle[T]): T {.inline.} =
  ## Calculates the perimeter of this rectangle.
  result = 2 * (self.Width + self.Height)

proc Diagnal*[T](self: Rectangle[T]): T {.inline.} =
  ## Calculates the diagnal of this rectangle.
  let w = self.Width
  let h = self.Height
  result = T(sqrt( (w * w) + (h * h) ))

# }}}
