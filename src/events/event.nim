import 
  events

import 
  sdl2

type
  DEngineEventType* = enum
    LOAD_ASSET

  SDLEventType* = enum
    WINDOW_RESIZE = "WindowEvent_Resized"

  DEngineEvent* = object
    case eventType*: DEngineEventType
    of LOAD_ASSET:
      filename*: string

  DEngineEventMessage* = object of EventArgs
    event*: DEngineEvent

  SDLEventMessage* = object of EventArgs
    event*: sdl2.Event

  EventHandler* = proc(e: EventArgs)