import
  events

import
  sdl2 as sdl

import
  events/event

let defaultKeyboardState = sdl.getKeyboardState(nil)

type Input* = ref object
  pressedKeys, releasedKeys: seq[cint]
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
  echo repr event
  #let sdlEventMsg = SDLEventMessage(event)
  #pressedKeys.add(sdlEventMsg.event.key.keysym.sym)
  #echo repr sdlEventMsg.event.key.keysym.sym

proc onKeyUp*(event: EventArgs) {.procvar.} =
  discard
  #let msg = SDLEventMessage(event)
  #releasedKeys.add(msg.event.key.keysym.sym)

proc down*(this: Input, button: string): bool =
  var key = sdl.getKeyFromName(button)
  var code = sdl.getScancodeFromKey(key)
  echo $key & " " & $code
  # state[code] == 1

proc pressed*(this: Input, button: string): bool =
  sdl.getKeyFromName(button) in pressedKeys

proc released*(this: Input, button: string): bool =
  sdl.getKeyFromName(button) in releasedKeys
