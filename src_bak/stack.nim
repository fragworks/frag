# FastStack
# Copyright (c) 2016 Vladar
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Vladar vladar4@gmail.com


##  FastStack is dynamically resizable data structure
##  optimized for fast iteration over the large arrays
##  of similar elements avoiding memory fragmentation
##  (e.g., update and rendering cycles of a game scene).
##
##  ``Note:`` the indexes of items here are not set in stone,
##  could change after ``push``, ``inject``, or ``eject`` operations,
##  and may not start with `0`.
##


type
  FastStack*[T] = ref object of RootObj
    head, tail, size, growth: int
    body: ptr T


template `+`[T](p: ptr T, off: int): ptr T =
  cast[ptr T](cast[ByteAddress](p) +% off * sizeof(T))


template `[]`[T](p: ptr T, off: int): T =
  (p + off)[]


template`[]=`[T](p: ptr T, off: int, val: T) =
  (p + off)[] = val


proc init*[T](x: FastStack[T], size: int) =
  ##  Initializer. Resets ``x``.
  ##
  ##  ``size`` Initial size. Must be greater than `0`.
  ##
  assert(size > 0)
  x.head = 0
  x.tail = 0
  x.size = size
  x.growth = size
  if not x.body.isNil:
    dealloc(x.body)
  x.body = cast[ptr T](alloc0(size * sizeof(T)))


proc free*[T](x: FastStack[T]) =
  ##  Finalizer. ``MUST`` be called to deallocate the memory.
  ##
  if not x.body.isNil:
    dealloc(x.body)
  x.body = nil


proc flush*[T](x: FastStack[T]) =
  ##  Discard all items.
  ##
  x.head = 0
  x.tail = 0


proc reset*[T](x: FastStack[T]) =
  ##  Discard all items and reset to ``growth`` size.
  ##
  x.init(x.growth)


proc newFastStack*[T](size: int): FastStack[T] =
  ##  Constructor.
  ##
  ##  ``size``  Initial size. Must be greater than `0`.
  ##
  ##  It is best to set the maximum possible size
  ##  to avoid additional memory reallocations.
  ##
  assert(size > 0)
  new result, free[T]
  init result, size


proc len*(x: FastStack): int {.inline.} =
  ##  ``Return`` the number of stored items.
  ##
  x.tail - x.head


proc growth*(x: FastStack): int {.inline.} =
  ##  ``Return`` the current growth value
  ##  (for how much units ``x`` will reallocate if needed).
  ##
  x.growth


proc `growth=`*(x: FastStack, value: int) {.inline.} =
  ##  Set a new growth ``value``
  ##  (for how much units ``x`` will reallocate if needed).
  ##
  ##  Must be greater than `0`.
  ##
  assert(value > 0)
  x.growth = value


proc grow[T](x: FastStack[T]) =
  assert(x.size <= (high(int) - x.growth))  # check for the integer limit
  x.size += x.growth
  x.body = cast[ptr T](realloc(x.body, x.size * sizeof(T)))


proc add*[T](x: FastStack[T], item: T) =
  ##  Add a new ``item`` to the end of ``x``.
  ##
  if x.tail > 0:
    # the body is not empty

    if x.tail >= x.size:
      # the tail reached the end, need to grow
      x.grow()

  # add new item
  x.body[x.tail] = item
  inc x.tail


proc pop*[T](x: FastStack[T]): T =
  ##  ``Return`` the last item and remove it from ``x``.
  ##
  if x.tail < 1:
    # the body is empty
    return

  dec x.tail
  return x.body[x.tail]


proc shiftRight[T](x: FastStack[T], start: int) =
  if x.tail >= x.size:
    x.grow()
  for idx in countdown(x.tail, start + 1):
    x.body[idx] = x.body[idx - 1]
  inc x.tail


proc shiftLeft[T](x: FastStack[T], start: int) =
  for idx in start..(x.tail - 1):
    x.body[idx] = x.body[idx + 1]
  dec x.tail


proc splitLeft[T](x: FastStack[T], start: int) =
  assert(x.head > 0)
  for idx in (x.head - 1)..(start - 2):
    x.body[idx] = x.body[idx + 1]
  dec x.head


proc push*[T](x: FastStack[T], item: T) =
  ##  Add a new ``item`` to the start of ``x``.
  ##
  ##  Slow operation.
  ##
  if x.tail > 0:
    # the body is not empty

    if x.head < 1:
      # there isn't any free space in the start
      shiftRight(x, x.head)

    else:
      # there is a free space in the start
      dec x.head

  # add new item
  x.body[x.head] = item


proc pull*[T](x: FastStack[T]): T =
  ##  ``Return`` the first item and remove it from ``x``.
  ##
  if x.len < 1:
    # the body is empty
    return

  result = x.body[x.head]
  inc x.head


proc indexIsValid*[T](x: FastStack[T], index: int): bool {.inline.} =
  ##  ``Return`` `true` if ``index`` is valid, `false` otherwise.
  ##
  (index >= x.head) and (index < x.tail)


