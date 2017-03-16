import
  events

import
  sdl2 as sdl

import
  events/event

let defaultKeyboardState = sdl.getKeyboardState(nil)

type Input* = ref object
  pressedKeys*, releasedKeys: seq[cint]
  state: ptr array[0 .. SDL_NUM_SCANCODES.int, uint8]

proc init*(input: Input): bool =
  input.pressedKeys = @[]
  input.releasedKeys = @[]
  return true

proc update*(input: Input) =
  input.pressedKeys.setLen(0)
  input.releasedKeys.setLen(0)
  input.state = defaultKeyboardState

proc onKeyDown*(input: Input, event: sdl.Event) {.procvar.} =
  input.pressedKeys.add(event.key.keysym.sym)

proc onKeyUp*(input: Input, event: sdl.Event) {.procvar.} =
  input.releasedKeys.add(event.key.keysym.sym)

proc down*(input: Input, button: string): bool =
  let key = sdl.getKeyFromName(button)
  let code = sdl.getScancodeFromKey(key)
  echo $key & " " & $code
  input.state[code.int] == 1u8

proc pressed*(input: Input, button: string): bool =
  sdl.getKeyFromName(button) in input.pressedKeys

proc released*(input: Input, button: string): bool =
  sdl.getKeyFromName(button) in input.releasedKeys
