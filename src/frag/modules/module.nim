import
  events,
  hashes,
  tables

import
  sdl2 as sdl

import
  ../assets/asset,
  ../config,
  ../graphics/window

type 
  ModuleType* {.pure.} = enum
    Assets, EventBus, Graphics, Input

  Module* = object
    case moduleType*: ModuleType
    of ModuleType.Assets:
      assetSearchPath*: string
      internalSearchPath*: string
      assets*: Table[Hash, ref Asset]
    of ModuleType.EventBus:
      emitter*: EventEmitter
      assetManager*: AssetManager
    of ModuleType.Input:
      pressedKeys*, releasedKeys*: seq[cint]
      state*: ptr array[0 .. SDL_NUM_SCANCODES.int, uint8]
    of ModuleType.Graphics:
      rootWindow*: window.Window
      rootGLContext8: sdl.GLContextPtr
    else:
      discard

  AssetManager* = ref Module
  EventBus* = ref Module
  Input* = ref Module
  Graphics* = ref Module
