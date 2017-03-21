import
  events

import
  sdl2 as sdl

import
  ../config,
  module

let defaultKeyboardState = sdl.getKeyboardState(nil)

proc init*(this: Input): bool =
  this.pressedKeys = @[]
  this.releasedKeys = @[]
  return true

proc update*(this: Input) =
  this.pressedKeys.setLen(0)
  this.releasedKeys.setLen(0)
  this.state = defaultKeyboardState

proc onKeyDown*(this: Input, event: sdl.Event) {.procvar.} =
  this.pressedKeys.add(event.key.keysym.sym)

proc onKeyUp*(this: Input, event: sdl.Event) {.procvar.} =
  this.releasedKeys.add(event.key.keysym.sym)

proc getScancode(this: Input, name: string, raw: bool): sdl.Scancode =
  if raw: return sdl.getScancodeFromName(name)
  let key = sdl.getKeyFromName(name)
  return sdl.getScancodeFromKey(key)

proc getKey(this: Input, name: string, raw: bool): cint =
  if not raw: return sdl.getKeyFromName(name)
  let code = sdl.getScancodeFromName(name)
  return sdl.getKeyFromScancode(code)

proc down*(this: Input, name: string, raw: bool = false): bool =
  let code = this.getScancode(name, raw)
  this.state[code.int] == 1u8

proc pressed*(this: Input, name: string, raw: bool = false): bool =
  this.getKey(name, raw) in this.pressedKeys

proc released*(this: Input, name: string, raw: bool = false): bool =
  this.getKey(name, raw) in this.releasedKeys