proc inject*[T](x: FastStack[T], value: T, index: int) =
  ##  Inject a new ``value`` into the index ``i``
  ##  shifting other items to the right starting with ``i``.
  ##
  ##  Slow operation.
  ##
  if index == x.head:
    x.push(value)
    return

  if x.indexIsValid(index):
    if x.head > 0:
      # there is a free space in the start
      splitLeft(x, index)

    else:
      # there isn't any free space in the start
      shiftRight(x, index)

    # after
    x.body[index] = value

  else:
    raise newException(IndexError, "Index " & $index & " is out of bounds.")


proc eject*[T](x: FastStack[T], index: int): T =
  ##  ``Return`` a value stored under the index ``i``
  ##  and remove it from ``x``.
  ##
  ##  Slow operation.
  ##
  if index == x.head:
    return x.pull()

  if index == (x.tail - 1):
    return x.pop()

  if x.indexIsValid(index):
    result = x.body[index]
    shiftLeft(x, index)

  else:
    raise newException(IndexError, "Index " & $index & " is out of bounds.")


template iteratePairs() =
  for idx in x.head..(x.tail - 1):
    yield (idx, x.body[idx])


template iterate() =
  for idx in x.head..(x.tail - 1):
    yield x.body[idx]

template iterateReverse() =
  for idx in countdown((x.tail-1), x.head):
    yield x.body[idx]


iterator pairs*[T](x: FastStack[T]): tuple [key: int, val: T] {.inline.} =
  ##  Iterates over each item. Yields ``(index, o[index])`` pairs.
  ##
  iteratePairs()


iterator mpairs*[T](x: FastStack[T]): tuple [key: int, val: var T] {.inline.} =
  ##  Iterates over each item. Yields ``(index, o[index])`` pairs.
  ##  ``o[index]`` can be modified.
  ##
  iteratePairs()


iterator items*[T](x: FastStack[T]): T {.inline.} =
  ##  Iterate over each item.
  ##
  iterate()

iterator itemsReverse*[T](x: FastStack[T]): T {.inline.} =
  ##  Iterate over each item.
  ##
  iterateReverse()


iterator mitems*[T](x: FastStack[T]): var T {.inline.} =
  ##  Iterates over each item so that you can modify the yielded value.
  ##
  iterate()


proc firstKey*(x: FastStack): int {.inline.} =
  ##  ``Return`` the index of the first item or `-1` if there's no items.
  ##
  if x.len < 1:
    return -1
  return x.head


proc firstVal*[T](x: FastStack[T]): T {.inline.} =
  ##  ``Return`` the value of the first item.
  ##
  if x.len < 1:
    return
  return x.body[x.head]


proc mFirstVal*[T](x: FastStack[T]): var T {.inline.} =
  ##  ``Return`` the value of the first item so that you can modify it.
  ##
  if x.len < 1:
    return
  return x.body[x.head]


proc lastKey*(x: FastStack): int {.inline.} =
  ##  ``Return`` the index of the last item or `-1` if there's no items.
  ##
  if x.len < 1:
    return -1
  return x.tail - 1


proc lastVal*[T](x: FastStack[T]): T {.inline.} =
  ##  ``Return`` the value of the last item.
  ##
  if x.len < 1:
    return
  return x.body[x.tail - 1]


proc mLastVal*[T](x: FastStack[T]): var T {.inline.} =
  ##  ``Return`` the value of the last item so you can modify it.
  ##
  if x.len < 1:
    return
  return x.body[x.tail - 1]


proc `$`*[T](x: FastStack[T]): string =
  ##  The stringify operator.
  ##
  result = "["
  for item in x.items:
    if result.len > 1: result.add(", ")
    result.add($item)
  result.add("]")


proc find*[T](x: FastStack[T], value: T): int =
  ##  ``Return`` the index of the first appearance of a ``value``,
  ##  or `-1` if there is no such value.
  ##
  ##  ``Note:`` the index may be changed after following operations:
  ##  ``push``, ``inject``, ``eject``.
  ##
  for pair in x.pairs:
    if pair.val == value:
      return pair.key
  return -1


proc contains*[T](x: FastStack[T], value: T): bool {.inline.} =
  ##  ``Return`` `true` if ``x`` contains `value`.
  ##
  x.find(value) > -1


proc `[]`*[T](x: FastStack[T], index: int): T =
  ##  ``Return`` a value stored under the index ``i``.
  ##
  ##  ``Note:`` the index may be changed after following operations:
  ##  ``push``, ``inject``, ``eject``.
  ##
  if x.indexIsValid(index):
    return x.body[index]
  raise newException(IndexError, "Index " & $index & " is out of bounds.")


proc `[]=`*[T](x: FastStack[T], index: int, value: T) =
  ##  Overwrite the `value` stored under the index `i`.
  ##
  ##  ``Note:`` the index may be changed after following operations:
  ##  ``push``, ``inject``, ``eject``.
  ##
  if x.indexIsValid(index):
    x.body[index] = value
    return
  raise newException(IndexError, "Index " & $index & " is out of bounds.")


proc dump*[T](x: FastStack[T]): string =
  ##  Debugging function.
  ##
  ##  ``Return`` all contents of ``x`` as string.
  ##
  result = "" & repr(x) & "["

  for idx in 0..(x.size-1):
    if idx > 0:
      result &= ", "
    result &= $x.body[idx]
  result &= "]"