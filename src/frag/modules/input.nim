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
  this.clickedButtons = @[]
  this.releasedButtons = @[]
  return true

proc update*(this: Input) =
  this.pressedKeys.setLen(0)
  this.releasedKeys.setLen(0)
  this.clickedButtons.setLen(0)
  this.releasedButtons.setLen(0)
  this.state = defaultKeyboardState
  this.mouseState = getMouseState(nil, nil)

proc onKeyDown*(this: Input, event: sdl.Event) =
  this.pressedKeys.add(event.key.keysym.sym)

proc onKeyUp*(this: Input, event: sdl.Event) =
  this.releasedKeys.add(event.key.keysym.sym)

proc onMouseButtonDown*(this: Input, event: sdl.Event) =
  this.clickedButtons.add(event.button.button)

proc onMouseButtonUp*(this: Input, event: sdl.Event) =
  this.releasedButtons.add(event.button.button)

proc onMouseMotion*(this: Input, event: sdl.Event) =
  discard

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

proc clicked*(this: Input, button: uint8): bool =
  button in this.clickedButtons

proc down*(this: Input, button: uint8, raw: bool = false): bool =
  bool this.mouseState and SDL_BUTTON(button)

proc released*(this: Input, name: string, raw: bool = false): bool =
  this.getKey(name, raw) in this.releasedKeys

proc released*(this: Input, button: uint8): bool =
  button in this.releasedButtons
