type
  Rectangle* = object
    x*, y*, width*, height*: float
  
proc intersects*(a, b: Rectangle): bool =
  let bRight = b.x + b.width
  let aRight = a.x + a.width
  let bBottom = b.y + b.height
  let aBottom = a.y + a.height

  a.x < bRight and aRight > b.x and a.y < bBottom and aBottom > b.y

proc translate*(a: var Rectangle, x, y: float) =
  a.x += x
  a.y += y


when isMainModule:
  let nonIntersectingRect = Rectangle(
    x: 0,
    y: 0,
    width: 100,
    height: 100
  )

  let intersectingRectOne = Rectangle(
    x: 101,
    y: 101,
    width: 100,
    height: 100
  )
  let intersectingRectTwo = Rectangle(
    x: 105,
    y: 105,
    width: 100,
    height: 100
  )

  assert intersects(nonIntersectingRect, intersectingRectOne) == false
  assert intersects(intersectingRectOne, intersectingRectTwo) == true