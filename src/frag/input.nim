import
  events

import
  sdl2 as sdl

import
  events/event

var pressedKeys, releasedKeys: seq[cint]
var state = sdl.getKeyboardState(nil)

type Input* = ref object

proc init*(this: Input): bool =
  pressedKeys = @[]
  releasedKeys = @[]
  return true

proc update*(this: Input) =
  pressedKeys = @[]
  releasedKeys = @[]
  state = sdl.getKeyboardState(nil)

proc onKeyDown*(input: Input, event: sdl.Event) {.procvar.} =
  echo repr event
  #let sdlEventMsg = SDLEventMessage(event)
  #pressedKeys.add(sdlEventMsg.event.key.keysym.sym)
  #echo repr sdlEventMsg.event.key.keysym.sym

proc onKeyUp*(event: EventArgs) {.procvar.} =
  let msg = SDLEventMessage(event)
  releasedKeys.add(msg.event.key.keysym.sym)

proc down*(this: Input, button: string): bool =
  var key = sdl.getKeyFromName(button)
  var code = sdl.getScancodeFromKey(key)
  echo $key & " " & $code
  # state[code] == 1

proc pressed*(this: Input, button: string): bool =
  sdl.getKeyFromName(button) in pressedKeys

proc released*(this: Input, button: string): bool =
  sdl.getKeyFromName(button) in releasedKeys
