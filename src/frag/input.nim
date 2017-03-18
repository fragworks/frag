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

proc getScancode(input: Input, name: string, raw: bool): sdl.Scancode =
  if raw: return sdl.getScancodeFromName(name)
  let key = sdl.getKeyFromName(name)
  return sdl.getScancodeFromKey(key)

proc getKey(input: Input, name: string, raw: bool): cint =
  if not raw: return sdl.getKeyFromName(name)
  let code = sdl.getScancodeFromName(name)
  return sdl.getKeyFromScancode(code)

proc down*(input: Input, name: string, raw: bool = false): bool =
  let code = input.getScancode(name, raw)
  input.state[code.int] == 1u8

proc pressed*(input: Input, name: string, raw: bool = false): bool =
  input.getKey(name, raw) in input.pressedKeys

proc released*(input: Input, name: string, raw: bool = false): bool =
  input.getKey(name, raw) in input.releasedKeys
