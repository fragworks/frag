import events

import sdl2 as sdl except Event

import 
  ./event,
  ../input

type
  SDLEventType* {.pure.} = enum
    KeyDown
    KeyUp
    WindowResize = "WindowEvent_Resized"

  SDLEvent* = object of Event
    sdlEventData*: sdl.Event
    case sdlEventType*: SDLEventType
    of SDLEventType.KeyDown, SDLEventType.KeyUp:
      input*: Input
    else:
      discard

  SDLEventMessage* = object of EventArgs
    event*: SDLEvent