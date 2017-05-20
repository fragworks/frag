when defined(js):
  discard
else:
  import
    events

  import
    sdl2 as sdl

  import
    ../config,
    module

  let defaultKeyboardState = sdl.getKeyboardState(nil)

  proc init*(self: Input): bool =
    self.pressedKeys = @[]
    self.releasedKeys = @[]
    return true

  proc update*(self: Input) =
    self.pressedKeys.setLen(0)
    self.releasedKeys.setLen(0)
    self.state = defaultKeyboardState

  proc onKeyDown*(self: Input, event: sdl.Event) =
    self.pressedKeys.add(event.key.keysym.sym)

  proc onKeyUp*(self: Input, event: sdl.Event) =
    self.releasedKeys.add(event.key.keysym.sym)

  proc onMouseButtonDown*(self: Input, event: sdl.Event) =
    discard

  proc onMouseButtonUp*(self: Input, event: sdl.Event) =
    discard

  proc onMouseMotion*(self: Input, event: sdl.Event) =
    discard

  proc getScancode(self: Input, name: string, raw: bool): sdl.Scancode =
    if raw: return sdl.getScancodeFromName(name)
    let key = sdl.getKeyFromName(name)
    return sdl.getScancodeFromKey(key)

  proc getKey(self: Input, name: string, raw: bool): cint =
    if not raw: return sdl.getKeyFromName(name)
    let code = sdl.getScancodeFromName(name)
    return sdl.getKeyFromScancode(code)

  proc down*(self: Input, name: string, raw: bool = false): bool =
    let code = self.getScancode(name, raw)
    self.state[code.int] == 1u8

  proc pressed*(self: Input, name: string, raw: bool = false): bool =
    self.getKey(name, raw) in self.pressedKeys

  proc released*(self: Input, name: string, raw: bool = false): bool =
    self.getKey(name, raw) in self.releasedKeys
