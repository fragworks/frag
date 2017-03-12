import 
  events

import 
  sdl2

import
  ../assets,
  ../assets/asset

type
  dEngineEventType* = enum
    LOAD_ASSET

  SDLEventType* = enum
    WINDOW_RESIZE = "WindowEvent_Resized"

  dEngineEvent* = object
    case eventType*: dEngineEventType
    of LOAD_ASSET:
      filename*: string
      assetManager*: AssetManager
      assetType*: AssetType

  dEngineEventMessage* = object of EventArgs
    event*: dEngineEvent

  SDLEventMessage* = object of EventArgs
    event*: sdl2.Event

  EventHandler* = proc(e: EventArgs)