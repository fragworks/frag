import
  deques,
  events,
  hashes,
  tables

when defined(js):
  import
    webgl
  
  import
    ../js/res
    
when not defined(js):
  import
    threadpool
  
  import
    sdl2 as sdl

import
  ../assets/asset,
  ../assets/asset_types,
  ../config,
  ../graphics/window,
  ../graphics/camera,
  ../gui/imgui,
  ../utils/viewport

type 
  ModuleType* {.pure.} = enum
    Assets, EventBus, Graphics, GUI, Input

  AssetLoadRequest* = object
    filename*: string
    filepath*: string
    assetId*: Hash
    assetType*: AssetType

  Module* = object
    case moduleType*: ModuleType
    of ModuleType.Assets:
      assetSearchPath*: string
      internalSearchPath*: string
      assetLoadRequests*: Deque[AssetLoadRequest]
      assets*: Table[Hash, ref Asset]
      when defined(js):
        loader*: Loader
      when not defined(js):
        assetLoadsInProgress*: Table[Hash, FlowVarBase]
      loaded*: uint
      peakLoadsInProgress*: uint
    of ModuleType.EventBus:
      emitter*: EventEmitter
      assetManager*: AssetManager
    of ModuleType.Input:
      pressedKeys*, releasedKeys*: seq[cint]
      when not defined(js):
        state*: ptr array[0 .. SDL_NUM_SCANCODES.int, uint8]
    of ModuleType.Graphics:
      when defined(js):
        gl*: WebGLRenderingContext
      when not defined(js):
        rootWindow*: window.Window
        rootGLContext8: sdl.GLContextPtr
    of ModuleType.GUI:
      when not defined(js):
        imgui*: IMGUI
        view*: uint8
        camera*: Camera
        window*: Window
        viewport*: Viewport
        offsetX*, offsetY*: int
    else:
      discard

  AssetManager* = ref Module
  EventBus* = ref Module
  Input* = ref Module
  Graphics* = ref Module
  GUI* = ref Module
