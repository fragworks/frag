import 
  events

import 
  sdl2 as sdl

import
  ../assets,
  ../assets/asset

type
  dEngineEventType* = enum
    LOAD_ASSET

  SDLEventType* = enum
    WINDOW_RESIZE = "WindowEvent_Resized"

  dEngineEvent* = object of RootObj
    case eventType*: dEngineEventType
    of LOAD_ASSET:
      filename*: string
      assetManager*: AssetManager
      assetType*: AssetType

  SDLEvent* = object of dEngineEvent
    sdlEventData*: sdl.Event

  dEngineEventMessage* = object of EventArgs
    event*: dEngineEvent

  SDLEventMessage* = object of EventArgs
    event*: sdl.Event

  EventHandler* = proc(e: EventArgs)