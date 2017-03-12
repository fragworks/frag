import 
  events

import 
  sdl2 as sdl

import
  ../assets,
  ../assets/asset

type
  FragEventType* = enum
    LOAD_ASSET

  SDLEventType* = enum
    WINDOW_RESIZE = "WindowEvent_Resized"

  FragEvent* = object of RootObj
    case eventType*: FragEventType
    of LOAD_ASSET:
      filename*: string
      assetManager*: AssetManager
      assetType*: AssetType

  SDLEvent* = object of FragEvent
    sdlEventData*: sdl.Event

  FragEventMessage* = object of EventArgs
    event*: FragEvent

  SDLEventMessage* = object of EventArgs
    event*: sdl.Event

  EventHandler* = proc(e: EventArgs)